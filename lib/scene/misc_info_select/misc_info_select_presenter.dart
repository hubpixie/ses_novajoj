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

  MiscInfoSelectPresenterInput(
      {this.appBarTitle = '',
      this.serviceType = ServiceType.none,
      this.selectedUrlInfo,
      this.completeHandler});
}

abstract class MiscInfoSelectPresenter
    with SimpleBloc<MiscInfoSelectPresenterOutput> {
  void eventViewReady({required MiscInfoSelectPresenterInput input});
  void eventSelectingUrlInfo(Object context,
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
              viewModel: MiscInfoSelectViewModel(event.model!)));
        } else {
          streamAdd(ShowMiscInfoSelectPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required MiscInfoSelectPresenterInput input}) {
    useCase.fetchMiscInfoSelect(input: MiscInfoSelectUseCaseInput());
  }

  @override
  void eventSelectingUrlInfo(Object context,
      {required MiscInfoSelectPresenterInput input}) {
    router.gotoWebPage(context,
        appBarTitle: input.appBarTitle,
        itemInfo:
            input.selectedUrlInfo?.toItemInfo(serviceType: input.serviceType),
        completeHandler: input.completeHandler);
  }
}
