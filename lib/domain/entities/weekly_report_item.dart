import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';

class WeeklyReportItem extends WeatherInfo {
  List<WeatherInfo>? hourlyForecast;
  List<WeatherInfo>? weeklyForecast;
  // Internal members
  List<WeatherInfo>? _hourlyForecast;
  List<WeatherInfo>? _weeklyForecast;

  WeeklyReportItem.copy(
      {required WeatherInfo from, List<WeatherInfo>? newForecast}) {
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
    // forecast
    forecast = newForecast ?? from.forecast;
    _hourlyForecast =
        _makeHourlyForecastData(todayWeather: from, newForecast: newForecast);
    _weeklyForecast =
        _makeWeeklyForecastData(todayWeather: from, newForecast: newForecast);
    hourlyForecast = _hourlyForecast;
    weeklyForecast = _weeklyForecast;
  }

  WeeklyReportItem({
    this.hourlyForecast,
    this.weeklyForecast,
  });
  List<WeatherInfo> _makeHourlyForecastData(
      {required WeatherInfo todayWeather, List<WeatherInfo>? newForecast}) {
    if (newForecast != null) {
      List<WeatherInfo> data = newForecast;
      if (data.length >= 8) {
        List<WeatherInfo> ret = data.take(9).toList();
        for (int idx = 0; idx < ret.length; idx++) {
          ret[idx].city = todayWeather.city;
        }
        return ret;
      } else {
        return <WeatherInfo>[];
      }
    } else {
      return <WeatherInfo>[];
    }
  }

  List<WeatherInfo> _makeWeeklyForecastData(
      {required WeatherInfo todayWeather, List<WeatherInfo>? newForecast}) {
    if (newForecast != null) {
      List<WeatherInfo> data = newForecast;
      List<WeatherInfo> ret = <WeatherInfo>[];
      double maxTempForecast;
      double minTempForecast;

      if (data.isNotEmpty) {
        List<String> addedKeys = [];
        String lastDateKey = DateUtil().getDateMMDDStringWithTimestamp(
            timestamp: data.last.time,
            timezone: todayWeather.city?.timezone ?? 0);

        // decides the day keys for weekly report
        for (int i = 1; i <= 7; i++) {
          String dateKey = DateUtil().getDateMMDDStringWithTimestamp(
              timestamp: (todayWeather.time ?? 0) + i * 24 * 3600,
              timezone: todayWeather.city?.timezone ?? 0);
          if (dateKey.compareTo(lastDateKey) > 0) break;
          if (!addedKeys.contains(dateKey)) {
            addedKeys.add(dateKey);
          }
        }

        // get temperature's data during min day ~ max day
        for (int i = 0; i < addedKeys.length; i++) {
          final subData = data.where((element) {
            String dateKey = DateUtil().getDateMMDDStringWithTimestamp(
                timestamp: element.time,
                timezone: todayWeather.city?.timezone ?? 0);
            return dateKey == addedKeys[i];
          });
          // maxTempForecast, minTempForecast
          maxTempForecast = subData
              .map((e) => e.maxTemperature?.kelvin ?? 0)
              .reduce((curr, next) => curr > next ? curr : next);
          minTempForecast = subData
              .map((e) => e.minTemperature?.kelvin ?? 0)
              .reduce((curr, next) => curr < next ? curr : next);
          ret.add(subData.first);
          ret[ret.length - 1].maxTemperatureOfForecast =
              Temperature(maxTempForecast);
          ret[ret.length - 1].minTemperatureOfForecast =
              Temperature(minTempForecast);
          // City Info
          ret[ret.length - 1].city = todayWeather.city;
        }
        return ret;
      } else {
        return <WeatherInfo>[];
      }
    } else {
      return <WeatherInfo>[];
    }
  }
}
