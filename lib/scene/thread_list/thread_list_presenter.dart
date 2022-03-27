import 'dart:async';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_list_usecase_output.dart';
import 'thread_list_presenter_output.dart';

import 'thread_list_router.dart';

class ThreadListPresenterInput {
  int itemIndex;
  String itemUrl;
  bool isReloaded;

  ThreadListPresenterInput(
      {required this.itemIndex, this.itemUrl = "", this.isReloaded = false});
}

abstract class ThreadListPresenter with SimpleBloc<ThreadListPresenterOutput> {
  void eventViewReady({required ThreadListPresenterInput input});
  Future<String> eventFetchThumbnail({required ThreadListPresenterInput input});
}

class ThreadListPresenterImpl extends ThreadListPresenter {
  final ThreadNovaListUseCase useCase;
  final ThreadListRouter router;
  late StreamSubscription<ThreadNovaListUseCaseOutput> _streamSubscription;

  ThreadListPresenterImpl({required this.router})
      : useCase = ThreadNovaListUseCaseImpl() {
    _streamSubscription = _addStreamListener();
  }

  @override
  void eventViewReady({required ThreadListPresenterInput input}) async {
    useCase.fetchThreadNovaList(
        input: ThreadNovaListUseCaseInput(itemIndex: input.itemIndex));
    if (input.isReloaded) {
      await _streamSubscription.cancel();
      _streamSubscription = _addStreamListener();
    }
    useCase.fetchThreadNovaList(
        input: ThreadNovaListUseCaseInput(itemIndex: input.itemIndex));
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
        streamAdd(ShowThreadListPageModel(
            viewModelList: event.model
                ?.map((row) => ThreadNovaListRowViewModel(row))
                .toList(),
            error: event.error));
      }
    });
  }
}
