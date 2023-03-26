import 'dart:convert';
import 'dart:io';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';

enum _UserDataKey {
  miscMyTimes,
  miscOnlineSites,
  miscWeatherCities,
  miscHistory,
  miscFavorites,
  commentMenuSetting,
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
      case _UserDataKey.miscHistory:
        return 'misc_history';
      case _UserDataKey.miscFavorites:
        return 'misc_favorites';
      case _UserDataKey.commentMenuSetting:
        return 'comment_menu_setting';
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
  final List<CityInfo> _miscWeatherCities = [];
  final List<String> _miscHistorioList = [];
  final List<String> _miscFavoritesList = [];

  final EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();

  List<SimpleUrlInfo> get miscMyTimes => _miscMyTimes;
  List<SimpleUrlInfo> get miscOnlineSites => _miscOnlineSites;
  List<CityInfo> get miscWeatherCities => _miscWeatherCities;
  List<String> get miscHistorioList => _miscHistorioList;
  List<String> get miscFavoritesList => _miscFavoritesList;
  Future<CommentMenuSetting?> get commentMenuSetting async {
    String savedValue =
        await _preferences.getString(_UserDataKey.commentMenuSetting.name);
    if (savedValue.isEmpty) {
      return null;
    }
    final jsonData = await json.decode(savedValue);
    return jsonData != null
        ? CommentMenuSettingDescript.fromJson(jsonData)
        : null;
  }

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
    _getCityInfoList(
        key: _UserDataKey.miscWeatherCities.name, outData: _miscWeatherCities);

    // _miscHistorioList
    _miscHistorioList.clear();
    _getHistorioList(
        key: _UserDataKey.miscHistory.name, outData: _miscHistorioList);

    // _miscFavoritesList
    _miscFavoritesList.clear();
    _getHistorioList(
        key: _UserDataKey.miscFavorites.name, outData: _miscFavoritesList);
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
    final parsed = jsonData[_kDefaultListValueKey] as List?;
    final list =
        parsed?.map((elem) => SimpleUrlInfoDescript.fromJson(elem)).toList() ??
            [];

