import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_select_usecase.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_select_usecase_output.dart';
import 'misc_info_select_presenter_output.dart';

import 'misc_info_select_router.dart';

class MiscInfoSelectPresenterInput {
  String appBarTitle;
  SimpleUrlInfo? selectedUrlInfo;
  Object? completeHandler;
  ServiceType serviceType;
  int order;

  MiscInfoSelectPresenterInput(
      {this.appBarTitle = '',
      this.serviceType = ServiceType.none,
      this.order = 0,
      this.selectedUrlInfo,
      this.completeHandler});
}

abstract class MiscInfoSelectPresenter
    with SimpleBloc<MiscInfoSelectPresenterOutput> {
  void eventViewReady({required MiscInfoSelectPresenterInput input});
  bool eventSelectingUrlInfo(Object context,
      {required MiscInfoSelectPresenterInput input});
}

class MiscInfoSelectPresenterImpl extends MiscInfoSelectPresenter {
  final MiscInfoSelectUseCase useCase;
  final MiscInfoSelectRouter router;

  MiscInfoSelectPresenterImpl({required this.router})
      : useCase = MiscInfoSelectUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowMiscInfoSelectPageModel(
              viewModelList: event.models
                  ?.map((row) => MiscInfoSelectViewModel(row))
                  .toList()));
        } else {
          streamAdd(ShowMiscInfoSelectPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required MiscInfoSelectPresenterInput input}) {
    useCase.fetchMiscInfoSelectData(input: MiscInfoSelectUseCaseInput());
  }

  @override
  bool eventSelectingUrlInfo(Object context,
      {required MiscInfoSelectPresenterInput input}) {
    // save the selected url info
    bool saved = UserData().saveUserInfoList(
        newValue: input.selectedUrlInfo,
        order: input.order,
        serviceType: input.serviceType);

    // navigate the target as web page if exists
    if (saved) {
      router.gotoWebPage(context,
          appBarTitle: input.appBarTitle,
          itemInfo:
              input.selectedUrlInfo?.toItemInfo(serviceType: input.serviceType),
          completeHandler: input.completeHandler);
    }
    return saved;
  }
}
