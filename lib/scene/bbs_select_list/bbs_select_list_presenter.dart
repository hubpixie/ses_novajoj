import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/bbs_select_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/bbs_select_list_usecase_output.dart';
import 'bbs_select_list_presenter_output.dart';

import 'bbs_select_list_router.dart';

class BbsSelectListPresenterInput {
  String targetUrl;
  int targetPageIndex;
  bool isReloaded;

  BbsSelectListPresenterInput(
      {required this.targetUrl,
      this.targetPageIndex = 1,
      this.isReloaded = false});
}

abstract class BbsSelectListPresenter
    with SimpleBloc<BbsSelectListPresenterOutput> {
  void eventViewReady({required BbsSelectListPresenterInput input});
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
}

class BbsSelectListPresenterImpl extends BbsSelectListPresenter {
  final BbsSelectListUseCase useCase;
  final BbsSelectListRouter router;

  BbsSelectListPresenterImpl({required this.router})
      : useCase = BbsSelectListUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowBbsSelectListPageModel(
              viewModelList: event.model
                  ?.map((model) => BbsSelectListRowViewModel(model))
                  .toList()));
        } else {
          streamAdd(ShowBbsSelectListPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required BbsSelectListPresenterInput input}) {
    useCase.fetchBbsSelectList(
        input: BbsSelectListUseCaseInput(
            targetUrl: input.targetUrl,
            targetPageIndex: input.targetPageIndex));
  }

  @override
  void eventSelectDetail(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    router.gotoBbsDetail(context,
        appBarTitle: appBarTitle,
        itemInfo: itemInfo,
        completeHandler: completeHandler);
  }
}
