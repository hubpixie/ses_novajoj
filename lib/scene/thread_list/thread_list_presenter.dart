import 'dart:async';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_list_usecase_output.dart';
import 'thread_list_presenter_output.dart';

import 'thread_list_router.dart';

class ThreadListPresenterInput {
  int itemIndex;
  String itemUrl;
  String searchedKeyword;
  bool searchResultIsCleared;
  int pageIndex;
  bool isReloaded;

  ThreadListPresenterInput(
      {required this.itemIndex,
      this.itemUrl = "",
      this.searchedKeyword = "",
      this.searchResultIsCleared = false,
      this.pageIndex = 1,
      this.isReloaded = false});
}

abstract class ThreadListPresenter with SimpleBloc<ThreadListPresenterOutput> {
  void eventViewReady({required ThreadListPresenterInput input});
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
  Future<String> eventFetchThumbnail({required ThreadListPresenterInput input});
}

class ThreadListPresenterImpl extends ThreadListPresenter {
  final ThreadNovaListUseCase useCase;
  final ThreadListRouter router;
  late bool _isProcessing;
  List<ThreadNovaListRowViewModel>? _viewModelList;

  late StreamSubscription<ThreadNovaListUseCaseOutput> _streamSubscription;

  ThreadListPresenterImpl({required this.router})
      : useCase = ThreadNovaListUseCaseImpl() {
    _streamSubscription = _addStreamListener();
  }

  @override
  void eventViewReady({required ThreadListPresenterInput input}) async {
    if (input.searchResultIsCleared) {
      streamAdd(ShowThreadListPageModel(viewModelList: _viewModelList));
      return;
    }
    _isProcessing = true;

    if (input.isReloaded) {
      await _streamSubscription.cancel();
      _streamSubscription = _addStreamListener();
    }
    useCase.fetchThreadNovaList(
        input: ThreadNovaListUseCaseInput(
      itemIndex: input.itemIndex,
      targetPageIndex: input.pageIndex,
      itemUrl: input.itemUrl,
      searchedKeyword: input.searchedKeyword,
    ));
  }

  @override
  void eventSelectDetail(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    router.gotoThreadDetail(context,
        appBarTitle: appBarTitle,
        itemInfo: itemInfo,
        completeHandler: completeHandler);
  }

  @override
  Future<String> eventFetchThumbnail(
      {required ThreadListPresenterInput input}) async {
    return useCase.fetchThumbUrl(
        input: ThreadNovaListUseCaseInput(
            itemIndex: input.itemIndex, itemUrl: input.itemUrl));
  }

  StreamSubscription<ThreadNovaListUseCaseOutput> _addStreamListener() {
    return useCase.stream.listen((event) {
      if (event is PresentModel) {
        _viewModelList = event.model
            ?.map((model) => ThreadNovaListRowViewModel(model))
            .toList();
        streamAdd(ShowThreadListPageModel(
            viewModelList: _viewModelList, error: event.error));
      }
      _isProcessing = false;
    });
  }

  bool get isProcessing {
    return _isProcessing;
  }
}
