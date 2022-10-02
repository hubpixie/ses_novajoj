import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/weekly_report_usecase_output.dart';

abstract class WeeklyReportPresenterOutput {}

class ShowWeeklyReportPageModel extends WeeklyReportPresenterOutput {
  final WeeklyReportViewModel? viewModel;
  final AppError? error;
  ShowWeeklyReportPageModel({this.viewModel, this.error});
}

class WeeklyReportViewModel {
  WeatherInfo? data;
  List<WeatherInfo>? hourlyForecastData;
  List<WeatherInfo>? weeklyForecastData;

  WeeklyReportViewModel(WeeklyReportUseCaseModel? model)
      : data = model?.data,
        hourlyForecastData = model?.hourlyForecastData,
        weeklyForecastData = model?.weeklyForecastData;
}
