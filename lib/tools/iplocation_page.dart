import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toolbox/core/dialogs.dart';
import 'package:toolbox/core/http_requests.dart';
import 'package:toolbox/core/url.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'package:toolbox/models/iplocation_iplocation.dart';

class IpLocationPage extends StatefulWidget {
  const IpLocationPage({super.key});

  @override
  State<IpLocationPage> createState() => _IpLocationPage();
}

class _IpLocationPage extends State<IpLocationPage> {
  final String apiEndpoint = "https://api.iplocation.net/?ip=";
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  IpLocationIpLocation? ipLocation;

  Future<IpLocationIpLocation> getIpLocation(String ip) async {
    final response = await httpGet("$apiEndpoint$ip", {});
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return IpLocationIpLocation.fromJson(json);
    } else {
      throw Exception("Failed to fetch IP location");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(t.tools.iplocation.title),
          actions: [
            Tooltip(
              message: t.tools.iplocation.api_used,
              child: IconButton(
                icon: const Icon(Icons.copyright_outlined),
                onPressed: () {
                  showCustomButtonsTextDialog(
                    context,
                    t.tools.iplocation.about_the_api,
                    t.tools.iplocation.about_the_api_description(source: "iplocation.net"),
                    [
                      TextButton(
                        onPressed: () {
                          launchUrlInBrowser("https://api.iplocation.net/");
                        },
                        child: Text(t.tools.iplocation.visit_website),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(t.generic.ok)
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: t.tools.iplocation.ip_address,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.location_on_outlined,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : () async {
                                setState(() {
                                  isLoading = true;
                                  ipLocation = null;
                                });
                                try {
                                  if (_controller.text.isEmpty) {
                                    showOkTextDialog(context, t.tools.iplocation.error.ip_required, t.tools.iplocation.error.please_enter_an_ip_address);
                                    return;
                                  }
                                  final response = await getIpLocation(_controller.text);
                                  setState(() => ipLocation = response);
                                } catch (e) {
                                  showOkTextDialog(context, t.tools.iplocation.error.error_fetching_location, t.tools.iplocation.error.error_fetching_location_description);
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              },
                              icon: const Icon(Icons.search),
                              label: Text(t.tools.iplocation.get_ip_location),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (ipLocation != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.tools.iplocation.location_information,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            _buildResultRow(
                                context,
                                Icons.public_outlined,
                                t.tools.iplocation.ip_address,
                                ipLocation?.ip ?? t.tools.iplocation.n_a,
                                colorScheme
                            ),
                            const Divider(),
                            _buildResultRow(
                                context,
                                Icons.flag_outlined,
                                t.tools.iplocation.country,
                                "${ipLocation?.countryName ?? t.tools.iplocation.n_a} [${ipLocation?.countryCode2 ?? t.tools.iplocation.n_a}]",
                                colorScheme
                            ),
                            const Divider(),
                            _buildResultRow(
                                context,
                                Icons.business_outlined,
                                t.tools.iplocation.provider,
                                ipLocation?.isp ?? t.tools.iplocation.n_a,
                                colorScheme
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, IconData icon, String title, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
