import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

const int DNS_TYPE_A = 1;
const int DNS_TYPE_AAAA = 28;
const int DNS_TYPE_CNAME = 5;
const int DNS_TYPE_NS = 2;
const int DNS_TYPE_PTR = 12;
const int DNS_TYPE_MX = 15;
const int DNS_TYPE_TXT = 16;

Future<List<String>?> rawDnsLookup(String domain, String dnsServer, int type, {bool throwError = false}) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  if (type == DNS_TYPE_PTR) {
    final String reverseDomainSuffix = ".in-addr.arpa";
    final List<String> parts = domain.split('.');
    final String reversedDomain = parts.reversed.join('.') + reverseDomainSuffix;
    domain = reversedDomain;
  }
  final query = _buildDnsQuery(domain, type);
  final server = InternetAddress(dnsServer);

  socket.send(query, server, 53);

  final completer = Completer<List<String>>();
  final results = <String>[];

  socket.listen((event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        final data = datagram.data;
        _parseDnsResponse(data, type).forEach((result) {
          if (!results.contains(result)) {
            results.add(result);
          }
        });
        socket.close();
        completer.complete(results);
      }
    }
  });

  return completer.future.timeout(Duration(seconds: 5), onTimeout: () {
    socket.close();
    if (throwError) {
      throw TimeoutException("DNS query timed out");
    }
    return [];
  });
}

Uint8List _buildDnsQuery(String domain, int type) {
  final buffer = BytesBuilder();

  // Header
  buffer.add([0x12, 0x34]); // ID
  buffer.add([0x01, 0x00]); // Standard query
  buffer.add([0x00, 0x01]); // QDCOUNT
  buffer.add([0x00, 0x00]); // ANCOUNT
  buffer.add([0x00, 0x00]); // NSCOUNT
  buffer.add([0x00, 0x00]); // ARCOUNT

  // Question
  for (final label in domain.split('.')) {
    buffer.addByte(label.length);
    buffer.add(label.codeUnits);
  }
  buffer.addByte(0); // End of QNAME
  buffer.add([0x00, type]); // QTYPE
  buffer.add([0x00, 0x01]); // QCLASS IN

  return buffer.toBytes();
}

List<String> _parseDnsResponse(Uint8List data, int type) {
  final results = <String>[];
  final reader = _ByteReader(data);

  reader.skip(6 * 2); // skip header

  final qdCount = 1;
  for (int i = 0; i < qdCount; i++) {
    reader.skipName(); // QNAME
    reader.skip(4); // QTYPE + QCLASS
  }

  final anCount = (data[6] << 8) | data[7];
  for (int i = 0; i < anCount; i++) {
    reader.skipName();
    final rtype = reader.readShort();
    reader.skip(2); // class
    reader.skip(4); // ttl
    final rdLength = reader.readShort();
    final startOffset = reader.offset;

    if (rtype == type) {
      if (type == DNS_TYPE_A) {
        // A record
        final ip = List.generate(4, (_) => reader.readByte()).join('.');
        results.add(ip);
      } else if (type == DNS_TYPE_AAAA) {
        // AAAA
        final parts = List.generate(8, (_) => reader.readShort().toRadixString(16));
        results.add(parts.join(':'));
      } else if (type == DNS_TYPE_NS) {
        // NS
        final ns = reader.readName();
        results.add(ns);
      } else if ([DNS_TYPE_CNAME, DNS_TYPE_PTR].contains(type)) {
        // CNAME PTR
        results.add(reader.readName());
      } else if (type == DNS_TYPE_MX) {
        // MX
        final preference = reader.readShort();
        final exchange = reader.readName();
        results.add('$exchange (pref: $preference)');
      } else if (type == DNS_TYPE_TXT) {
        // TXT
        final txtEnd = startOffset + rdLength;
        while (reader.offset < txtEnd) {
          final length = reader.readByte();
          String txt = "";
          for (int j = 0; j < length; j++) {
            txt += String.fromCharCode(reader.readByte());
          }
          if (txt.isNotEmpty) {
            results.add(txt);
          }
        }
      } else {
        reader.skip(rdLength); // Unhandled type
      }
    } else {
      reader.skip(rdLength); // Skip non-matching record
    }
  }

  return results;
}

class _ByteReader {
  final Uint8List data;
  int offset = 0;

  _ByteReader(this.data);

  int readByte() => data[offset++];
  int readShort() => (readByte() << 8) | readByte();
  void skip(int count) => offset += count;

  void skipName() {
    final start = offset;
    while (true) {
      final len = data[offset];
      if (len == 0) {
        offset++;
        break;
      }
      if ((len & 0xC0) == 0xC0) {
        // Compression pointer
        offset += 2;
        break;
      }
      offset += len + 1;
    }
  }

  String readName() {
    final nameParts = <String>[];
    int pos = offset;
    bool jumped = false;
    int jumpOffset = -1;

    while (true) {
      final len = data[pos];
      if (len == 0) {
        if (!jumped) offset = pos + 1;
        break;
      }

      if ((len & 0xC0) == 0xC0) {
        final b2 = data[pos + 1];
        final pointer = ((len & 0x3F) << 8) | b2;
        if (!jumped) {
          jumpOffset = pos + 2;
        }
        pos = pointer;
        jumped = true;
        continue;
      }

      pos++;
      final label = String.fromCharCodes(data.sublist(pos, pos + len));
      nameParts.add(label);
      pos += len;
    }

    if (!jumped) {
      offset = pos + 1;
    } else {
      offset = jumpOffset;
    }

    return nameParts.join('.');
  }
}