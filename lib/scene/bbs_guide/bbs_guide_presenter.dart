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
