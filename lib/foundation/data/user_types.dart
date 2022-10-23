import 'dart:io';

enum NovaDocType {
  none,
  list,
  table,
  thumb,
  detail,
  bbsList,
  bbsEtcList,
  bbsSelect,
  threadList
}

enum ServiceType {
  none,
  time,
  audio,
  weather,
  // favorite,
  // history,
}

class Comment {
  int id;
  String author;
  String createAt;
  String bodyHtmlString;

  Comment(
      {required this.id,
      required this.author,
      required this.createAt,
      required this.bodyHtmlString});
}

class NovaItemInfo {
  int id;
  ServiceType serviceType;
  String thunnailUrlString;
  String title;
  String urlString;
  String source;
  String author;
  DateTime createAt;
  int orderIndex;
  String loadCommentAt;
  List<Comment>? comments;
  String commentUrlString;
  int commentCount;
  int reads;
  bool isRead;
  bool isNew;
  List<NovaItemInfo>? children;
  WeatherInfo? weatherInfo;

  NovaItemInfo(
      {required this.id,
      this.serviceType = ServiceType.none,
      this.thunnailUrlString = '',
      required this.title,
      required this.urlString,
      this.source = '',
      this.author = '',
      required this.createAt,
      this.orderIndex = 0,
      this.loadCommentAt = '',
      this.commentUrlString = '',
      this.commentCount = 0,
      this.reads = 0,
      this.isRead = false,
      this.isNew = false,
      this.children,
      this.weatherInfo});
}

class HistorioInfo {
  late int id;
  late DateTime createdAt;
  late String category;
  late NovaItemInfo itemInfo;
  String? htmlText;
}

class SimpleUrlInfo {
  String title;
  String urlString;

  SimpleUrlInfo({this.title = '', this.urlString = ''});
  NovaItemInfo? toItemInfo(
      {int orderIndex = 0, ServiceType serviceType = ServiceType.none}) {
    return NovaItemInfo(
        id: 0,
        orderIndex: orderIndex,
        title: title,
        urlString: urlString,
        createAt: DateTime.now(),
        serviceType: serviceType);
  }
}

class UrlSelectInfo {
  int id;
  int order;
  ServiceType serviceType;
  List<SimpleUrlInfo>? urlItemList;

  UrlSelectInfo(
      {this.id = 0,
      this.order = 0,
      this.serviceType = ServiceType.none,
      this.urlItemList});
}

class SimpleCityInfo {
  String name;
  String langCode;
  String state;
  String countryCode;

  SimpleCityInfo(
      {this.name = '',
      this.langCode = '',
      this.state = '',
      this.countryCode = ''});
}

class CityInfo extends SimpleCityInfo {
  int id;
  String zip;
  String nameDesc; // Name description with current locale.(same as localName)
  int timezone;
  bool isFavorite;

  CityInfo(
      {this.id = 0,
      this.zip = '',
      langCode,
      name = '',
      this.nameDesc = '',
      state = '',
      countryCode = '',
      this.timezone = 0,
      this.isFavorite = false});

  NovaItemInfo? toItemInfo(
      {int orderIndex = 0, ServiceType serviceType = ServiceType.none}) {
    return NovaItemInfo(
        id: 0,
        orderIndex: orderIndex,
        title: 'weather',
        urlString: 'http://',
        createAt: DateTime.now(),
        serviceType: serviceType,
        weatherInfo: WeatherInfo(city: this));
  }

  String toCityKey() {
    return "$name}_$state}_$countryCode";
  }
}

enum TemperatureUnit { kelvin, celsius, fahrenheit }

extension TemperatureUnitDescripts on TemperatureUnit {
  String get name {
    switch (this) {
      case TemperatureUnit.kelvin:
        return '°K';
      case TemperatureUnit.celsius:
        return '°C'; //
      case TemperatureUnit.fahrenheit:
        return '°F';
      default:
        return '';
    }
  }

