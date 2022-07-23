import 'dart:convert';
import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/misc_info_list_item_response.dart';
// import 'package:ses_novajoj/networking/request/misc_info_list_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/weather_data_item.dart';
import 'package:ses_novajoj/domain/entities/misc_info_list_item.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class MiscInfoListRepositoryImpl extends MiscInfoListRepository {
  final MyWebApi _api;

  // sigleton
  static final MiscInfoListRepositoryImpl _instance =
      MiscInfoListRepositoryImpl._internal();
  MiscInfoListRepositoryImpl._internal() : _api = MyWebApi();
  factory MiscInfoListRepositoryImpl() => _instance;

  @override
  Future<Result<List<MiscInfoListItem>>> fetchMiscInfoList(
      {required FetchMiscInfoListRepoInput input}) async {
    String _json = '''
{"coord":{"lon":139.6917,"lat":35.6895},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"base":"stations","main":{"temp":300.52,"feels_like":303.96,"temp_min":299.12,"temp_max":301.28,"pressure":999,"humidity":82},"visibility":10000,"wind":{"speed":7.2,"deg":220},"clouds":{"all":75},"dt":1658236935,"sys":{"type":2,"id":2038398,"country":"JP","sunrise":1658173138,"sunset":1658224537},"timezone":32400,"id":1850144,"name":"Tokyo","cod":200}
''';
    var jsonData = await json.decode(_json);
    final weatherItem = WeatherDataItem.fromJson(jsonData);

    Result<List<MiscInfoListItem>> result = Result.success(data: [
      MiscInfoListItem(
          itemInfo: NovaItemInfo(
              id: 0,
              urlString: 'https://tms.kinnosuke.jp/',
              title: 'Kinnosuke',
              createAt: DateTime.now(),
              serviceType: ServiceType.time,
              orderIndex: 0)),
      MiscInfoListItem(
          itemInfo: NovaItemInfo(
              id: 1,
              urlString: 'https://www.spreaker.com/user/cock-radio',
              title: 'Hot Radio',
              createAt: DateTime.now(),
              serviceType: ServiceType.audio,
              orderIndex: 0)),
      MiscInfoListItem(
          itemInfo: NovaItemInfo(
              id: 2,
              urlString:
                  'https://www.afnpacific.net/Portals/101/360/AudioPlayer2.html#AFNP_OSN',
              title: 'Freely Listen',
              createAt: DateTime.now(),
              serviceType: ServiceType.audio,
              orderIndex: 1)),
      MiscInfoListItem(
          itemInfo: NovaItemInfo(
        id: 3,
        urlString: 'http://',
        title: 'Weather',
        createAt: DateTime.now(),
        serviceType: ServiceType.weather,
        weatherInfo:
            weatherItem /*WeatherInfo(
            city: CityInfo(countryCode: 'JP', name: 'Tokyo'),
            temperature: Temperature(24 + Temperature.kKelvin),
            iconCode: '01d')*/
        ,
        orderIndex: 0,
      )),
    ]);
    DateTime.now().timeZoneName;
    return result;
  }
}

/*
  int? id;
  int? time;
  int? sunrise;
  int? sunset;
  int? humidity;
  double? rain; //mm
  double? snow; //cm

  String? description;
  String? iconCode;
  String? main;
  CityInfo? city;

  double? windSpeed;
  double? windDeg;

  Temperature? feelsLike;
  Temperature? temperature;
  Temperature? maxTemperature;
  Temperature? minTemperature;
  Temperature? maxTemperatureOfForecast;
  Temperature? minTemperatureOfForecast;

  List<WeatherInfo>? forecast;

*/