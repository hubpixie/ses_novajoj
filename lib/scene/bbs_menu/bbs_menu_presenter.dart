import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_menu_usecase.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_menu_usecase_output.dart';
import 'bbs_menu_presenter_output.dart';

import 'bbs_menu_router.dart';

class BbsMenuPresenterInput {}

abstract class BbsMenuPresenter with SimpleBloc<BbsMenuPresenterOutput> {
  void eventViewReady({required BbsMenuPresenterInput input});
  void eventSelectNextList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? searchedUrl,
      Object? completeHandler});
}

class BbsMenuPresenterImpl extends BbsMenuPresenter {
  final BbsNovaMenuUseCase useCase;
  final BbsMenuRouter router;

  BbsMenuPresenterImpl({required this.router})
      : useCase = BbsNovaMenuUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowBbsMenuPageModel(
              viewModelList: event.model
                  ?.map((model) => BbsMenuListRowViewModel(model))
                  .toList(),
              error: event.error));
        } else {
          streamAdd(ShowBbsMenuPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required BbsMenuPresenterInput input}) {
    useCase.fetchBbsNovaMenu(input: BbsNovaMenuUseCaseInput());
  }

  @override
  void eventSelectNextList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? searchedUrl,
      Object? completeHandler}) {
    router.gotoBbsSelectList(context,
        appBarTitle: appBarTitle,
        targetUrl: targetUrl,
        searchedUrl: searchedUrl,
        completeHandler: completeHandler);
  }
}
