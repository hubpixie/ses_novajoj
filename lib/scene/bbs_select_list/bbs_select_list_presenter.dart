import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/bbs_select_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/bbs_select_list_usecase_output.dart';
import 'bbs_select_list_presenter_output.dart';

import 'bbs_select_list_router.dart';

class BbsSelectListPresenterInput {
  String targetUrl;
  String searchedKeyword;
  bool searchResultIsCleared;
  int targetPageIndex;
  bool isReloaded;

  BbsSelectListPresenterInput(
      {required this.targetUrl,
      this.targetPageIndex = 1,
      this.searchedKeyword = '',
      this.searchResultIsCleared = false,
      this.isReloaded = false});
}

abstract class BbsSelectListPresenter
    with SimpleBloc<BbsSelectListPresenterOutput> {
  bool get isProcessing;
  void eventViewReady({required BbsSelectListPresenterInput input});
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
}

class BbsSelectListPresenterImpl extends BbsSelectListPresenter {
  final BbsSelectListUseCase useCase;
  final BbsSelectListRouter router;
  late bool _isProcessing;
  List<BbsSelectListRowViewModel>? _viewModelList;

  BbsSelectListPresenterImpl({required this.router})
      : useCase = BbsSelectListUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          _viewModelList = event.model
              ?.map((model) => BbsSelectListRowViewModel(model))
              .toList();
          streamAdd(ShowBbsSelectListPageModel(viewModelList: _viewModelList));
        } else {
          streamAdd(ShowBbsSelectListPageModel(error: event.error));
        }
        _isProcessing = false;
      }
    });
  }

  @override
  bool get isProcessing {
    return _isProcessing;
  }

  @override
  void eventViewReady({required BbsSelectListPresenterInput input}) {
    if (input.searchResultIsCleared) {
      streamAdd(ShowBbsSelectListPageModel(viewModelList: _viewModelList));
      return;
    }
    _isProcessing = true;
    useCase.fetchBbsSelectList(
        input: BbsSelectListUseCaseInput(
            targetUrl: input.targetUrl,
            searchedKeyword: input.searchedKeyword,
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
