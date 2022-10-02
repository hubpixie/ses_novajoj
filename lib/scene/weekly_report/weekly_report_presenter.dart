import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/weekly_report_usecase.dart';
import 'package:ses_novajoj/domain/usecases/weekly_report_usecase_output.dart';
import 'weekly_report_presenter_output.dart';

import 'weekly_report_router.dart';

class WeeklyReportPresenterInput {
  CityInfo cityInfo;

  WeeklyReportPresenterInput({required this.cityInfo});
}

abstract class WeeklyReportPresenter
    with SimpleBloc<WeeklyReportPresenterOutput> {
  void eventViewReady({required WeeklyReportPresenterInput input});
}

class WeeklyReportPresenterImpl extends WeeklyReportPresenter {
  final WeeklyReportUseCase useCase;
  final WeeklyReportRouter router;

  WeeklyReportPresenterImpl({required this.router})
      : useCase = WeeklyReportUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowWeeklyReportPageModel(
              viewModel: WeeklyReportViewModel(event.model!)));
        } else {
          streamAdd(ShowWeeklyReportPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required WeeklyReportPresenterInput input}) {
    useCase.fetchWeeklyReport(
        input: WeeklyReportUseCaseInput(cityInfo: input.cityInfo));
  }
}
