import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase_output.dart';
import 'package:ses_novajoj/viper_templates/templates/lib/foundation/data/result.dart';
import 'historio_presenter_output.dart';

import 'historio_router.dart';

class HistorioPresenterInput {}

abstract class HistorioPresenter with SimpleBloc<HistorioPresenterOutput> {
  Future<HistorioPresenterOutput> eventViewReady(
      {required HistorioPresenterInput input});
}

class HistorioPresenterImpl extends HistorioPresenter {
  final HistorioUseCase useCase;
  final HistorioRouter router;

  HistorioPresenterImpl({required this.router})
      : useCase = HistorioUseCaseImpl();

  @override
  Future<HistorioPresenterOutput> eventViewReady(
      {required HistorioPresenterInput input}) async {
    final output = await useCase.fetchHistorio(input: HistorioUseCaseInput());
    List<HistorioViewModel>? list;
    if (output is PresentModel) {
      list = output.models?.map((e) => HistorioViewModel(e)).toList();
    }
    return ShowHistorioPageModel(viewModelList: list, error: null);
  }
}
