import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase_output.dart';
import 'misc_info_list_presenter_output.dart';

import 'misc_info_list_router.dart';

class MiscInfoListPresenterInput {
  String appBarTitle;
  List<MiscInfoListViewModel>? viewModelList;
  int itemIndex;
  ServiceType serviceType;
  Object? completeHandler;
  MiscInfoListPresenterInput(
      {this.appBarTitle = '',
      this.viewModelList,
      this.itemIndex = 0,
      this.serviceType = ServiceType.none,
      this.completeHandler});
}

abstract class MiscInfoListPresenter
    with SimpleBloc<MiscInfoListPresenterOutput> {
  void eventViewReady({required MiscInfoListPresenterInput input});
  void eventViewWebPage(Object context,
      {required MiscInfoListPresenterInput input});
}

class MiscInfoListPresenterImpl extends MiscInfoListPresenter {
  final MiscInfoListUseCase useCase;
  final MiscInfoListRouter router;

  MiscInfoListPresenterImpl({required this.router})
      : useCase = MiscInfoListUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowMiscInfoListPageModel(
              viewModelList: event.model
                  ?.map((row) => MiscInfoListViewModel(row))
                  .toList()));
        } else {
          streamAdd(ShowMiscInfoListPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required MiscInfoListPresenterInput input}) {
    useCase.fetchMiscInfoList(input: MiscInfoListUseCaseInput());
  }

  @override
  void eventViewWebPage(Object context,
      {required MiscInfoListPresenterInput input}) {
    final itemInfos = input.viewModelList?.where((element) =>
        element.itemInfo.serviceType == input.serviceType &&
        element.itemInfo.orderIndex == input.itemIndex);

    void removeAction() {
      UserData().saveUserInfoList(
          newValue: input.serviceType == ServiceType.weather
              ? SimpleCityInfo()
              : SimpleUrlInfo(),
          order: input.itemIndex,
          allowsRemove: true,
          serviceType: input.serviceType);
    }

    NovaItemInfo? itemInfo;
    if (itemInfos == null || itemInfos.isEmpty || input.itemIndex == -1) {
      itemInfo = SimpleUrlInfo().toItemInfo(
          orderIndex: input.itemIndex, serviceType: input.serviceType);
    } else {
      itemInfo = itemInfos.first.itemInfo;
    }
    if (itemInfo?.urlString.isEmpty ?? true) {
      if (input.serviceType == ServiceType.weather) {
        router.gotoCitySelectPage(context,
            appBarTitle: input.appBarTitle,
            itemInfo: itemInfo,
            completeHandler: input.completeHandler);
      } else {
        router.gotoSelectPage(context,
            appBarTitle: input.appBarTitle,
            itemInfo: itemInfo,
            completeHandler: input.completeHandler);
      }
      return;
    }
    router.gotoWebPage(context,
        appBarTitle: input.appBarTitle,
        itemInfo: itemInfos?.first.itemInfo,
        removeAction:
            input.serviceType == ServiceType.audio ? removeAction : null,
        completeHandler: input.completeHandler);
  }
}
