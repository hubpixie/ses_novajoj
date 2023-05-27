import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/city_select_usecase.dart';
import 'package:ses_novajoj/domain/usecases/city_select_usecase_output.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'city_select_presenter_output.dart';

import 'city_select_router.dart';

class CitySelectPresenterInput {
  String appBarTitle;
  CityInfo? selectedCityInfo;
  ServiceType serviceType;
  String? sourceRoute;
  int order;
  Object? completeHandler;
  bool dataCleared;

  CitySelectPresenterInput(
      {this.appBarTitle = '',
      this.selectedCityInfo,
      this.serviceType = ServiceType.none,
      this.sourceRoute,
      this.order = 0,
      this.completeHandler,
      this.dataCleared = false});
}

abstract class CitySelectPresenter with SimpleBloc<CitySelectPresenterOutput> {
  void eventViewReady({required CitySelectPresenterInput input});
  bool eventSelectingCityInfo(Object context,
      {required CitySelectPresenterInput input});
  Future<CitySelectPresenterOutput> eventSelectMainCities(
      {required CitySelectPresenterInput input});
}

class CitySelectPresenterImpl extends CitySelectPresenter {
  final CitySelectUseCase useCase;
  final CitySelectRouter router;

  CitySelectPresenterImpl({required this.router})
      : useCase = CitySelectUseCaseImpl();

  @override
  void eventViewReady({required CitySelectPresenterInput input}) {
    useCase
        .fetchCitySelect(
            input: CitySelectUseCaseInput(
                cityInfo: input.selectedCityInfo!,
                dataCleared: input.dataCleared))
        .then((value) {
      if (value is PresentModel) {
        if (value.error == null) {
          streamAdd(ShowCitySelectPageModel(
              viewModel: CitySelectViewModel(value.model!)));
        } else {
          streamAdd(ShowCitySelectPageModel(error: value.error));
        }
      }
    });
  }

  @override
  bool eventSelectingCityInfo(Object context,
      {required CitySelectPresenterInput input}) {
    // save the selected url info
    UserData()
        .saveUserInfoList(
            newValue: input.selectedCityInfo,
            order: input.order,
            serviceType: input.serviceType)
        .then((value) {
      // navigate the target as web page if exists
      if (value) {
        if (input.sourceRoute == ScreenRouteName.weeklyReport.name) {
          router.gotoWeeklyReportPage(context,
              itemInfo: input.selectedCityInfo
                  ?.toItemInfo(serviceType: input.serviceType),
              completeHandler: input.completeHandler);
        } else {
          router.gotoMiscListPage(context,
              itemInfo: input.selectedCityInfo
                  ?.toItemInfo(serviceType: input.serviceType),
              completeHandler: input.completeHandler);
        }
      }
    });
    return true;
  }

  @override
  Future<CitySelectPresenterOutput> eventSelectMainCities(
      {required CitySelectPresenterInput input}) async {
    final ret = await useCase.fetchMainCities(
        input: CitySelectUseCaseInput(cityInfo: CityInfo()));
    if (ret is PresentModel) {
      return ShowCitySelectPageModel(
          viewModel: CitySelectViewModel(ret.model!));
    } else {
      log.severe('unknown error!');
      return ShowCitySelectPageModel(viewModel: null);
    }
  }
}
