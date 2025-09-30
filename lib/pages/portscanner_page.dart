
import 'package:flutter/material.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'dart:io';
import 'dart:async';

import 'package:toolbox/models/portscanner_scanresult.dart';

class PortScanner extends StatefulWidget {
  const PortScanner({super.key});

  @override
  State<PortScanner> createState() => _PortScanner();
}

class _PortScanner extends State<PortScanner> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _startPortController = TextEditingController(text: '1');
  final TextEditingController _endPortController = TextEditingController(text: '512');

  int startPort = 1;
  int endPort = 512;

  var testedPort = 0;
  bool isScanning = false;

  List<ScanResult> scanResults = [];
  StreamController<ScanResult> controller = StreamController<ScanResult>();

  @override
  void dispose() {
    _hostController.dispose();
    controller.close();
    super.dispose();
  }

  Future<bool> isTcpOpen(String host, int port,
      {Duration timeout = const Duration(milliseconds: 800)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<ScanResult> scanPorts(String host, int startPort, int endPort, {int concurrency = 50}) async* {
    final ports = List.generate(endPort - startPort + 1, (i) => startPort + i);

    if (isScanning) {
      await stopScan();
    }

    if (mounted) {
      setState(() {
        isScanning = true;
      });
    }

    () async {
      for (var i = 0; i < ports.length; i += concurrency) {
        if (!isScanning) return;
        final batch = ports.skip(i).take(concurrency);
        await Future.wait(batch.map((port) async {
          final tcpOpen = await isTcpOpen(host, port);
          if (!isScanning) return;
          controller.add(ScanResult(port, tcpOpen));
        }));
      }
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
    ();

    yield* controller.stream;
  }

  Future<void> stopScan() async {
    await controller.close();
    controller = StreamController<ScanResult>();
    if (mounted) {
      setState(() {
        isScanning = false;
      });
    }
  }

  String? getPortSubtitle(String port) {
    switch (port) {
      case '21':
        return 'FTP';
      case '22':
        return 'SSH';
      case '23':
        return 'Telnet';
      case '25':
        return 'SMTP';
      case '43':
        return 'WHOIS';
      case '53':
        return 'DNS';
      case '80':
        return 'HTTP';
      case '88':
        return 'Kerberos';
      case '110':
        return 'POP3';
      case '123':
        return 'NTP';
      case '139':
        return 'NetBIOS';
      case '143':
        return 'IMAP';
      case '177':
        return 'XDMCP';
      case '194':
        return 'IRC';
      case '389':
        return 'LDAP';
      case '443':
        return 'HTTPS';
      case '445':
        return 'SMB';
      case '465':
        return 'SMTP (SSL)';
      case '554':
        return 'RTSP';
      case '587':
        return 'SMTP (TLS)';
      case '636':
        return 'LDAPS';
      case '666':
        return 'Doom';
      case '853':
        return 'DNS over TLS';
      case '873':
        return 'rsync';
      case '993':
        return 'IMAPS';
      case '995':
        return 'POP3S';
      case '1521':
        return 'Oracle DB';
      case '1935':
        return 'RTMP';
      case '3306':
        return 'MySQL';
      case '3389':
        return 'Microsoft RDP';
      case '5000':
        return 'UPNP or Synology DSM';
      case '5001':
        return 'Synology DSM';
      case '5432':
        return 'PostgreSQL';
      case '5900':
        return 'VNC';
      case '6379':
        return 'Redis';
      case '19132':
        return 'Minecraft (Bedrock)';
      case '19133':
        return 'Minecraft (Bedrock)';
      case '27015':
        return 'Source Engine (Valve)';
      case '27016':
        return 'Source Engine (Valve)';
      case '25565':
        return 'Minecraft (Java)';
      case '27017':
        return 'MongoDB';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(t.tools.portscanner.title),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: t.tools.portscanner.host_to_scan,
                          ),
                          controller: _hostController,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: t.tools.portscanner.start_port,
                                ),
                                keyboardType: TextInputType.number,
                                controller: _startPortController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: t.tools.portscanner.end_port,
                                ),
                                keyboardType: TextInputType.number,
                                controller: _endPortController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                              onPressed: () async {
                                if (isScanning) {
                                  await stopScan();
                                  if (mounted) {
                                    setState(() {
                                      isScanning = false;
                                    });
                                  }
                                  return;
                                }

                                final host = _hostController.text.trim();
                                if (host.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(t.tools.portscanner.error.please_enter_a_valid_host)),
                                  );
                                  return;
                                }

                                startPort = int.tryParse(_startPortController.text) ?? 1;
                                endPort = int.tryParse(_endPortController.text) ?? 512;

                                if (startPort < 1 || startPort > 65535 || endPort < 1 || endPort > 65535 || startPort > endPort) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(t.tools.portscanner.error.please_enter_a_valid_port_number)),
                                  );
                                  return;
                                }

                                setState(() {
                                  testedPort = 0;
                                  scanResults.clear();
                                });
                                scanPorts(host, startPort, endPort).listen(
                                        (result) {
                                      setState(() {
                                        testedPort += 1;
                                        if (testedPort > endPort - startPort + 1) {
                                          testedPort = endPort - startPort + 1;
                                        }
                                        scanResults.add(result);
                                      });
                                    }
                                );
                              },
                              child: Text(isScanning ? t.tools.portscanner.stop_scan : t.tools.portscanner.start_scan)
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (testedPort > 0)
                          Text('${(testedPort / (endPort - startPort + 1) * 100).toStringAsFixed(2)}% ($testedPort/${endPort - startPort + 1})'),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: endPort - startPort + 1,
                          itemBuilder: (context, index) {
                            final result = scanResults.firstWhere(
                                  (r) => r.port == startPort + index,
                              orElse: () => ScanResult(startPort + index, null),
                            );

                            if (result.open != true) {
                              return const SizedBox.shrink();
                            }

                            return ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              title: Text('${t.tools.portscanner.port} ${result.port}'),
                              subtitle: Text(getPortSubtitle('${result.port}') ?? '${result.port}'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}