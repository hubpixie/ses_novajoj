import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/networking/response/weather_item_response.dart';
import 'package:ses_novajoj/networking/request/weather_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/weekly_report_item.dart';
import 'package:ses_novajoj/domain/repositories/weekly_report_repository.dart';
import 'package:ses_novajoj/networking/api/weather_web_api.dart';

class WeeklyReportRepositoryImpl extends WeeklyReportRepository {
  final WeatherWebApi _api;

  // sigleton
  static final WeeklyReportRepositoryImpl _instance =
      WeeklyReportRepositoryImpl._internal();
  WeeklyReportRepositoryImpl._internal() : _api = WeatherWebApi();
  factory WeeklyReportRepositoryImpl() => _instance;

  @override
  Future<Result<WeeklyReportItem>> fetchWeeklyReport(
      {required FetchWeeklyReportRepoInput input}) async {
    // fetch weather
    WeatherItemParameter paramter = WeatherItemParameter();
    paramter.cityParam = input.cityInfo;
    Result<WeatherItemRes> ret = await _api.getWeatherData(paramter: paramter);
    WeatherItemRes? weatherRes;
    dynamic weatherError;
    ret.when(success: (value) {
      weatherRes = value;
    }, failure: (error) {
      weatherError = error;
    });

    // fetch forecast
    paramter.latitude = weatherRes?.latitude ?? 0;
    paramter.longitude = weatherRes?.longitude ?? 0;
    Result<List<WeatherItemRes>> retForecast =
        await _api.getForecast(paramter: paramter);

    late Result<WeeklyReportItem> result;
    List<WeatherItemRes>? forecast;
    retForecast.when(success: (value) {
      forecast = value;
    }, failure: (error) {
      log.severe('Get forecast errors occured: $error');
    });

    // set result
    if (weatherRes != null) {
      WeeklyReportItem data =
          WeeklyReportItem.copy(from: weatherRes!, newForecast: forecast);
      data.city?.name = input.cityInfo.name;
      data.city?.nameDesc = input.cityInfo.nameDesc;
      data.city?.state = input.cityInfo.state;
      data.city?.langCode = input.cityInfo.langCode;
      data.city?.countryCode = input.cityInfo.countryCode;

      result = Result.success(data: data);
    } else {
      log.severe('Get weather errors occured: $weatherError');
      result = Result.failure(error: weatherError);
    }

    return result;
  }
}
