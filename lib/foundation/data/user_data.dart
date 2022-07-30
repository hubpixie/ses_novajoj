import 'dart:convert';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_summary.dart';

enum _UserDataKey {
  miscMyTimes,
  miscOnlineSites,
  miscWeatherCities,
}

extension _UserDataKeyInfo on _UserDataKey {
  String get name {
    switch (this) {
      case _UserDataKey.miscMyTimes:
        return 'misc_my_times';
      case _UserDataKey.miscOnlineSites:
        return 'misc_online_sites';
      case _UserDataKey.miscWeatherCities:
        return 'misc_weather_cities';
      default:
        return '';
    }
  }
}

class UserData {
  static const String _kDefaultListValueKey = 'values';
  static final UserData _instance = UserData._internal();
  factory UserData() {
    return _instance;
  }
  UserData._internal();

  /// variables for properties
  final List<SimpleUrlInfo> _miscMyTimes = [];
  final List<SimpleUrlInfo> _miscOnlineSites = [];
  final List<SimpleCityInfo> _miscWeatherCities = [];

  final EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();

  List<SimpleUrlInfo> get miscMyTimes => _miscMyTimes;
  List<SimpleUrlInfo> get miscOnlineSites => _miscOnlineSites;
  List<SimpleCityInfo> get miscWeatherCities => _miscWeatherCities;

  ///
  /// read all keys and their values
  ///
  void readValues() {
    // miscMyTimes
    _miscMyTimes.clear();
    _miscMyTimes.addAll(
        [SimpleUrlInfo(), SimpleUrlInfo(), SimpleUrlInfo(), SimpleUrlInfo()]);
    _getSimpleUrlInfoList(
        key: _UserDataKey.miscMyTimes.name, outData: _miscMyTimes);

    // miscOnlineSites
    _miscOnlineSites.clear();
    _getSimpleUrlInfoList(
        key: _UserDataKey.miscOnlineSites.name, outData: _miscOnlineSites);

    // _miscWeatherCities
    _miscWeatherCities.clear();
    _getSimpleCityInfoList(
        key: _UserDataKey.miscWeatherCities.name, outData: _miscWeatherCities);
  }

  ///
  /// getSimpleUrlInfoList
  ///
  void _getSimpleUrlInfoList(
      {required String key, required List<SimpleUrlInfo> outData}) async {
    String savedValue = await _preferences.getString(key);
    savedValue =
        savedValue.isEmpty ? '{"$_kDefaultListValueKey":[]}' : savedValue;

    final jsonData = await json.decode(savedValue);
    final parsed = jsonData[_kDefaultListValueKey] as List<dynamic>?;
    final list =
        parsed?.map((elem) => SimpleUrlInfoSummary.fromJson(elem)).toList() ??
            [];
    if (outData.isEmpty && list.isNotEmpty) {
      List.filled(list.length, SimpleUrlInfo());
    }
    list.asMap().forEach((idx, value) {
      list.asMap().forEach((idx, value) {
        outData[idx].title = value.title;
        outData[idx].urlString = value.urlString;
      });
    });
  }

  ///
  /// getSimpleCityInfoList
  ///
  void _getSimpleCityInfoList(
      {required String key, required List<SimpleCityInfo> outData}) async {
    String savedValue = await _preferences.getString(key);
    savedValue =
        savedValue.isEmpty ? '{"$_kDefaultListValueKey":[]}' : savedValue;

    final jsonData = await json.decode(savedValue);
    final parsed = jsonData[_kDefaultListValueKey] as List<dynamic>?;
    final list =
        parsed?.map((elem) => SimpleCityInfoSummary.fromJson(elem)).toList() ??
            [];
    if (outData.isEmpty && list.isNotEmpty) {
      List.filled(list.length, SimpleCityInfo());
    }
    list.asMap().forEach((idx, value) {
      list.asMap().forEach((idx, value) {
        outData[idx].name = value.name;
        outData[idx].langCode = value.langCode;
        outData[idx].countryCode = value.countryCode;
      });
    });
  }

  ///
  /// saveSimpleUrlInfoList
  ///
  void saveSimpleUrlInfoList(
      {required List<SimpleUrlInfo> newValue,
      required String key,
      required List<SimpleUrlInfo> targetData}) {
    targetData.clear();
    targetData.addAll(newValue);

    final jsonData = newValue.map((elem) => elem.toJson()).toList();
    final encoded = jsonEncode(jsonData);

    _preferences.setString(key, encoded).then((succeeded) {
      if (!succeeded) {
        log.warning('Cannot save $key info SharedPref!');
      }
    });
  }

  ///
  /// saveSimpleUrlInfoList
  ///
  void saveSimpleCityInfoList(
      {required List<SimpleCityInfo> newValue,
      required String key,
      required List<SimpleCityInfo> targetData}) {
    targetData.clear();
    targetData.addAll(newValue);

    final jsonData = newValue.map((elem) => elem.toJson()).toList();
    final encoded = jsonEncode(jsonData);

    _preferences.setString(key, encoded).then((succeeded) {
      if (!succeeded) {
        log.warning('Cannot save $key info SharedPref!');
      }
    });
  }
}
