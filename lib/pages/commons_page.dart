
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:toolbox/core/dialogs.dart';
import 'package:toolbox/core/url.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'package:toolbox/models/commons_fileinfo.dart';

class CommonsPage extends StatefulWidget {
  const CommonsPage({super.key});

  @override
  State<CommonsPage> createState() => _CommonsPage();
}

class _CommonsPage extends State<CommonsPage> {
  final String apiEndpoint = "https://commons.wikimedia.org/w/api.php";
  final int pageSize = 10;

  String searchQuery = "";

  int currentPage = 1;
  List<CommonsFileInfo> mediaFiles = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getContentOfHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  String getFileSizeString(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes ${t.tools.commons.bytes}';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} ${t.tools.commons.kilobytes}';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} ${t.tools.commons.megabytes}';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ${t.tools.commons.gigabytes}';
    }
  }

  String getFileDurationString(double durationInSeconds) {
    if (durationInSeconds < 60) {
      return '${durationInSeconds.toStringAsFixed(0)}s';
    } else if (durationInSeconds < 3600) {
      final int minutes = durationInSeconds ~/ 60;
      final double seconds = durationInSeconds % 60;
      return '$minutes:${seconds.toStringAsFixed(0)}';
    } else {
      final int hours = durationInSeconds ~/ 3600;
      final int minutes = (durationInSeconds % 3600) ~/ 60;
      final double seconds = durationInSeconds % 60;
      return '$hours:$minutes:${seconds.toStringAsFixed(0)}';
    }
  }

  Future<void> fetchFileInfo(String fileName, int pageNumber) async {
    setState(() {
      mediaFiles = [];
    });
    final Uri url = Uri.parse("$apiEndpoint?action=query&format=json&generator=search&gsrsearch=$fileName&gsrlimit=$pageSize&gsroffset=${(pageNumber - 1) * pageSize}&gsrnamespace=6&prop=imageinfo&iiprop=url|size|mime|metadata|extmetadata");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(response.body));
        if (data.containsKey('query') && data['query'].containsKey('pages')) {
          final Map<String, dynamic> pages = Map<String, dynamic>.from(data['query']['pages']);
          List<CommonsFileInfo> fetchedFiles = [];
          for (var page in pages.values) {
            fetchedFiles.add(CommonsFileInfo.fromJson(Map<String, dynamic>.from(page)));
          }
          setState(() {
            mediaFiles = fetchedFiles;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.tools.commons.no_files_found)),
            );
            setState(() {
              mediaFiles = [];
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${t.generic.error}: ${response.statusCode}')),
          );
          setState(() {
            mediaFiles = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.generic.error}: $e')),
        );
        setState(() {
          mediaFiles = [];
        });
      }
    }
  }

  Widget getLeadingByMimeType(String mimeType, String fileUrl) {
    if (mimeType.startsWith('image/')) {
      if (!mimeType.contains('jpeg') && !mimeType.contains('png') && !mimeType.contains('gif') && !mimeType.contains('webp') && !mimeType.contains('svg')) {
        return Icon(Icons.image_outlined);
      }
      if (mimeType.contains('svg')) {
        return GestureDetector(
          onTap: () {
            showImagePreviewDialog(context, fileUrl, isSvg: true);
          },
          child: SvgPicture.network(fileUrl, width: 40, height: 40, placeholderBuilder: (context) => SizedBox(
            width: 40,
            height: 40,
            child: Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )),
          ), errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.image_not_supported_outlined);
          }),
        );
      }
      return GestureDetector(
        onTap: () {
          showImagePreviewDialog(context, fileUrl);
        },
        child: Image.network(fileUrl, width: 40, height: 40, fit: BoxFit.cover, loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: child
            );
          }
          return SizedBox(
            width: 40,
            height: 40,
            child: Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image_not_supported_outlined);
        }),
      );
    } else if (mimeType.startsWith('video/')) {
      return Icon(Icons.videocam_outlined);
    } else if (mimeType.startsWith('audio/') || mimeType.startsWith('application/ogg')) {
      return Icon(Icons.audiotrack_outlined);
    } else if (mimeType == 'application/pdf') {
      return Icon(Icons.picture_as_pdf_outlined);
    } else {
      return Icon(Icons.insert_drive_file_outlined);
    }
  }

  Future<void> showImagePreviewDialog(BuildContext context, String imageUrl, {bool isSvg = false}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(200),
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(24),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          content: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: IconButton(
                    tooltip: t.tools.commons.close_preview,
                    icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 48,
                  height: MediaQuery.of(context).size.height - 200,
                  child: InteractiveViewer(
                    maxScale: 6.0,
                    child: isSvg
                        ? SvgPicture.network(imageUrl, height: MediaQuery.of(context).size.width - 48, placeholderBuilder: (context) =>
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                      ),
                    ), errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white, size: 100));
                    })
                        : Image.network(
                        imageUrl, loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                        ),
                      );
                    }, errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported_outlined, size: 100);
                    }),
                  ),
                ),
                Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMainDialog(CommonsFileInfo file) {
    List<TextButton> buttons = [
      if (file.licenseUrl.isNotEmpty)
      TextButton(
        onPressed: () => launchUrlInBrowser(file.licenseUrl),
        child: Text(t.tools.commons.view_license_details)
      ),
      TextButton(
        onPressed: () async {
          await downloadMediaAsFile(file);
          if (mounted) {
            Navigator.pop(context);
          }
        },
        child: Text(t.tools.commons.download_media)
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(t.tools.commons.close)
      ),
    ];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(file.cleanName.isNotEmpty ? getContentOfHtmlTags(file.cleanName) : getContentOfHtmlTags(file.fileName)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.tools.commons.file_information, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${t.tools.commons.mime_type} : ${file.mimeType}"),
                  Text("${t.tools.commons.file_size} : ${getFileSizeString(file.size)}"),
                  if (file.width != 0 && file.height != 0)
                    Text("${t.tools.commons.dimensions} : ${file.width} x ${file.height}"),
                  if (file.duration != null)
                    Text("${t.tools.commons.duration} : ${getFileDurationString(file.duration!)}"),
                  SizedBox(height: 16),
                  Text(t.tools.commons.file_license, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(file.licenseShortName.isNotEmpty ? file.licenseShortName : t.tools.commons.unknown_license),
                  if (file.licenseTerms.isNotEmpty)
                    Text(getContentOfHtmlTags(file.licenseTerms)),
                  SizedBox(height: 8),
                  if (file.licenseAttribution.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(t.tools.commons.file_by, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(getContentOfHtmlTags(file.licenseAttribution)),
                  ]
                ],
              ),
            ),
            actions: buttons,
          );
        }
    );
  }

  Future<void> downloadMediaAsFile(CommonsFileInfo file) async {
    try {
      showDownloadingDialog(context);
      final response = await http.get(Uri.parse(file.fileUrl));
      if (response.statusCode == 200) {
        await saveFile(file.fileName, response.bodyBytes);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.tools.commons.error.error_downloading_file(errorCode: response.statusCode.toString()))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.tools.commons.error.error_download_file_check_internet))
        );
      }
    }
    if (mounted) {
      hideDownloadingDialog(context);
    }
    return;
  }

  Future<void> saveFile(String fileName, Uint8List fileBytes) async {
    final params = SaveFileDialogParams(data: fileBytes, fileName: fileName);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    if (filePath != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(t.tools.commons.file_downloaded_successfully)
            )
        );
      }
    }
  }

  Future<void> showDownloadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(t.tools.commons.downloading)
            ],
          ),
        );
      },
    );
  }

  void hideDownloadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(t.tools.commons.title),
            actions: [
              IconButton(
                tooltip: t.tools.commons.data_source_and_licensing,
                icon: Icon(Icons.copyright_outlined),
                onPressed: () {
                  List<TextButton> buttons = [
                    TextButton(
                      onPressed: () => launchUrlInBrowser("https://commons.wikimedia.org"),
                      child: Text(t.tools.commons.open_wikimedia_commons),
                    ),TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t.generic.ok)
                    ),
                  ];
                  showCustomButtonsTextDialog(
                    context,
                      t.tools.commons.data_source_and_licensing,
                      t.tools.commons.data_source_and_licensing_description,
                      buttons
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: t.tools.commons.search_files,
                        ),
                        onSubmitted: (value) {
                          currentPage = 1;
                          searchQuery = value.trim();
                          if (value.trim().isNotEmpty) {
                            fetchFileInfo(value.trim(), currentPage);
                          }
                        },
                      ),
                    ),
                    mediaFiles.isEmpty && searchQuery.isEmpty ? Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        t.tools.commons.enter_search_query_to_find_files,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ) : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: mediaFiles.length,
                      itemBuilder: (context, index) {
                        final file = mediaFiles[index];
                        return Card(
                          child: ListTile(
                            leading: SizedBox(
                                width: 40,
                                child: Center(child: getLeadingByMimeType(file.mimeType, file.fileUrl))
                            ),
                            title: Text(getContentOfHtmlTags(file.cleanName.isNotEmpty ? file.cleanName : file.fileName)),
                            subtitle: Text('${getFileSizeString(file.size)} - ${file.width != 0 && file.height != 0 ? "${file.width}x${file.height}" : ""}${file.duration != null ? " - ${getFileDurationString(file.duration!)}" : ""}'),
                            trailing: IconButton(
                              tooltip: t.tools.commons.view_on_wikimedia,
                              icon: Icon(Icons.open_in_new_outlined),
                              onPressed: () {
                                launchUrlInBrowser(file.wikimediaUrl);
                              },
                            ),
                            onTap: () {
                              showMainDialog(file);
                            },
                          ),
                        );
                      },
                    ),
                    // Change page buttons
                    if (searchQuery.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FilledButton(
                                onPressed: currentPage > 1 ? () {
                                  setState(() {
                                    currentPage--;
                                  });
                                  fetchFileInfo(searchQuery, currentPage);
                                } : null,
                                child: Text(t.tools.commons.previous)
                              ),
                              FilledButton(
                                onPressed: mediaFiles.isNotEmpty && mediaFiles.length == pageSize ? () {
                                  setState(() {
                                    currentPage++;
                                  });
                                  fetchFileInfo(searchQuery, currentPage);
                                } : null,
                                child: Text(t.tools.commons.next)
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
            ),
          )
      ),
    );
  }
}