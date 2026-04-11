class IpLocationIpLocation {
  String? ip;
  String? ipNumber;
  int? ipVersion;
  String? countryName;
  String? countryCode2;
  String? isp;
  String? responseCode;
  String? responseMessage;

  IpLocationIpLocation({
    this.ip,
    this.ipNumber,
    this.ipVersion,
    this.countryName,
    this.countryCode2,
    this.isp,
    this.responseCode,
    this.responseMessage,
  });

  IpLocationIpLocation.fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
    ipNumber = json['ip_number'];
    ipVersion = json['ip_version'];
    countryName = json['country_name'];
    countryCode2 = json['country_code2'];
    isp = json['isp'];
    responseCode = json['response_code'];
    responseMessage = json['response_message'];
  }
}