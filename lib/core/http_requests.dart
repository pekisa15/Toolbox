import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';

const String userAgentAppUrl = "https://jtu.me/tbx-ua";

Future<http.Response> httpGet(String url, Map<String, String> params) async {
  String urlWithParams = url;
  if (params.isNotEmpty) {
    urlWithParams += "?";
    params.forEach((key, value) {
      key = Uri.encodeComponent(key);
      value = Uri.encodeComponent(value);
      urlWithParams += "$key=$value&";
    });
    urlWithParams = urlWithParams.substring(0, urlWithParams.length - 1);
  }
  Map<String, String> headers = {"User-Agent": await getToolboxUserAgent()};
  return await http.get(Uri.parse(urlWithParams), headers: headers);
}

Future<http.Response> httpPost(String url, Map<String, String> params) async {
  Map<String, String> headers = {"User-Agent": await getToolboxUserAgent()};
  return await http.post(Uri.parse(url), headers: headers, body: params);
}

Future<String> getToolboxUserAgent() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final appName = packageInfo.appName;
  final appVersion = packageInfo.version;
  final osName = Platform.operatingSystem;
  final packageName = packageInfo.packageName;
  final dartVersion = Platform.version;

  return "$appName/$appVersion ($userAgentAppUrl; $osName:$packageName) Dart/${dartVersion.split(' ')[0]} (dart:io)";
}
