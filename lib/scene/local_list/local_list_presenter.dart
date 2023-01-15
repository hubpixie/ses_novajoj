import 'dart:async';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/local_nova_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/local_nova_list_usecase_output.dart';
import 'local_list_presenter_output.dart';

import 'local_list_router.dart';

class LocalListPresenterInput {
  int itemIndex;
  String itemUrl;
  int targetPageIndex;
  bool isReloaded;

  LocalListPresenterInput(
      {required this.itemIndex,
      this.itemUrl = "",
      this.targetPageIndex = 1,
      this.isReloaded = false});
}

abstract class LocalListPresenter with SimpleBloc<LocalListPresenterOutput> {
  void eventViewReady({required LocalListPresenterInput input});
  void eventSelectDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
  Future<String> eventFetchThumbnail({required LocalListPresenterInput input});
}

class LocalListPresenterImpl extends LocalListPresenter {
  final LocalNovaListUseCase useCase;
  final LocalListRouter router;
  late StreamSubscription<LocalNovaListUseCaseOutput> _streamSubscription;

  LocalListPresenterImpl({required this.router})
      : useCase = LocalNovaListUseCaseImpl() {
    _streamSubscription = _addStreamListener();
  }

  @override
  void eventViewReady({required LocalListPresenterInput input}) async {
    if (input.isReloaded) {
      await _streamSubscription.cancel();
      _streamSubscription = _addStreamListener();
    }
    useCase.fetchLocalNovaList(
        input: LocalNovaListUseCaseInput(
            itemIndex: input.itemIndex,
            targetPageIndex: input.targetPageIndex));
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
  Future<String> eventFetchThumbnail(
      {required LocalListPresenterInput input}) async {
    return useCase.fetchThumbUrl(
        input: LocalNovaListUseCaseInput(
            itemIndex: input.itemIndex, itemUrl: input.itemUrl));
  }

  StreamSubscription<LocalNovaListUseCaseOutput> _addStreamListener() {
    return useCase.stream.listen((event) {
      if (event is PresentModel) {
        streamAdd(ShowLocalListPageModel(
            viewModelList: event.model
                ?.map((row) => LocalNovaListRowViewModel(row))
                .toList(),
            error: event.error));
      }
    });
  }
}
