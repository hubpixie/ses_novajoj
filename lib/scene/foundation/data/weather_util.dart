import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';

/// Exposes specific weather icons
/// https://openweathermap.org/weather-conditions
// hex values and ttf file from https://erikflowers.github.io/weather-icons/
class WeatherIcons {
  static const IconData clearDay = _IconData(0xf00d);
  static const IconData clearNight = _IconData(0xf02e);

  static const IconData fewCloudsDay = _IconData(0xf002);
  static const IconData fewCloudsNight = _IconData(0xf081);

  static const IconData cloudsDay = _IconData(0xf07d);
  static const IconData cloudsNight = _IconData(0xf080);

  static const IconData showerRainDay = _IconData(0xf009);
  static const IconData showerRainNight = _IconData(0xf029);

  static const IconData rainDay = _IconData(0xf008);
  static const IconData rainNight = _IconData(0xf028);

  static const IconData thunderStormDay = _IconData(0xf010);
  static const IconData thunderStormNight = _IconData(0xf03b);

  static const IconData snowDay = _IconData(0xf00a);
  static const IconData snowNight = _IconData(0xf02a);

  static const IconData mistDay = _IconData(0xf003);
  static const IconData mistNight = _IconData(0xf04a);
}

class _IconData extends IconData {
  const _IconData(int codePoint)
      : super(
          codePoint,
          fontFamily: 'WeatherIcons',
        );
}

enum _WindDirection {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest
}

class WeatherUtil {
  static final WeatherUtil _instance = WeatherUtil._internal();
  factory WeatherUtil() {
    return _instance;
  }
  WeatherUtil._internal();

  String getPrecipLabel({double? rain, double? snow}) {
    String ret = '';
    if (rain != null) {
      ret = '降水';
    } else if (snow != null) {
      ret = '降雪';
    }
    return ret;
  }

  String getPrecipValue({double? rain, double? snow}) {
    String ret = '';
    if (rain != null) {
      ret = '$rain mm';
    } else if (snow != null) {
      ret = '$snow cm';
    }
    return ret;
  }

  String getWindDirectionValue({double? degree, String? langCode}) {
    double deg = (dynamic value) {
      if (value == null) return 0;
      return value + 22.5 >= 360 ? value + 22.5 - 360 : value + 22.5;
    }(degree);
    int directNum = (deg / 45).floor();
    _WindDirection direct = _WindDirection.values[directNum];

    String langCd = langCode ?? StringUtil().getDefaultLangCode();
    int langIdx = ['en', 'zh', 'ja'].lastIndexOf(langCd);
    langIdx = langIdx < 0 ? 0 : langIdx;

    String values = (_WindDirection dir) {
      switch (dir) {
        case _WindDirection.north:
          return 'North,北,北';
        case _WindDirection.northEast:
          return 'North East,东北,北東';
        case _WindDirection.east:
          return 'East,东,東';
        case _WindDirection.southEast:
          return 'South East,东南,南東';
        case _WindDirection.south:
          return 'South,南,南';
        case _WindDirection.southWest:
          return 'South West,西南,南西';
        case _WindDirection.west:
          return 'West,西,西';
        case _WindDirection.northWest:
          return 'North West,西北,北西';
        default:
          return '';
      }
    }(direct);
    final arr = values.split(',');
    return arr.isEmpty ? '' : arr[langIdx];
  }