    // set result
    list.asMap().forEach((idx, value) {
      if (list.length > outData.length) {
        outData
            .add(SimpleUrlInfo(title: value.title, urlString: value.urlString));
      } else {
        outData[idx].title = value.title;
        outData[idx].urlString = value.urlString;
      }
    });
  }

  ///
  /// getCityInfoList
  ///
  void _getCityInfoList(
      {required String key, required List<CityInfo> outData}) async {
    String savedValue = await _preferences.getString(key);
    savedValue =
        savedValue.isEmpty ? '{"$_kDefaultListValueKey":[]}' : savedValue;

    final jsonData = await json.decode(savedValue);
    final parsed = jsonData[_kDefaultListValueKey] as List?;
    final list =
        parsed?.map((elem) => CityInfoDescript.fromJson(elem)).toList() ?? [];
    list.asMap().forEach((idx, value) {
      outData.add(value);
    });
  }

  ///
  /// _getHistorioList
  ///
  void _getHistorioList(
      {required String key, required List<String> outData}) async {
    String savedValue = await _preferences.getString(key);
    if (savedValue.isEmpty) {
      return;
    }
    savedValue =
        savedValue.isEmpty ? '{"$_kDefaultListValueKey":[]}' : savedValue;

    Codec<String, String> codec = utf8.fuse(base64);
    final decoded = codec.decode(savedValue);
    final jsonData = json.decode(decoded);
    final parsed = jsonData[_kDefaultListValueKey] as List?;
    final list = parsed?.map((elem) => elem).toList() ?? [];
    list.asMap().forEach((idx, value) {
      outData.add(value);
    });
  }

  ///
  /// saveUserInfoList
  ///
  bool saveUserInfoList(
      {required dynamic newValue,
      required int order,
      bool allowsRemove = false,
      required ServiceType serviceType}) {
    String key;

    bool saveIfNeedProc_(dynamic value, List<dynamic> list, bool removed,
        int index, String key) {
      if (removed && index < list.length) {
        list.removeAt(index);
        return true;
      }
      if (value is SimpleUrlInfo) {
        if (SimpleUrlInfoDescript.isInList(
            element: newValue, list: list as List<SimpleUrlInfo>)) {
          return false;
        }
      } else if (value is CityInfo) {
        if (CityInfoDescript.isInList(
            element: newValue, list: list as List<CityInfo>)) {
          return false;
        }
      }
      if (index == -1) {
        list.add(value);
      } else {
        list[index] = value;
      }
      return true;
    }

    bool retVal = false;
    switch (serviceType) {
      case ServiceType.time:
        key = 'misc_my_times';
        retVal =
            saveIfNeedProc_(newValue, _miscMyTimes, allowsRemove, order, key);
        if (retVal) {
          _saveSimpleUrlInfoList(newValues: _miscMyTimes, key: key);
        }
        break;
      case ServiceType.audio:
        key = 'misc_online_sites';
        retVal = saveIfNeedProc_(
            newValue, _miscOnlineSites, allowsRemove, order, key);
        if (retVal) {
          _saveSimpleUrlInfoList(newValues: _miscOnlineSites, key: key);
        }
        break;
      case ServiceType.weather:
        key = 'misc_weather_cities';
        retVal = saveIfNeedProc_(
            newValue, _miscWeatherCities, allowsRemove, order, key);
        if (retVal) {
          _saveCityInfoList(newValues: _miscWeatherCities, key: key);
        }
        break;
      default:
        break;
    }
    return retVal;
  }

  ///
  /// insertHistorio
  ///
  void insertHistorio(
      {required String historio, String? url, String? htmlText}) {
    if (_miscHistorioList.contains(historio)) {
      return;
    } else if (url != null &&
        _miscHistorioList
            .firstWhere((element) => element.contains(url), orElse: () => '')
            .isNotEmpty) {
      return;
    }

    // save file
    _getDataPath(key: _UserDataKey.miscHistory.name).then((path) {
      // encode
      Codec<String, String> codec = utf8.fuse(base64);
      final encoded = codec.encode(htmlText ?? '');
      // save
      File file = File('$path/${url.hashCode}');
      file.writeAsBytes(encoded.codeUnits);
    });

    // save list
    _miscHistorioList.insert(0, historio);
    _saveHistorioList(
        newValues: _miscHistorioList, key: _UserDataKey.miscHistory.name);
  }

  ///
  /// removeHistorio
  ///
  void removeHistorio({required String url}) {
    int foundIndex = -1;
    if (url.isNotEmpty) {
      foundIndex =
          _miscHistorioList.indexWhere((element) => element.contains(url));
    }
    if (foundIndex >= 0) {
      _miscHistorioList.removeAt(foundIndex);
      // delete file
      _getDataPath(key: _UserDataKey.miscHistory.name).then((path) {
        File file = File('$path/${url.hashCode}');
        file.delete();
      });
    }

    // save list
    _saveHistorioList(
        newValues: _miscHistorioList, key: _UserDataKey.miscHistory.name);
  }

  ///
  /// readHistorioData
  ///
  Future<String> readHistorioData({required String url}) async {
    String path = await _getDataPath(key: _UserDataKey.miscHistory.name);
    String filename = '$path/${url.hashCode}';
    File file = File(filename);
    if (await file.exists()) {
      final str = file.readAsStringSync();

      // decode
      Codec<String, String> codec = utf8.fuse(base64);
      return codec.decode(str);
    }
    return '';
  }

  ///
  /// readFavoriteData
  ///
  Future<String> readFavoriteData({required String url}) async {
    String path = await _getDataPath(key: _UserDataKey.miscFavorites.name);
    String filename = '$path/${url.hashCode}';
    File file = File(filename);
    if (await file.exists()) {
      final str = file.readAsStringSync();

      // decode
      Codec<String, String> codec = utf8.fuse(base64);
      return codec.decode(str);
    }
    return '';
  }

  ///
  /// saveFavorites
  ///
  void saveFavorites(
      {required String bookmark,
      bool bookmarkIsOn = false,
      String? url,
      String? htmlText}) {
    int foundIndex = -1;
    if (url != null) {
      foundIndex =
          _miscFavoritesList.indexWhere((element) => element.contains(url));
    }
    if (foundIndex >= 0) {
      _miscFavoritesList.removeAt(foundIndex);
      // delete file
      _getDataPath(key: _UserDataKey.miscFavorites.name).then((path) {
        File file = File('$path/${url.hashCode}');
        file.delete();
      });
    }
    // save bookmark if isOn = true
    if (bookmarkIsOn) {
      if (_miscFavoritesList.isEmpty) {
        _miscFavoritesList.add(bookmark);
      } else {
        _miscFavoritesList.insert(0, bookmark);
      }
    }

    // save file
    if ((htmlText ?? '').isNotEmpty) {
      _getDataPath(key: _UserDataKey.miscFavorites.name).then((path) {
        // encode
        Codec<String, String> codec = utf8.fuse(base64);
        final encoded = codec.encode(htmlText ?? '');
        // save
        File file = File('$path/${url.hashCode}');
        file.writeAsBytes(encoded.codeUnits);
      });
    }

    // save list
    _saveHistorioList(
        newValues: _miscFavoritesList, key: _UserDataKey.miscFavorites.name);
  }

  ///
  /// saveCommentMenuSetting
  ///
  void saveCommentMenuSetting({required CommentMenuSetting newValue}) {
    String key = _UserDataKey.commentMenuSetting.name;
    final encoded = jsonEncode(newValue.toJson());

    _preferences
        .setString(_UserDataKey.commentMenuSetting.name, encoded)
        .then((succeeded) {
      if (!succeeded) {
        log.warning('Cannot save $key info SharedPref!');
      }
    });
  }

  ///
  /// saveSimpleUrlInfoList
  ///
  void _saveSimpleUrlInfoList(
      {required List<SimpleUrlInfo> newValues, required String key}) {
    final jsonList = newValues.map((elem) => elem.toJson()).toList();
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData[_kDefaultListValueKey] = jsonList;
    final encoded = jsonEncode(jsonData);

    _preferences.setString(key, encoded).then((succeeded) {
      if (!succeeded) {
        log.warning('Cannot save $key info SharedPref!');
      }
    });
  }

  ///
  /// _saveHistorioList
  ///
  void _saveHistorioList(
      {required List<String> newValues, required String key}) {
    final jsonList = newValues;
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData[_kDefaultListValueKey] = jsonList;
    final encoded = jsonEncode(jsonData);
    Codec<String, String> codec = utf8.fuse(base64);
    final encoded2 = codec.encode(encoded);

    _preferences.setString(key, encoded2).then((succeeded) {
      if (!succeeded) {
        log.warning('Cannot save $key info SharedPref!');
      }
    });
  }

  ///
  /// _saveCityInfoList
  ///
  void _saveCityInfoList(
      {required List<CityInfo> newValues, required String key}) {
    final jsonList = newValues.map((elem) => elem.toJson()).toList();
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData[_kDefaultListValueKey] = jsonList;
    final encoded = jsonEncode(jsonData);

    _preferences.setString(key, encoded).then((succeeded) {
      if (!succeeded) {
        log.warning('Cannot save $key info SharedPref!');
      }
    });
  }

  ///
  /// _saveCityInfoList
  ///
  Future<String> _getDataPath({required String key}) async {
    final tempDic = await getApplicationDocumentsDirectory();
    final filePathName = '${tempDic.path}/$key';
    Directory dir = Directory(filePathName);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return filePathName;
  }
}
