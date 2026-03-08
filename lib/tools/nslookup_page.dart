import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toolbox/core/colors.dart';
import 'package:toolbox/core/dialogs.dart';
import 'package:toolbox/core/raw_dns_lookup.dart';
import 'package:toolbox/gen/strings.g.dart';

// Map DNS type numbers to names
final Map<int, String> typeMap = {
  1: 'A',
  28: 'AAAA',
  15: 'MX',
  16: 'TXT',
  2: 'NS',
  5: 'CNAME',
  12: 'PTR',
};

enum DnsProvider {
  googleDoh('Google DoH', 'dns.google', 'resolve', true),
  cloudflareDoh('Cloudflare DoH', 'cloudflare-dns.com', 'dns-query', true),
  alidnsDoh('Alibaba Cloud DoH', 'dns.alidns.com', 'resolve', true),
  dnssbDoh('DNS.SB DoH', 'doh.dns.sb', 'dns-query', true),
  google('Google', '8.8.8.8', null, false),
  cloudflare('Cloudflare', '1.1.1.1', null, false),
  quad9('Quad9', '9.9.9.9', null, false),
  adguard('AdGuard', '94.140.14.14', null, false),
  adguardUnfiltered('AdGuard (unfiltered)', '94.140.14.140', null, false),
  dns4euProtected('DNS4EU (protected)', '86.54.11.1', null, false),
  dns4euUnfiltered('DNS4EU (unfiltered)', '86.54.11.100', null, false),
  system('System DNS', null, null, false);

  final String name;
  final String? host;
  final String? endpoint;
  final bool isDoh;
  const DnsProvider(this.name, this.host, this.endpoint, this.isDoh);
}

class NslookupPage extends StatefulWidget {
  const NslookupPage({super.key});
  @override
  State<NslookupPage> createState() => _NslookupPage();
}

class _NslookupPage extends State<NslookupPage> {
  bool loading = false;
  Map<String, List<String>> _dnsRecords = {};
  final TextEditingController _domainController = TextEditingController();
  DnsProvider _selectedProvider = DnsProvider.googleDoh;
  DnsProvider? _lastSelectedProvider;

  Future<Map<String, List<String>>> getDnsRecordsDns(String domain, String? host) async {
    if (host == null) {
      return getDnsRecordsSystem(domain);
    } else {
      Map<String, List<String>> recordsToReturn = {};
      for (String type in typeMap.values) {
        try {
          final records = await rawDnsLookup(domain, host, typeMap.entries.firstWhere((entry) => entry.value == type).key, throwError: true);
          if (records != null && records.isNotEmpty) {
            recordsToReturn[type] = records;
          }
        } catch (e) {
          // Continue with next record type if one fails
          debugPrint('Error resolving $domain with DNS provider $host for type $type: $e');
        }
      }
      return recordsToReturn;
    }
  }

  Future<Map<String, List<String>>> getDnsRecordsSystem(String domain) async
  {
    Map<String, List<String>> records = {};

    try {
      // System DNS only supports A/AAAA lookups
      final addresses = await InternetAddress.lookup(domain);

      List<String> ipv4 = [];
      List<String> ipv6 = [];

      for (var address in addresses) {
        if (address.type == InternetAddressType.IPv4) {
          ipv4.add(address.address);
        } else if (address.type == InternetAddressType.IPv6) {
          ipv6.add(address.address);
        }
      }

      if (ipv4.isNotEmpty) records['A'] = ipv4;
      if (ipv6.isNotEmpty) records['AAAA'] = ipv6;
    } catch (e) {
      // Failed to resolve
      debugPrint('Error resolving $domain with system DNS: $e');
    }

    return records;
  }

  Future<Map<String, List<String>>> getDnsRecordsDoH(String domain, String host, String endpoint) async {
    Map<String, List<String>> records = {};

    // Record types to query
    final recordTypes = typeMap.values.toList();

    for (String type in recordTypes) {
      try {
        final response = await http.get(
          Uri.parse('https://$host/$endpoint?name=$domain&type=$type'),
          headers: {'accept': 'application/dns-json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['Answer'] != null) {
            List<String> values = [];
            for (var answer in data['Answer']) {
              // Check if the answer type matches the requested type
              int answerType = answer['type'];
              String answerTypeName = typeMap[answerType] ?? 'UNKNOWN';

              // Only include answers that match the requested type
              if (answerTypeName == type) {
                String value = answer['data'].toString();
                values.add(value);
              }
            }
            if (values.isNotEmpty) {
              records[type] = values;
            }
          }
        }
      } catch (e) {
        // Continue with next record type if one fails
        debugPrint('Error resolving $domain with DoH provider $endpoint for type $type: $e');
      }
    }

    return records;
  }

