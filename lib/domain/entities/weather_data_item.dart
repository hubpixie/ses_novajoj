import 'package:ses_novajoj/foundation/data/user_types.dart';

class WeatherDataItem extends WeatherInfo {
  WeatherDataItem.copy({required WeatherInfo from}) {
    id = from.id;
    time = from.time;
    sunrise = from.sunrise;
    sunset = from.sunset;
    humidity = from.humidity;

    rain = from.rain;
    snow = from.snow;

    windSpeed = from.windSpeed;
    windDeg = from.windDeg;

    description = from.description;
    iconCode = from.iconCode;
    main = from.main;
    city = from.city;

    feelsLike = from.feelsLike;
    temperature = from.temperature;
    maxTemperature = from.maxTemperature;
    minTemperature = from.minTemperature;
    maxTemperatureOfForecast = from.maxTemperatureOfForecast;
    minTemperatureOfForecast = from.minTemperatureOfForecast;
    forecast = from.forecast;
  }
}
