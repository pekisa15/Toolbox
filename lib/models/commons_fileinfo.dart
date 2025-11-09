import 'dart:core';

class CommonsFileInfo {
  String fileName = "";
  String cleanName = "";
  int size = 0;
  int width = 0;
  int height = 0;
  double? duration;
  String mimeType = "";
  String fileUrl = "";
  String wikimediaUrl = "";
  String licenseShortName = "";
  String licenseTerms = "";
  String licenseUrl = "";
  String licenseAttribution = "";

  CommonsFileInfo({
    required this.fileName,
    required this.cleanName,
    required this.size,
    required this.width,
    required this.height,
    this.duration,
    required this.mimeType,
    required this.fileUrl,
    required this.wikimediaUrl,
    required this.licenseShortName,
    required this.licenseTerms,
    required this.licenseUrl,
    required this.licenseAttribution,
  });

  factory CommonsFileInfo.fromJson(Map<String, dynamic> json) {
    return CommonsFileInfo(
      fileName: json['title'] ?? "",
      cleanName: json['imageinfo']?[0]?['extmetadata']?['ObjectName']?['value'] ?? "",
      size: json['imageinfo']?[0]?['size'] ?? 0,
      width: json['imageinfo']?[0]?['width'] ?? 0,
      height: json['imageinfo']?[0]?['height'] ?? 0,
      duration: (json['imageinfo']?[0]?['duration'] != null) ? (json['imageinfo']?[0]?['duration'] as num).toDouble() : null,
      mimeType: json['imageinfo']?[0]?['mime'] ?? "",
      fileUrl: json['imageinfo']?[0]?['url'] ?? "",
      wikimediaUrl: json['imageinfo']?[0]?['descriptionurl'] ?? "",
      licenseShortName: json['imageinfo']?[0]?['extmetadata']?['LicenseShortName']?['value'] ?? "",
      licenseTerms: json['imageinfo']?[0]?['extmetadata']?['UsageTerms']?['value'] ?? "",
      licenseUrl: json['imageinfo']?[0]?['extmetadata']?['LicenseUrl']?['value'] ?? "",
      licenseAttribution: json['imageinfo']?[0]?['extmetadata']?['Artist']?['value'] ?? ""
    );
  }
}