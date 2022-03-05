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
      String? prefixTitle,
      bool isReloaded = false});
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo});
  Future<String> eventFetchThumbnail({required String targetUrl});
}

class TopListPresenterImpl extends TopListPresenter {
  final NewsListUseCase useCase;
  final TopListRouter router;
  late StreamSubscription<NovaListUseCaseOutput> _streamSubscription;
  bool _isProcessing = false;

  TopListPresenterImpl({required this.router}) : useCase = NewsListUseCase() {
    _streamSubscription = _addStreamListener();
  }

  @override
  bool get isProcessing => _isProcessing;

  @override
  void eventViewReady(
      {required int targetUrlIndex,
      String? prefixTitle,
      bool isReloaded = false}) async {
    _isProcessing = true;
    if (isReloaded) {
      await _streamSubscription.cancel();
      _streamSubscription = _addStreamListener();
    }
    useCase.fetchNewsList(
        targetUrlIndex: targetUrlIndex, prefixTitle: prefixTitle);
  }

  @override
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo}) {
    router.gotoTopDetail(context, appBarTitle: appBarTitle, itemInfo: itemInfo);
  }

  @override
  Future<String> eventFetchThumbnail({required String targetUrl}) async {
    return useCase.fetchThumbUrl(itemUrl: targetUrl);
  }

  StreamSubscription<NovaListUseCaseOutput> _addStreamListener() {
    return useCase.stream.listen((event) {
      if (event is PresentModel) {
        streamAdd(ShowNovaListModel(
            viewModelList:
                event.model?.map((row) => NovaListRowViewModel(row)).toList(),
            error: event.error));
        _isProcessing = false;
      }
    });
  }
}
