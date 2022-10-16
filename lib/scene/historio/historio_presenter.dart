import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase_output.dart';
import 'historio_presenter_output.dart';

import 'historio_router.dart';

class HistorioPresenterInput {

}

abstract class HistorioPresenter with SimpleBloc<HistorioPresenterOutput> {
  void eventViewReady({required HistorioPresenterInput input});
}

class HistorioPresenterImpl extends HistorioPresenter {
  final HistorioUseCase useCase;
  final HistorioRouter router;

  HistorioPresenterImpl({required this.router})
      : useCase = HistorioUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowHistorioPageModel(
              viewModel: HistorioViewModel(event.model!)));
        } else {
          streamAdd(ShowHistorioPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required HistorioPresenterInput input}) {
    useCase.fetchHistorio(input: HistorioUseCaseInput());
  }
}