  static TemperatureUnit fromString(String string) {
    return TemperatureUnit.values
        .firstWhere((element) => element.name == string);
  }

  String get stringClass {
    switch (this) {
      case TemperatureUnit.kelvin:
      case TemperatureUnit.celsius:
      case TemperatureUnit.fahrenheit:
        return toString().split(".").last;
      default:
        return '';
    }
  }
}

class Temperature {
  static const double kKelvin = 273.15;
  final double _kelvin;

  // ignore: unnecessary_null_comparison
  Temperature(this._kelvin) : assert(_kelvin != null);

  double get kelvin => _kelvin;

  double get celsius => _kelvin - kKelvin;

  double get fahrenheit => _kelvin * (9 / 5) - 459.67;

  double as(TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.kelvin:
        return kelvin;
      case TemperatureUnit.celsius:
        return celsius;
      case TemperatureUnit.fahrenheit:
        return fahrenheit;
    }
  }
}

class WeatherInfo {
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

  WeatherInfo(
      {this.id,
      this.time,
      this.sunrise,
      this.sunset,
      this.humidity,
      this.rain,
      this.snow,
      this.description,
      this.iconCode,
      this.main,
      this.city,
      this.windSpeed,
      this.windDeg,
      this.feelsLike,
      this.temperature,
      this.maxTemperature,
      this.minTemperature,
      this.maxTemperatureOfForecast,
      this.minTemperatureOfForecast,
      this.forecast});
}

class NetworkType {}

extension ExceptionExt on Exception {
  int getCode() {
    String str = toString().split(":").last.trim();
    return int.tryParse(str) ?? 0;
  }
}

enum AppErrorType {
  network,
  badRequest,
  unauthorized,
  cancel,
  timeout,
  server,
  dataError,
  unknown,
}

enum FailureReason {
  none,
  missingRootNode,
  missingImgNode,
  missingListNode,
  missingTableNode,
  missingBbsMenuNode,
  missingBbsLangNode,
  exception,
}

class AppError {
  String message;
  String innerMessage;
  AppErrorType type;
  FailureReason reason;

  AppError(
      {required this.type,
      this.message = '',
      this.innerMessage = '',
      this.reason = FailureReason.none});

  @override
  String toString() {
    String retStr = "AppError type:$type";
    if (message.isNotEmpty) {
      retStr += " message=$message";
    }
    if (reason != FailureReason.none) {
      retStr += " reason=$reason";
    }
    if (innerMessage.isNotEmpty) {
      retStr += " message=$innerMessage";
    }
    return retStr;
  }

  factory AppError.fromException(Exception error) {
    AppErrorType type = AppErrorType.unknown;
    String msg = '';
    String innerMsg = '';
    FailureReason reason = FailureReason.exception;
    if (error is SocketException) {
      SocketException err = error;
      type = AppErrorType.network;
      innerMsg = err.message;
    }

    return AppError(
        type: type, message: msg, innerMessage: innerMsg, reason: reason);
  }

  factory AppError.fromStatusCode(int statusCode) {
    AppErrorType type = AppErrorType.unknown;
    String msg = '';
    String innerMsg = '';
    FailureReason reason = FailureReason.exception;

    switch (statusCode) {
      case HttpStatus.badRequest: // 400
        type = AppErrorType.badRequest;
        break;
      case HttpStatus.unauthorized: // 401
        type = AppErrorType.unauthorized;
        break;
      case HttpStatus.requestTimeout: // 408
        type = AppErrorType.timeout;
        break;
      case HttpStatus.internalServerError: // 500
      case HttpStatus.badGateway: // 502
      case HttpStatus.serviceUnavailable: // 503
      case HttpStatus.gatewayTimeout: // 504
        type = AppErrorType.server;
        break;
      default:
        type = AppErrorType.unknown;
        break;
    }
    return AppError(
        type: type, message: msg, innerMessage: innerMsg, reason: reason);
  }
}
