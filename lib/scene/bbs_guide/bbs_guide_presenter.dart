import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_guide_usecase.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_guide_usecase_output.dart';
import 'bbs_guide_presenter_output.dart';

import 'bbs_guide_router.dart';

class BbsGuidePresenterInput {
  int itemIndex;
  String itemUrl;
  bool isReloaded;

  BbsGuidePresenterInput(
      {required this.itemIndex, this.itemUrl = "", this.isReloaded = false});
}

abstract class BbsGuidePresenter with SimpleBloc<BbsGuidePresenterOutput> {
  void eventViewReady({required BbsGuidePresenterInput input});
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
  void eventSelectList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? completeHandler});
  Future<String> eventFetchThumbnail({required BbsGuidePresenterInput input});
}

class BbsGuidePresenterImpl extends BbsGuidePresenter {
  final BbsNovaGuideUseCase useCase;
  final BbsGuideRouter router;

  BbsGuidePresenterImpl({required this.router})
      : useCase = BbsNovaGuideUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowBbsGuidePageModel(
              viewModelList: event.model
                  ?.map((row) => BbsGuideListViewRowModel(row))
                  .toList(),
              error: event.error));
        } else {
          streamAdd(ShowBbsGuidePageModel(error: event.error));
        }
      }
    });
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

  @override
  void eventSelectList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? completeHandler}) {
    router.gotoBbsSelectList(context,
        appBarTitle: appBarTitle,
        targetUrl: targetUrl,
        completeHandler: completeHandler);
  }

  @override
  void eventViewReady({required BbsGuidePresenterInput input}) {
    useCase.fetchBbsGuideList(
        input: BbsNovaGuideUseCaseInput(itemIndex: input.itemIndex));
  }

  @override
  Future<String> eventFetchThumbnail(
      {required BbsGuidePresenterInput input}) async {
    return useCase.fetchThumbUrl(
        input: BbsNovaGuideUseCaseInput(
            itemIndex: input.itemIndex, itemUrl: input.itemUrl));
  }
}
