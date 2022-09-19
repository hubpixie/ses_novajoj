import 'user_types.dart';
import 'package:intl/intl.dart';

extension SimpleUrlInfoDescript on SimpleUrlInfo {
  static SimpleUrlInfo fromJson(Map<String, dynamic> json) {
    SimpleUrlInfo self = SimpleUrlInfo();

    self.title = json['title'] ?? '';
    self.urlString = json['urlString'] ?? '';
    return self;
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
    SimpleCityInfo self = SimpleCityInfo();

    self.name = json['name'] ?? '';
    self.state = json['state'] ?? self.name;
    self.langCode = json['lang_code'] ?? '';
    self.countryCode = json['country_code'] ?? '';
    return self;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['name'] = name;
    data['state'] = state;
    data['lang_code'] = langCode;
    data['country_code'] = countryCode;
    return data;
  }

  static isInList(
      {required SimpleCityInfo element, required List<SimpleCityInfo> list}) {
    final found = list.where((e) =>
        e.name == element.name &&
        e.state == element.state &&
        e.langCode == element.langCode &&
        e.countryCode == element.countryCode);
    return found.isNotEmpty;
  }
}

extension CityInfoDescript on CityInfo {
  static const Map<String, List<String>> kMainCities = {
    "Hawaii": ["en", "US", "夏威夷", "ハワイ"],
    "Sao Paulo": ["pt", "BR", "圣保罗", "サンパロ"],
    "London": ["en", "UK", "伦敦", "サンパロ"],
    "Paris": ["fr", "FR", "巴黎", "パリ"],
    "Moscow": ["ru", "RU", "莫斯科", "パリ"],
    "Urumqi": ["zh", "CN", "乌鲁木齐", "ウルムチ"],
    "Beijing": ["zh", "CN", "北京", "北京"],
    "Seoul": ["ko", "KR", "首尔", "ソウル"],
    "Tokyo": ["ja", "JP", "东京", "東京"],
    "Sydney": ["en", "AU", "悉尼", "シドニー"],
    "New York": ["en", "US", "纽约", "ニューヨーク"],
  };

  static CityInfo fromCurrentLocale({required String name}) {
    CityInfo self = CityInfo();
    String locale = Intl.defaultLocale ?? Intl.systemLocale;
    final nameIndex = (String loc) {
      final lang = loc.split('-').first;
      final index = ['en', 'zh', 'ja'].indexOf(lang);
      return index < 0 ? 0 : index + 1;
    }(locale);

    final cityItem = kMainCities[name];
    self.name = name;
    self.nameDesc = name;
    if (cityItem != null) {
      if (nameIndex >= 2) {
        self.nameDesc = cityItem[nameIndex];
      }
      self.langCode = cityItem[0];
      self.countryCode = cityItem[1];
    }
    return self;
  }

  static CityInfo fromJson(Map<String, dynamic> json) {
    CityInfo self = CityInfo();
    self.id = json['id'] ?? 0;
    self.name = json['name'] ?? '';
    self.nameDesc = json['name_desc'] ?? '';
    self.state = json['state'] ?? self.name;
    self.langCode = json['lang_code'] ?? '';
    self.countryCode = json['country_code'] ?? '';
    self.timezone = json['timezone'] ?? 0;
    return self;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['name'] = name;
    data['name_desc'] = nameDesc;
    data['state'] = state;
    data['lang_code'] = langCode;
    data['country_code'] = countryCode;
    data['timezone'] = timezone;
    return data;
  }

  static isInList({required CityInfo element, required List<CityInfo> list}) {
    final found = list.where((e) =>
        e.name == element.name &&
        ((e.state != '' && e.state == element.state) || e.state == '') &&
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
