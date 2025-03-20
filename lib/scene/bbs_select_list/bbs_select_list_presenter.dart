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
  int? blockIndex;
  int? limitPerBlock;
  bool isReloaded;
  LoadingCompleteHandler? completeHandler;

  BbsSelectListPresenterInput(
      {required this.targetUrl,
      this.targetPageIndex = 1,
      this.searchedKeyword = '',
      this.searchResultIsCleared = false,
      this.blockIndex,
      this.limitPerBlock,
      this.isReloaded = false,
      this.completeHandler});
}

typedef LoadingCompleteHandler = void Function();

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
  LoadingCompleteHandler? _loadingCompleteHandler;

  String _searchedKeyword = '';
  List<BbsSelectListRowViewModel>? _prevViewModelList;
  List<BbsSelectListRowViewModel>? _viewModelList;

  BbsSelectListPresenterImpl({required this.router})
      : useCase = BbsSelectListUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          _viewModelList ??= [];
          List<BbsSelectListRowViewModel> modelList = event.model
                  ?.map((row) => BbsSelectListRowViewModel.fromUseCase(row))
                  .toList() ??
              [];
          for (var elem in modelList) {
            final list = _viewModelList!.where((subElem) =>
                subElem.itemInfo.urlString == elem.itemInfo.urlString);
            if (list.isEmpty) {
              _viewModelList?.add(elem);
            }
          }
          print(
              "[3-2]:totolItemCount=${modelList.last.itemInfo.totolItemClount}");
          streamAdd(ShowBbsSelectListPageModel(
              viewModelList: _viewModelList, error: event.error));

          // keep bbs select result not search result
          if (_searchedKeyword.isEmpty) {
            _prevViewModelList = _viewModelList;
          }

/*
          // set fetched result.
          final list = event.model
              ?.map((model) => BbsSelectListRowViewModel.fromUseCase(model))
              .toList();
          print(
              "[3]:totolItemCount=${list?.last.itemInfo.totolItemClount},${list?.length}");
          streamAdd(ShowBbsSelectListPageModel(viewModelList: list));

          // keep bbs select result not search result
          if (_searchedKeyword.isEmpty) {
            _prevViewModelList = list;
          }*/
        } else {
          streamAdd(ShowBbsSelectListPageModel(error: event.error));
        }
        _isProcessing = false;
        _loadingCompleteHandler?.call();
      }
    });
  }

  @override
  bool get isProcessing {
    return _isProcessing;
  }

  @override
  void eventViewReady({required BbsSelectListPresenterInput input}) {
    _searchedKeyword = input.searchedKeyword;
    if (input.searchResultIsCleared) {
      streamAdd(ShowBbsSelectListPageModel(viewModelList: _prevViewModelList));
      return;
    }
    _isProcessing = true;
    _loadingCompleteHandler = input.completeHandler;
    print("[3]:totolItemCount=...START");
    if (input.isReloaded) {
      // await _streamSubscription.cancel();
      // _streamSubscription = _addStreamListener();
      _viewModelList?.clear();
    }
    useCase.fetchBbsSelectList(
        input: BbsSelectListUseCaseInput(
            targetUrl: input.targetUrl,
            searchedKeyword: input.searchedKeyword,
            targetPageIndex: input.targetPageIndex,
            pageBlockIndex: input.blockIndex,
            limitPerBlock: input.limitPerBlock));
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
