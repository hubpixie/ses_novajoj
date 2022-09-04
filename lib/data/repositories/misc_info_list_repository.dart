import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/weather_web_api.dart';
import 'package:ses_novajoj/networking/response/weather_item_response.dart';
import 'package:ses_novajoj/networking/request/weather_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/misc_info_list_item.dart';
import 'package:ses_novajoj/domain/entities/weather_data_item.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';
import 'package:ses_novajoj/foundation/log_util.dart';

/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

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
    final miscMyTimes = UserData().miscMyTimes;
    final miscMyOnlineSites = UserData().miscOnlineSites;
    List<SimpleCityInfo> miscWeatherCities = () {
      final ret = UserData().miscWeatherCities;
      if (ret.isEmpty) {
        ret.add(_getLocalCityInfo());
      }
      return ret;
    }();

    // make return value
    List<MiscInfoListItem> data = await () async {
      List<MiscInfoListItem> ret = [];
      int id = 0;

      // My Time
      for (int idx = 0; idx < miscMyTimes.length; idx++) {
        ret.add(
          MiscInfoListItem(
              itemInfo: NovaItemInfo(
                  id: id + idx,
                  urlString: miscMyTimes[idx].urlString,
                  title: miscMyTimes[idx].title,
                  createAt: DateTime.now(),
                  serviceType: ServiceType.time,
                  orderIndex: idx)),
        );
      }

      // My Audio
      id = miscMyTimes.length;
      for (int idx = 0; idx < miscMyOnlineSites.length; idx++) {
        ret.add(
          MiscInfoListItem(
              itemInfo: NovaItemInfo(
                  id: id + idx,
                  urlString: miscMyOnlineSites[idx].urlString,
                  title: miscMyOnlineSites[idx].title,
                  createAt: DateTime.now(),
                  serviceType: ServiceType.audio,
                  orderIndex: idx)),
        );
      }

      // weather
      id += miscMyOnlineSites.length;
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
            orderIndex: 0,
          )),
        );
      }
      return ret;
    }();
    Result<List<MiscInfoListItem>> result = Result.success(data: data);
    return result;
  }

  ///
  /// fetch weather data using Weather API
  ///
  Future<WeatherDataItem?> _fetchWeatherData(
      SimpleCityInfo simpleCityInfo) async {
    WeatherDataItem? ret;
    WeatherItemParamter paramter = WeatherItemParamter();
    paramter.cityParam = CityInfo();
    paramter.cityParam?.langCode = simpleCityInfo.langCode;
    paramter.cityParam?.countryCode = simpleCityInfo.countryCode;
    Result<WeatherItemRes> result =
        await _api.getWeatherData(paramter: paramter);
    result.when(success: (value) {
      ret = WeatherDataItem.copy(from: value);
      ret?.city?.name = simpleCityInfo.name;
      ret?.city?.langCode = simpleCityInfo.langCode;
      ret?.city?.countryCode = simpleCityInfo.countryCode;
    }, failure: (error) {
      log.info('Get weather errors occured: $error');
    });
    return ret;
  }

  ///
  /// get local city info using timezone
  ///
  SimpleCityInfo _getLocalCityInfo() {
    final duration = DateTime.now().timeZoneOffset;
    String hourOffset = '';
    if (duration.isNegative) {
      hourOffset =
          ("-${duration.inHours.abs().toString()}:${(duration.inMinutes.abs() - (duration.inHours.abs() * 60)).toString().padLeft(2, '0')}");
    } else {
      hourOffset =
          ("+${duration.inHours.toString()}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    }
    switch (hourOffset) {
      case '-10:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Hawaii');
      case '-5:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Sao Paulo');
      case '+0:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'London');
      case '+1:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Paris');
      case '+3:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Moscow');
      case '+6:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Urumqi');
      case '+8:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Beijing');
      case '+9:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Tokyo');
      case '+10:00':
        return SimpleCityInfoDescript.asCurrentLocale(name: 'Sydney');
      default:
        return SimpleCityInfoDescript.asCurrentLocale(name: 'New York');
    }
  }
}
