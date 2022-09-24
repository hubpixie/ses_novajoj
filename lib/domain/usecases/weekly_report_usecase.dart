import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/weekly_report_repository.dart';
import 'package:ses_novajoj/data/repositories/weekly_report_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'weekly_report_usecase_output.dart';

class WeeklyReportUseCaseInput {}

abstract class WeeklyReportUseCase with SimpleBloc<WeeklyReportUseCaseOutput> {
  void fetchWeeklyReport({required WeeklyReportUseCaseInput input});
}

class WeeklyReportUseCaseImpl extends WeeklyReportUseCase {
  final WeeklyReportRepositoryImpl repository;
  WeeklyReportUseCaseImpl() : repository = WeeklyReportRepositoryImpl();

  @override
  void fetchWeeklyReport({required WeeklyReportUseCaseInput input}) async {
    final result = await repository.fetchWeeklyReport(
        input: FetchWeeklyReportRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(PresentModel(model: WeeklyReportUseCaseModel(null, [], [])));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
