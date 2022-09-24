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

// FIXME: DUMMY CODE
  WeeklyReportViewModel(WeeklyReportUseCaseModel? model)
      : data = model?.data,
        weeklyForecastData = model?.weeklyForecastData;
}
