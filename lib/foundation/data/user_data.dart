import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'package:uuid/uuid.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ses_novajoj/foundation/data/app_state.dart';
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

  final EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();
  final Uuid _uuid = const Uuid();

  Future<List<SimpleUrlInfo>> get miscMyTimes async {
    return _getSimpleUrlInfoList(key: _UserDataKey.miscMyTimes.name);
  }

  Future<List<SimpleUrlInfo>> get miscOnlineSites async {
    return _getSimpleUrlInfoList(key: _UserDataKey.miscOnlineSites.name);
  }

  Future<List<CityInfo>> get miscWeatherCities async {
    return _getCityInfoList(key: _UserDataKey.miscWeatherCities.name);
  }

  Future<List<String>> get miscHistorioList async {
    if (AppState.isHistorioEnabled) {
      return _getHistorioList(key: _UserDataKey.miscHistory.name);
    } else {
      return [];
    }
  }

  Future<List<String>> get miscFavoritesList async {
    return _getHistorioList(key: _UserDataKey.miscFavorites.name);
  }

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
  /// _getUuidFileName
  ///
  Future<String> _getUuidFileName({required String key}) async {
    String fileName = await _preferences.getString(key);
    if (fileName.isEmpty) {
      fileName = _uuid.v4();
      _preferences.setString(key, fileName);
    }
    return fileName;
  }

  ///
  /// getSimpleUrlInfoList
  ///
  Future<List<SimpleUrlInfo>> _getSimpleUrlInfoList(
      {required String key}) async {
    List<SimpleUrlInfo> outData = [];
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
    return outData;
  }

  ///
  /// getCityInfoList
  ///
  Future<List<CityInfo>> _getCityInfoList({required String key}) async {
    List<CityInfo> outData = [];
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
    return outData;
  }

  ///
  /// _getHistorioList
  ///
  Future<List<String>> _getHistorioList({required String key}) async {
    List<String> outData = [];
    // fileName
    String fileName = await _getUuidFileName(key: key);
    String path = await _getDataPath(key: key);
    String filePth = '$path/$fileName';

    // return empty list if no file
    File file = File(filePth);
    if (!(await file.exists())) {
      return [];
    }
    // read file content and parse
    String savedValue = await file.readAsString();
    if (savedValue.isEmpty) {
      return outData;
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
    return outData;
  }

  ///
  /// saveUserInfoList
  ///
  Future<bool> saveUserInfoList(
      {required dynamic newValue,
      required int order,
      bool allowsRemove = false,
      required ServiceType serviceType}) async {
    String key;
    final miscMyTimes =
        await _getSimpleUrlInfoList(key: _UserDataKey.miscMyTimes.name);
    final miscOnlineSites =
        await _getSimpleUrlInfoList(key: _UserDataKey.miscOnlineSites.name);
    final miscWeatherCities =
        await _getCityInfoList(key: _UserDataKey.miscWeatherCities.name);

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
      if (index == -1 || list.isEmpty) {
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
            saveIfNeedProc_(newValue, miscMyTimes, allowsRemove, order, key);
        if (retVal) {
          _saveSimpleUrlInfoList(newValues: miscMyTimes, key: key);
        }
        break;
      case ServiceType.audio:
        key = 'misc_online_sites';
        retVal = saveIfNeedProc_(
            newValue, miscOnlineSites, allowsRemove, order, key);
        if (retVal) {
          _saveSimpleUrlInfoList(newValues: miscOnlineSites, key: key);
        }
        break;
      case ServiceType.weather:
        key = 'misc_weather_cities';
        retVal = saveIfNeedProc_(
            newValue, miscWeatherCities, allowsRemove, order, key);
        if (retVal) {
          _saveCityInfoList(newValues: miscWeatherCities, key: key);
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
      {required String historio,
      String? url,
      String? innerUrl,
      String? htmlText,
      int index = 0}) async {
    if (!AppState.isHistorioEnabled) {
      return;
    }

    final hisList = await _getHistorioList(key: _UserDataKey.miscHistory.name);
    int fndIndex = -1;
    if (hisList.contains(historio)) {
      return;
    } else if (url != null && hisList.isNotEmpty) {
      fndIndex = hisList.indexWhere((element) => element.contains(url));
      if ((innerUrl != null && fndIndex < 0) ||
          (innerUrl == null && fndIndex >= 0)) {
        return;
      }
    }

    // save file
    _getDataPath(
            key: _UserDataKey.miscHistory.name,
            subKey: innerUrl == null ? '' : '${url.hashCode}')
        .then((path) {
      // encode
      Codec<String, String> codec = utf8.fuse(base64);
      final encoded = codec.encode(htmlText ?? '');
      // save
      File file;
      if (innerUrl == null) {
        file = File('$path/${url.hashCode}');
      } else {
        file = File('$path/${innerUrl.hashCode}');
      }
      file.writeAsBytes(encoded.codeUnits);
    });

    // save list
    if (innerUrl == null) {
      if (index < 0 || index > hisList.length) {
        hisList.add(historio);
      } else {
        hisList.insert(index, historio);
      }
    } else {
      hisList[fndIndex] = historio;
    }
    _saveHistorioList(newValues: hisList, key: _UserDataKey.miscHistory.name);
  }

  ///
  /// removeHistorio
  ///
  void removeHistorio({required String url}) async {
    int foundIndex = -1;
    final hisList = await _getHistorioList(key: _UserDataKey.miscHistory.name);
    if (url.isNotEmpty) {
      foundIndex = hisList.indexWhere((element) => element.contains(url));
    }
    if (foundIndex >= 0) {
      hisList.removeAt(foundIndex);
      // delete file
      _getDataPath(key: _UserDataKey.miscHistory.name).then((path) {
        Directory dir = Directory('$path/index${url.hashCode}');
        if (dir.existsSync()) {
          dir.delete(recursive: true);
          File file = File('$path/${url.hashCode}');
          file.delete();
        }
      });
    }

    // save list
    _saveHistorioList(newValues: hisList, key: _UserDataKey.miscHistory.name);
  }

  ///
  /// readHistorioData
  ///
  Future<String> readHistorioData(
      {required String url, String innerUrl = ''}) async {
    log.info('UserData: [url = $url]');
    String path = await _getDataPath(
        key: _UserDataKey.miscHistory.name,
        subKey: innerUrl.isEmpty ? '' : '${url.hashCode}');
    String filename = innerUrl.isEmpty
        ? '$path/${url.hashCode}'
        : '$path/${innerUrl.hashCode}';
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
  Future<String> readFavoriteData(
      {required String url, String innerUrl = ''}) async {
    log.info('UserData: [url = $url]');
    String path = await _getDataPath(
        key: _UserDataKey.miscFavorites.name,
        subKey: innerUrl.isEmpty ? '' : '${url.hashCode}');
    String filename = innerUrl.isEmpty
        ? '$path/${url.hashCode}'
        : '$path/${innerUrl.hashCode}';
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
      String? innerUrl,
      String? htmlText}) async {
    // copy subFlolder
    void copySubFolder(String destPath) {
      _getDataPath(key: _UserDataKey.miscHistory.name).then((sourcePath) {
        Directory dir = Directory('$sourcePath/index${url.hashCode}');
        Directory toDir = Directory('$destPath/index${url.hashCode}');
        // check if fromPath is existed
        if (dir.existsSync()) {
          // check if toPath is existed
          if (!toDir.existsSync()) {
            toDir.createSync(recursive: true);
          }
          // copy every file from source path to dest path.
          Directory(sourcePath).list(recursive: true).forEach((entity) {
            if (entity is File) {
              String toFilePath =
                  '${toDir.path}/${path_lib.basename(entity.path)}';
              entity.copy(toFilePath);
            }
          });
        }
      });
    }

    // find the target favorite item
    int foundIndex = -1;
    final favorList =
        await _getHistorioList(key: _UserDataKey.miscFavorites.name);
    if (url != null) {
      foundIndex = favorList.indexWhere((element) => element.contains(url));
    }
    if (foundIndex >= 0) {
      if (innerUrl == null || !bookmarkIsOn) {
        favorList.removeAt(foundIndex);
        // delete file
        _getDataPath(key: _UserDataKey.miscFavorites.name).then((path) {
          Directory dir = Directory('$path/index${url.hashCode}');
          if (dir.existsSync()) {
            dir.delete(recursive: true);
            File file = File('$path/${url.hashCode}');
            file.delete();
          }
        });
      }
    }
    // save bookmark if isOn = true
    if (bookmarkIsOn) {
      if (innerUrl == null) {
        if (favorList.isEmpty) {
          favorList.add(bookmark);
        } else {
          favorList.insert(0, bookmark);
        }
      } else {
        favorList[foundIndex] = bookmark;
      }
    }

    // save file
    if ((htmlText ?? '').isNotEmpty) {
      _getDataPath(
              key: _UserDataKey.miscFavorites.name,
              subKey: innerUrl == null ? '' : '${url.hashCode}')
          .then((path) {
        // encode
        Codec<String, String> codec = utf8.fuse(base64);
        final encoded = codec.encode(htmlText ?? '');
        // save
        File file;
        if (innerUrl == null) {
          file = File('$path/${url.hashCode}');
          // copy every file from source path to dest path.
          copySubFolder(path);
        } else {
          file = File('$path/${innerUrl.hashCode}');
        }
        file.writeAsBytes(encoded.codeUnits);
      });
    }

    // save list
    _saveHistorioList(
        newValues: favorList, key: _UserDataKey.miscFavorites.name);
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
      {required List<String> newValues, required String key}) async {
    // encode jsonData
    final jsonList = newValues;
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData[_kDefaultListValueKey] = jsonList;
    final encoded = jsonEncode(jsonData);
    Codec<String, String> codec = utf8.fuse(base64);
    final encoded2 = codec.encode(encoded);

    // save jsonData into fileName
    String fileName = await _getUuidFileName(key: key);
    String path = await _getDataPath(key: key);
    String filePth = '$path/$fileName';
    File(filePth).writeAsString(encoded2);
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
  Future<String> _getDataPath({required String key, String subKey = ''}) async {
    final tempDic = await getApplicationDocumentsDirectory();
    String filePathName = '${tempDic.path}/$key';
    Directory dir;
    dir = Directory(filePathName);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    if (subKey.isNotEmpty) {
      filePathName = '$filePathName/index$subKey';
      dir = Directory(filePathName);
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }
    }
    return filePathName;
  }
}
