import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/city_select_usecase.dart';
import 'package:ses_novajoj/domain/usecases/city_select_usecase_output.dart';
import 'city_select_presenter_output.dart';

import 'city_select_router.dart';

class CitySelectPresenterInput {
  String appBarTitle;
  SimpleCityInfo? selectedCityInfo;
  Object? completeHandler;
  ServiceType serviceType;
  int order;

  CitySelectPresenterInput(
      {this.appBarTitle = '',
      this.serviceType = ServiceType.none,
      this.order = 0,
      this.selectedCityInfo,
      this.completeHandler});
}

abstract class CitySelectPresenter with SimpleBloc<CitySelectPresenterOutput> {
  void eventViewReady({required CitySelectPresenterInput input});
  bool eventSelectingCityInfo(Object context,
      {required CitySelectPresenterInput input});
}

class CitySelectPresenterImpl extends CitySelectPresenter {
  final CitySelectUseCase useCase;
  final CitySelectRouter router;

  CitySelectPresenterImpl({required this.router})
      : useCase = CitySelectUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowCitySelectPageModel(
              viewModel: CitySelectViewModel(event.model!)));
        } else {
          streamAdd(ShowCitySelectPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required CitySelectPresenterInput input}) {
    useCase.fetchCitySelect(input: CitySelectUseCaseInput());
  }

  @override
  bool eventSelectingCityInfo(Object context,
      {required CitySelectPresenterInput input}) {
    return true;
  }
}