  String getWeatherDesc({int? weatherId, String? langCode}) {
    String langCd = langCode ?? StringUtil().getDefaultLangCode();
    int langIdx = ['en', 'zh', 'ja'].lastIndexOf(langCd);
    langIdx = langIdx < 0 ? 0 : langIdx;

    String values = (int? id) {
      switch (id) {
        case 200:
          return 'thunderstorm with light rain,小雨伴有雷雨，小雨で雷を伴う';
        case 201:
          return 'thunderstorm with rain,中雨伴有雷雨,雨で雷を伴う';
        case 202:
          return 'thunderstorm with heavy rain,大雨伴有雷雨,強い雨で雷を伴う';
        case 210:
          return 'light thunderstorm,小雷雨,雷';
        case 211:
          return 'thunderstorm,雷雨,雷雨';
        case 212:
          return 'heavy thunderstorm,强雷雨,強い雷雨';
        case 221:
          return 'ragged thunderstorm,局部伴有雷雨,局地的雷雨';
        case 230:
          return 'thunderstorm with light drizzle,小细雨伴有雷,薄い霧で雷を伴う';
        case 231:
          return 'thunderstorm with drizzle,细雨伴有雷,霧雨で雷を伴う';
        case 232:
          return 'thunderstorm with heavy drizzle,绵绵细雨伴有雷，濃い霧雨で雷を伴う';
        case 300:
          return 'light intensity drizzle,烟霞,もや';
        case 301:
          return 'drizzle,细雨,霧雨';
        case 302:
          return 'heavy intensity drizzle,强细雨,重い強度霧雨';
        case 310:
          return 'light intensity drizzle rain,小细雨,霧雨';
        case 311:
          return 'drizzle rain,小雨,小雨';
        case 312:
          return 'heavy intensity drizzle rain,中雨伴有强细雨,濃霧の伴う雨';
        case 313:
          return 'shower rain and drizzle,小雨局部有阵雨,霧所によりにわか雨';
        case 314:
          return 'heavy shower rain and drizzle,小雨局部有强阵雨,霧所により強いにわか雨';
        case 321:
          return 'shower drizzle,小阵雨,にわか霧';
        case 500:
          return 'light rain,小雨,小雨';
        case 501:
          return 'moderate rain,雨，適度な雨';
        case 502:
          return 'heavy intensity rain,强降雨,重い強度の雨';
        case 503:
          return 'very heavy rain,极强降雨,非常に激しい雨';
        case 504:
          return 'extreme rain.暴雨,激しい雨';
        case 511:
          return 'freezing rain,冻雨,冷たい雨';
        case 520:
          return 'light intensity shower rain,小阵雨，時々小雨';
        case 521:
          return 'shower rain,阵雨,にわか雨';
        case 522:
          return 'heavy intensity shower rain,强阵雨,強いにわか雨';
        case 531:
          return 'ragged shower rain,局地阵雨,局地的にわか雨';
        case 600:
          return 'light snow,小雪,小雪';
        case 601:
          return 'snow,雪,雪';
        case 602:
          return 'heavy snow,大雪,大雪';
        case 611:
          return 'sleet,雨雪,みぞれ';
        case 612:
          return 'shower sleet,雨雪交加,にわかみぞれ';
        case 615:
          return 'light rain and snow,小雨局地有雪,小雨所により雪';
        case 616:
          return 'rain and snow,雨局地有雪,雨所により雪';
        case 620:
          return 'light shower snow,小阵雪,にわか小雪';
        case 621:
          return 'shower snow,阵雪,にわか雪';
        case 622:
          return 'heavy shower snow,强阵雪,強いにわか雪';
        case 701:
          return 'mist,薄雾,霧';
        case 711:
          return 'smoke,雾霾,スモック';
        case 721:
          return 'haze,烟雾,ヘイズ';
        case 731:
          return 'dust whirls;沙尘暴,砂嵐';
        case 741:
          return 'fog,雾,霧';
        case 751:
          return 'sand,黄沙,黄砂';
        case 761:
          return 'dust,粉尘,ほこり';
        case 762:
          return 'volcanic ash,火山灰,火山灰';
        case 771:
          return 'squalls,雨(雪)飑,スコール';
        case 781:
          return 'tornado,龙卷风,竜巻';
        case 800:
          return 'clear sky,晴,晴れ';
        case 801:
          return 'few clouds,晴间阴,晴れ所により曇り';
        case 802:
          return 'scattered clouds,阴间晴,曇り所により晴れ';
        case 803:
          return 'broken clouds,多云转晴,曇り時々晴れ';
        case 804:
          return 'overcast clouds,阴,曇り';
        case 900:
          return 'tornado,龙卷风,竜巻';
        case 901:
          return 'tropical storm,热带暴风雨,台風';
        case 902:
          return 'hurricane,飓风,ハリケーン';
        case 903:
          return 'cold,寒气,寒気';
        case 904:
          return 'hot,热气,暖気';
        case 905:
          return 'windy,大风,強風';
        case 906:
          return 'hail,冰雹,ひょう';
        case 951:
          return 'calm,无风,無風';
        case 952:
          return 'light breeze,微风,微風';
        case 953:
          return 'gentle breeze,微风,そよ風';
        case 954:
          return 'moderate breeze,和风,弱い風';
        case 955:
          return 'fresh breeze,较强风,やや強い風';
        case 956:
          return 'strong breeze,强风,強風';
        case 957:
          return 'near gale,超强风,非常に強い風';
        case 958:
          return 'gale,大风,強風注意報';
        case 959:
          return 'severe gale,超大风,海上風警報';
        case 960:
          return 'storm,风暴,強風警報';
        case 961:
          return 'violent storm,超强风暴,暴風警報';
        case 962:
          return 'hurricane,飓风,特別暴風警報';
        default:
          return '';
      }
    }(weatherId);
    final arr = values.split(',');
    return arr.isEmpty ? '' : arr[langIdx];
  }

