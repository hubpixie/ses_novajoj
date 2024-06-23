import 'dart:async';

import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/nova_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/nova_list_usecase_output.dart';
import 'top_list_router.dart';
import 'top_list_presenter_output.dart';

abstract class TopListPresenter with SimpleBloc<TopListPresenterOutput> {
  bool get isProcessing;

  void eventViewReady(
      {required int targetUrlIndex,
      String searchedKeyword,
      bool searchResultIsCleared,
      String? prefixTitle,
      int? blockIndex,
      int? pageIndex,
      int? limitPerBlock,
      bool isReloaded = false});
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
  Future<String> eventFetchThumbnail({required String targetUrl});
}

class TopListPresenterImpl extends TopListPresenter {
  final NewsListUseCase useCase;
  final TopListRouter router;
  late StreamSubscription<NovaListUseCaseOutput> _streamSubscription;
  List<NovaListRowViewModel>? _viewModelList;
  bool _isProcessing = false;

  TopListPresenterImpl({required this.router}) : useCase = NewsListUseCase() {
    _streamSubscription = _addStreamListener();
  }

  @override
  bool get isProcessing => _isProcessing;

  @override
  void eventViewReady(
      {required int targetUrlIndex,
      String searchedKeyword = '',
      bool searchResultIsCleared = false,
      String? prefixTitle,
      int? blockIndex,
      int? pageIndex,
      int? limitPerBlock,
      bool isReloaded = false}) async {
    if (searchResultIsCleared) {
      streamAdd(ShowListPageModel(
        viewModelList: _viewModelList,
      ));
      return;
    }
    _isProcessing = true;
    if (isReloaded) {
      await _streamSubscription.cancel();
      _streamSubscription = _addStreamListener();
      _viewModelList?.clear();
    }
    useCase.fetchNewsList(
        targetUrlIndex: targetUrlIndex,
        searchedKeyword: searchedKeyword,
        targetPageIndex: pageIndex,
        pageBlockIndex: blockIndex,
        limitPerBlock: limitPerBlock,
        prefixTitle: prefixTitle);

    // set loading indcator from block 2.
    if (blockIndex! > 1) {
      int blockCount = ((_viewModelList!.last.itemInfo.totolItemClount! - 1) /
                  _viewModelList!.last.itemInfo.limitPerBlock)
              .ceil() +
          1;
      if (blockIndex < blockCount - 1) {
        NovaListRowViewModel viewModel = NovaListRowViewModel(
            itemInfo: _viewModelList!.last.itemInfo,
            showsIndicatorOnNextBlock: true);
        List<NovaListRowViewModel> viewModelList = [
          ..._viewModelList!,
          viewModel
        ];
        streamAdd(ShowListPageModel(
          viewModelList: viewModelList,
        ));
      }
    }
  }

  @override
  void eventSelectDetail(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    router.gotoTopDetail(context,
        appBarTitle: appBarTitle,
        itemInfo: itemInfo,
        completeHandler: completeHandler);
  }

  @override
  Future<String> eventFetchThumbnail({required String targetUrl}) async {
    return useCase.fetchThumbUrl(itemUrl: targetUrl);
  }

  StreamSubscription<NovaListUseCaseOutput> _addStreamListener() {
    return useCase.stream.listen((event) {
      if (event is PresentModel) {
        _viewModelList ??= [];
        List<NovaListRowViewModel> modelList = event.model
                ?.map((row) => NovaListRowViewModel.fromUseCase(row))
                .toList() ??
            [];
        for (var elem in modelList) {
          final list = _viewModelList!.where((subElem) =>
              subElem.itemInfo.urlString == elem.itemInfo.urlString);
          if (list.isEmpty) {
            _viewModelList?.add(elem);
          }
        }
        streamAdd(ShowListPageModel(
            viewModelList: _viewModelList, error: event.error));
        _isProcessing = false;
      }
    });
  }
}
