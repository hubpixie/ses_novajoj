import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/weekly_report_repository.dart';
import 'package:ses_novajoj/data/repositories/weekly_report_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'weekly_report_usecase_output.dart';

class WeeklyReportUseCaseInput {
  CityInfo cityInfo;

  WeeklyReportUseCaseInput({required this.cityInfo});
}

abstract class WeeklyReportUseCase with SimpleBloc<WeeklyReportUseCaseOutput> {
  void fetchWeeklyReport({required WeeklyReportUseCaseInput input});
}

class WeeklyReportUseCaseImpl extends WeeklyReportUseCase {
  final WeeklyReportRepositoryImpl repository;
  WeeklyReportUseCaseImpl() : repository = WeeklyReportRepositoryImpl();

  @override
  void fetchWeeklyReport({required WeeklyReportUseCaseInput input}) async {
    final result = await repository.fetchWeeklyReport(
        input: FetchWeeklyReportRepoInput(cityInfo: input.cityInfo));

    result.when(success: (value) {
      streamAdd(PresentModel(
          model: WeeklyReportUseCaseModel(
              value, value.hourlyForecast, value.weeklyForecast)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
