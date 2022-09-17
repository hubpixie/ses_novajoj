import 'dart:async';

import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/city_select_usecase.dart';
import 'package:ses_novajoj/domain/usecases/city_select_usecase_output.dart';
import 'city_select_presenter_output.dart';

import 'city_select_router.dart';

class CitySelectPresenterInput {
  String appBarTitle;
  CityInfo? selectedCityInfo;
  Object? completeHandler;
  ServiceType serviceType;
  int order;
  bool dataCleared;

  CitySelectPresenterInput(
      {this.appBarTitle = '',
      this.serviceType = ServiceType.none,
      this.order = 0,
      this.selectedCityInfo,
      this.completeHandler,
      this.dataCleared = false});
}

abstract class CitySelectPresenter with SimpleBloc<CitySelectPresenterOutput> {
  void eventViewReady({required CitySelectPresenterInput input});
  bool eventSelectingCityInfo(Object context,
      {required CitySelectPresenterInput input});
}

class CitySelectPresenterImpl extends CitySelectPresenter {
  final CitySelectUseCase useCase;
  final CitySelectRouter router;

  late StreamSubscription<CitySelectUseCaseOutput> _streamSubscription;
  bool _isRefreshed = false;

  CitySelectPresenterImpl({required this.router})
      : useCase = CitySelectUseCaseImpl() {
    _streamSubscription = _addStreamListener();
  }

  @override
  void eventViewReady({required CitySelectPresenterInput input}) async {
    if (_isRefreshed) {
      await _streamSubscription.cancel();
      _streamSubscription = _addStreamListener();
    } else {
      _isRefreshed = true;
    }
    useCase.fetchCitySelect(
        input: CitySelectUseCaseInput(
            cityInfo: input.selectedCityInfo!, dataCleared: input.dataCleared));
  }

  @override
  bool eventSelectingCityInfo(Object context,
      {required CitySelectPresenterInput input}) {
    // save the selected url info
    bool saved = UserData().saveUserInfoList(
        newValue: input.selectedCityInfo,
        order: input.order,
        serviceType: input.serviceType);

    // navigate the target as web page if exists
    if (saved) {
      router.gotoMiscListPage(context,
          itemInfo: input.selectedCityInfo
              ?.toItemInfo(serviceType: input.serviceType),
          completeHandler: input.completeHandler);
    }
    return saved;
  }

  StreamSubscription<CitySelectUseCaseOutput> _addStreamListener() {
    return useCase.stream.listen((event) {
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
}
