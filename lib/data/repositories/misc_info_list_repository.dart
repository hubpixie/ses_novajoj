import 'dart:convert';

import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/weather_web_api.dart';
import 'package:ses_novajoj/networking/response/historio_item_response.dart';
import 'package:ses_novajoj/networking/response/weather_item_response.dart';
import 'package:ses_novajoj/networking/request/weather_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/misc_info_list_item.dart';
import 'package:ses_novajoj/domain/entities/weather_data_item.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';
import 'package:ses_novajoj/foundation/log_util.dart';

class MiscInfoListRepositoryImpl extends MiscInfoListRepository {
  final WeatherWebApi _api;

  // sigleton
  static final MiscInfoListRepositoryImpl _instance =
      MiscInfoListRepositoryImpl._internal();
  MiscInfoListRepositoryImpl._internal() : _api = WeatherWebApi();
  factory MiscInfoListRepositoryImpl() => _instance;

  @override
  Future<Result<List<MiscInfoListItem>>> fetchMiscInfoList(
      {required FetchMiscInfoListRepoInput input}) async {
    // prepare to get pref data
    List<SimpleUrlInfo> miscMyTimes = UserData().miscMyTimes;
    List<SimpleUrlInfo> miscMyOnlineSites = UserData().miscOnlineSites;
    List<CityInfo> miscWeatherCities = () {
      final ret = UserData().miscWeatherCities;
      if (ret.isEmpty) {
        ret.add(_getLocalCityInfo());
      }
      return ret;
    }();
    List<HistorioInfo> miscHistorioList = _getHistorioList();

    // make return value
    List<MiscInfoListItem> data = await () async {
      List<MiscInfoListItem> ret = [];
      int id = 0;
      int orderIndex = 0;

      // My Time
      for (int idx = 0; idx < miscMyTimes.length; idx++) {
        orderIndex = idx;
        ret.add(
          MiscInfoListItem(
              itemInfo: NovaItemInfo(
                  id: id + idx,
                  urlString: miscMyTimes[idx].urlString,
                  title: miscMyTimes[idx].title,
                  createAt: DateTime.now(),
                  serviceType: ServiceType.time,
                  orderIndex: orderIndex)),
        );
      }

      // My Audio
      id = miscMyTimes.length;
      for (int idx = 0; idx < miscMyOnlineSites.length; idx++) {
        orderIndex = idx;
        ret.add(
          MiscInfoListItem(
              itemInfo: NovaItemInfo(
                  id: id + idx,
                  urlString: miscMyOnlineSites[idx].urlString,
                  title: miscMyOnlineSites[idx].title,
                  createAt: DateTime.now(),
                  serviceType: ServiceType.audio,
                  orderIndex: orderIndex)),
        );
      }

      // weather
      id += miscMyOnlineSites.length;
      orderIndex = 0;
      for (int idx = 0; idx < miscWeatherCities.length; idx++) {
        final weaterData = await _fetchWeatherData(miscWeatherCities[idx]);
        if (weaterData == null) {
          continue;
        }
        ret.add(
          MiscInfoListItem(
              itemInfo: NovaItemInfo(
            id: id,
            urlString: 'http://',
            title: 'Weather',
            createAt: DateTime.now(),
            serviceType: ServiceType.weather,
            weatherInfo: weaterData,
            orderIndex: orderIndex++,
          )),
        );
      }
      // history
      id = 0;
      orderIndex = 0;
      for (int idx = 0; idx < miscHistorioList.length; idx++) {
        ret.add(MiscInfoListItem(
            itemInfo: NovaItemInfo(
              id: id,
              urlString: 'http://',
              title: 'Weather',
              createAt: DateTime.now(),
              serviceType: ServiceType.none,
              orderIndex: orderIndex++,
            ),
            hisInfo: miscHistorioList[idx]));
      }

      return ret;
    }();

    Result<List<MiscInfoListItem>> result = Result.success(data: data);
    return result;
  }

  ///
  /// fetch weather data using Weather API
  ///
  Future<WeatherDataItem?> _fetchWeatherData(CityInfo cityInfo) async {
    WeatherDataItem? ret;
    WeatherItemParameter paramter = WeatherItemParameter();
    paramter.cityParam = CityInfo();
    paramter.cityParam?.name = cityInfo.name;
    paramter.cityParam?.langCode = cityInfo.langCode;
    paramter.cityParam?.countryCode = cityInfo.countryCode;
    Result<WeatherItemRes> result =
        await _api.getWeatherData(paramter: paramter);
    result.when(success: (value) {
      ret = WeatherDataItem.copy(from: value);
      ret?.city?.name = cityInfo.name;
      ret?.city?.nameDesc = cityInfo.nameDesc;
      ret?.city?.state = cityInfo.state;
      ret?.city?.langCode = cityInfo.langCode;
      ret?.city?.countryCode = cityInfo.countryCode;
    }, failure: (error) {
      log.severe('Get weather errors occured: $error');
    });
    return ret;
  }

  ///
  /// get local city info using timezone
  ///
  CityInfo _getLocalCityInfo() {
    final duration = DateTime.now().timeZoneOffset;
    String hourOffset = '';
    if (duration.isNegative) {
      hourOffset =
          ("-${duration.inHours.abs().toString()}:${(duration.inMinutes.abs() - (duration.inHours.abs() * 60)).toString().padLeft(2, '0')}");
    } else {
      hourOffset =
          ("+${duration.inHours.toString()}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    }

    return () {
      switch (hourOffset) {
        case '-10:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Hawaii');
        case '-5:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Sao Paulo');
        case '+0:00':
          return CityInfoDescript.fromCurrentLocale(name: 'London');
        case '+1:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Paris');
        case '+3:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Moscow');
        case '+6:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Urumqi');
        case '+8:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Beijing');
        case '+9:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Tokyo');
        case '+10:00':
          return CityInfoDescript.fromCurrentLocale(name: 'Sydney');
        default:
          return CityInfoDescript.fromCurrentLocale(name: 'New York');
      }
    }();
  }

  List<HistorioInfo> _getHistorioList() {
    final historioStrings = UserData().miscHistorioList;
    List<HistorioInfo> list = historioStrings.map((elem) {
      final jsonData = json.decode(elem);
      HistorioItemRes itemRes = HistorioItemRes.fromJson(jsonData);
      return itemRes;
    }).toList();
    return list;
  }
}
