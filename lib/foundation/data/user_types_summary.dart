import 'user_types.dart';

extension SimpleUrlInfoSummary on SimpleUrlInfo {
  static SimpleUrlInfo fromJson(Map<String, dynamic> json) {
    SimpleUrlInfo simpleUrlInfo = SimpleUrlInfo();

    simpleUrlInfo.title = json['title'] ?? '';
    simpleUrlInfo.urlString = json['urlString'] ?? '';
    return simpleUrlInfo;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['title'] = title;
    data['urlString'] = urlString;
    return data;
  }
}

extension SimpleCityInfoSummary on SimpleCityInfo {
  static SimpleCityInfo fromJson(Map<String, dynamic> json) {
    SimpleCityInfo simpleCityInfo = SimpleCityInfo();

    simpleCityInfo.name = json['name'] ?? '';
    simpleCityInfo.langCode = json['lang_code'] ?? '';
    simpleCityInfo.countryCode = json['country_code'] ?? '';
    return simpleCityInfo;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['name'] = name;
    data['lang_code'] = langCode;
    data['country_code'] = countryCode;
    return data;
  }
}