  IconData getIconData(String? iconCode) {
    switch (iconCode) {
      case '01d':
        return WeatherIcons.clearDay;
      case '01n':
        return WeatherIcons.clearNight;
      case '02d':
        return WeatherIcons.fewCloudsDay;
      case '02n':
        return WeatherIcons.fewCloudsDay;
      case '03d':
      case '04d':
        return WeatherIcons.cloudsDay;
      case '03n':
      case '04n':
        return WeatherIcons.clearNight;
      case '09d':
        return WeatherIcons.showerRainDay;
      case '09n':
        return WeatherIcons.showerRainNight;
      case '10d':
        return WeatherIcons.rainDay;
      case '10n':
        return WeatherIcons.rainNight;
      case '11d':
        return WeatherIcons.thunderStormDay;
      case '11n':
        return WeatherIcons.thunderStormNight;
      case '13d':
        return WeatherIcons.snowDay;
      case '13n':
        return WeatherIcons.snowNight;
      case '50d':
        return WeatherIcons.mistDay;
      case '50n':
        return WeatherIcons.mistNight;
      default:
        return WeatherIcons.clearDay;
    }
  }
}

extension WeatherInfoEx on WeatherInfo {
  bool get hasPrecit => rain != null || snow != null;
  String getSunsetFormattedString() => DateUtil()
      .getHMMString(timestamp: sunset ?? 0, timezone: city?.timezone ?? 0);
  String getSunriseFormattedString() => DateUtil()
      .getHMMString(timestamp: sunrise ?? 0, timezone: city?.timezone ?? 0);
  String getTimeFormattedString() => DateUtil()
      .getHMMString(timestamp: time ?? 0, timezone: city?.timezone ?? 0);
  String getDataFormattedString() => DateUtil().getDateMDEStringWithTimestamp(
      timestamp: time ?? 0, timezone: city?.timezone ?? 0);
  String getWeatherDesc() => WeatherUtil().getWeatherDesc(weatherId: id ?? 0);
  String getPrecipLabel() =>
      WeatherUtil().getPrecipLabel(rain: rain ?? 0, snow: snow ?? 0);
  String getPrecipValue() =>
      WeatherUtil().getPrecipValue(rain: rain ?? 0, snow: snow ?? 0);
  String getWindDirectionValue() =>
      WeatherUtil().getWindDirectionValue(degree: windDeg ?? 0);
  IconData getIconData() => WeatherUtil().getIconData(iconCode ?? '');
}
