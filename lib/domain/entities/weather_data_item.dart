import 'package:ses_novajoj/foundation/data/user_types.dart';

class WeatherDataItem extends WeatherInfo {
  WeatherDataItem.fromJson(Map<String, dynamic> json, {String zip = ''}) {
    final weather = json['weather'].first;
    id = weather['id'];
    time = json['dt'];
    description = weather['description'];
    iconCode = weather['icon'];
    main = weather['main'];
    city = CityInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tokyo',
      //nameDesc: CityUtil().getCityNameDesc(name: json['name'] ?? ''),
      zip: zip,
      countryCode: json['sys']?['country'] ?? 'JP',
      timezone: json['timezone'] ?? 0,
    );
    feelsLike = Temperature(_toDouble(json['main']['feels_like']) ?? 0);
    temperature = Temperature(_toDouble(json['main']['temp']) ?? 0);
    maxTemperature = Temperature(_toDouble(json['main']['temp_max']) ?? 0);
    minTemperature = Temperature(_toDouble(json['main']['temp_min']) ?? 0);
    sunrise = json['sys']['sunrise'];
    sunset = json['sys']['sunset'];
    humidity = json['main']['humidity'];
    rain = json['rain'] != null ? _toDouble(json['rain']['3h']) : null;
    snow = json['snow'] != null ? _toDouble(json['snow']['3h']) : null;
    windSpeed = json['wind'] != null ? _toDouble(json['wind']['speed']) : null;
    windDeg = _toDouble(json['wind']['deg']);
  }

  WeatherDataItem.fromForecastJson(Map<String, dynamic> json) {
    forecast = () {
      final dsList = json['list'] as List?;
      return dsList != null
          ? dsList
              .map((element) => WeatherInfo(
                  time: element['dt'],
                  temperature: Temperature(
                    element['main']['temp'],
                  ),
                  iconCode: element['weather'][0]['icon']))
              .toList()
          : <WeatherInfo>[];
    }();
  }

  double? _toDouble(dynamic value) {
    double? ret;
    if (value == null) return null;
    if (value is double) {
      ret = value;
    } else if (value is int) {
      int n = value;
      ret = n.toDouble();
    }
    return ret;
  }
}