  Future<Map<String, List<String>>> getDnsRecords(String domain) async {
    if (_selectedProvider.isDoh) {
      return getDnsRecordsDoH(domain, _selectedProvider.host ?? '', _selectedProvider.endpoint ?? '');
    } else {
      return getDnsRecordsDns(domain, _selectedProvider.host);
    }
  }

  IconData _getIconForRecordType(String recordType) {
    switch (recordType) {
      case 'A':
      case 'AAAA':
        return Icons.dns_outlined;
      case 'MX':
        return Icons.email_outlined;
      case 'TXT':
        return Icons.text_fields_outlined;
      case 'NS':
        return Icons.dns_outlined;
      case 'CNAME':
        return Icons.link_outlined;
      case 'PTR':
        return Icons.reply_outlined;
      default:
        return Icons.info_outlined;
    }
  }

  List<Widget> _buildDnsRecordCards(ColorScheme colorScheme) {
    final allRecordTypes = typeMap.values.toList();
    List<Widget> cards = [];

    for (String recordType in allRecordTypes) {
      final records = _dnsRecords[recordType];
      final hasRecords = records != null && records.isNotEmpty;
      final isSystemUnsupported = _lastSelectedProvider == DnsProvider.system && recordType != 'A' && recordType != 'AAAA';

      cards.add(
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasRecords
                            ? colorScheme.primaryContainer
                            : getDefaultInputColor(context, colorScheme),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconForRecordType(recordType),
                        color: hasRecords
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$recordType Records",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasRecords
                                ? null
                                : colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const Spacer(),
                    if (!isSystemUnsupported)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasRecords
                              ? colorScheme.secondaryContainer
                              : getDefaultInputColor(context, colorScheme),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hasRecords ? "${records.length}" : "0",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: hasRecords
                                        ? colorScheme.onSecondaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isSystemUnsupported)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3)
                      )
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.tools.nslookup.not_supported_by_system_dns,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (hasRecords)
                  ...records.map((record) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                record,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(),
                              ),
                            ),
                          ],
                        ),
                      )
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        t.tools.nslookup.no_records_found,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      cards.add(const SizedBox(height: 12));
    }
    return cards;
  }

  @override
  void initState() {
    super.initState();
  }

  void lookup() {
    if (_domainController.text.isEmpty) {
      showOkTextDialog(context, t.generic.error, t.tools.nslookup.error.please_enter_a_domain_name);
      return;
    }
    setState(() {
      loading = true;
      _lastSelectedProvider = _selectedProvider;
      _dnsRecords.clear();
    });
    getDnsRecords(_domainController.text.trim()).then((value) {
      setState(() {
        _dnsRecords = value;
        loading = false;
      });
      if (_dnsRecords.isEmpty) {
        showOkTextDialog(context, t.generic.error, t.tools.nslookup.error.no_address_associated_with_domain);
      }
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      showOkTextDialog(context, t.generic.error, t.tools.nslookup.error.no_address_associated_with_domain);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.tools.nslookup.title),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _domainController,
                          decoration: InputDecoration(
                            labelText: t.tools.nslookup.enter_a_domain_name,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.language_outlined,
                                color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownMenu<DnsProvider>(
                                width: MediaQuery.of(context).size.width - 64,
                                menuHeight: 300,
                                initialSelection: _selectedProvider,
                                onSelected: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedProvider = value;
                                    });
                                  }
                                },
                                dropdownMenuEntries: DnsProvider.values
                                    .map((provider) => DropdownMenuEntry(
                                          value: provider,
                                          leadingIcon: provider == DnsProvider.system
                                              ? const Icon(Icons.router_outlined)
                                              : provider.isDoh
                                                ? const Icon(Icons.https_outlined)
                                                : const Icon(Icons.dns_outlined),
                                          label: provider.name,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: lookup,
                            icon: const Icon(Icons.search),
                            label: Text(t.tools.nslookup.lookup),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_dnsRecords.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      children: _buildDnsRecordCards(colorScheme),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
