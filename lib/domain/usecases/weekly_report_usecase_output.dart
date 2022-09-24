import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class WeeklyReportUseCaseOutput {}

class PresentModel extends WeeklyReportUseCaseOutput {
  final WeeklyReportUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class WeeklyReportUseCaseModel {
  WeatherInfo? data;
  List<WeatherInfo>? hourlyForecastData;
  List<WeatherInfo>? weeklyForecastData;

  WeeklyReportUseCaseModel(
      this.data, this.hourlyForecastData, this.weeklyForecastData);
}
