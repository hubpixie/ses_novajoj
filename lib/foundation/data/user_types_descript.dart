import 'user_types.dart';

extension SimpleUrlInfoDescript on SimpleUrlInfo {
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

  static isInList(
      {required SimpleUrlInfo element, required List<SimpleUrlInfo> list}) {
    final found = list.where(
        (e) => e.title == element.title || e.urlString == element.urlString);
    return found.isNotEmpty;
  }
}

extension SimpleCityInfoDescript on SimpleCityInfo {
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

  static isInList(
      {required SimpleCityInfo element, required List<SimpleCityInfo> list}) {
    final found = list.where((e) =>
        e.name == element.name &&
        e.langCode == element.langCode &&
        e.countryCode == element.countryCode);
    return found.isNotEmpty;
  }
}

extension ServiceTypeDescriot on ServiceType {
  static ServiceType fromString(String string) {
    return ServiceType.values.firstWhere((element) => element.name == string);
  }

  String get stringClass {
    switch (this) {
      case ServiceType.time:
      case ServiceType.audio:
      case ServiceType.weather:
      case ServiceType.favorite:
      case ServiceType.history:
        return toString().split(".").last;
      default:
        return '';
    }
  }
}
