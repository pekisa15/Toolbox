import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:toolbox/gen/strings.g.dart';

class YouTubeThumbnailPage extends StatefulWidget {
  const YouTubeThumbnailPage({super.key});
  @override
  State<YouTubeThumbnailPage> createState() => _YouTubeThumbnailPage();
}

class _YouTubeThumbnailPage extends State<YouTubeThumbnailPage> {
  String videoId = "";

  Future<void> saveThumbnailToDisk() async {
    String url = "https://i3.ytimg.com/vi/$videoId/maxresdefault.jpg";

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();

    if (response.statusCode != 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.tools.youtubethumbnail.error.failed_to_download)));
      }
      return;
    }

    Uint8List bytes = await consolidateHttpClientResponseBytes(response);

    final params = SaveFileDialogParams(data: bytes, fileName: "$videoId.jpg");
    final filePath = await FlutterFileDialog.saveFile(params: params);

    if (filePath != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.tools.youtubethumbnail.saved)));
      }
    }

    httpClient.close();
  }

  String extractVideoIdFromYoutubeUrl(String url) {
    url = url.trim();
    try {
      Uri uri = Uri.parse(url);
      if (uri.host.contains("youtu.be")) {
        return uri.pathSegments.first;
      } else if (uri.host.contains("youtube.com")) {
        String? videoId = uri.queryParameters["v"];
        if (videoId != null) {
          return videoId;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.tools.youtubethumbnail.title),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.video_library_outlined, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              t.tools.youtubethumbnail.youtube_video_id,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "https://youtube.com/watch?v=...",
                            prefixIcon: Icon(Icons.link_outlined,
                                color: colorScheme.onSurfaceVariant),
                          ),
                          onChanged: (value) {
                            setState(() {
                              videoId = extractVideoIdFromYoutubeUrl(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Preview Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              t.tools.youtubethumbnail.thumbnail_preview,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            color: colorScheme.primaryContainer,
                            child: videoId.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.video_library_outlined,
                                          size: 64,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            t.tools.youtubethumbnail.please_enter_a_video_url,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Image.network(
                                    "https://i3.ytimg.com/vi/$videoId/maxresdefault.jpg",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: colorScheme.errorContainer,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline_outlined,
                                                size: 64,
                                                color: colorScheme
                                                    .onErrorContainer,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                t.tools.youtubethumbnail.error
                                                    .please_enter_a_valid_video_id,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onErrorContainer,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(t.tools.youtubethumbnail.save_thumbnail),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: videoId.isEmpty
                        ? null
                        : () {
                            saveThumbnailToDisk();
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
