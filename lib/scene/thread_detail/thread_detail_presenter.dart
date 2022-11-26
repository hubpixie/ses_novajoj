import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_detail_usecase.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_detail_usecase_output.dart';
import 'thread_detail_presenter_output.dart';

import 'thread_detail_router.dart';

class ThreadDetailPresenterInput {
  NovaItemInfo itemInfo;
  String? htmlText;

  ThreadDetailPresenterInput({required this.itemInfo, this.htmlText});
}

abstract class ThreadDetailPresenter
    with SimpleBloc<ThreadDetailPresenterOutput> {
  void eventViewReady({required ThreadDetailPresenterInput input});
  bool eventSaveBookmark({required ThreadDetailPresenterInput input});
}

class ThreadDetailPresenterImpl extends ThreadDetailPresenter {
  final ThreadNovaDetailUseCase useCase;
  final ThreadDetailRouter router;

  ThreadDetailPresenterImpl({required this.router})
      : useCase = ThreadNovaDetailUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowThreadDetailPageModel(
              viewModel: ThreadDetailViewModel(event.model!)));
        } else {
          streamAdd(ShowThreadDetailPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required ThreadDetailPresenterInput input}) {
    useCase.fetchThreadNovaDetail(
        input: ThreadNovaDetailUseCaseInput(itemInfo: input.itemInfo));
  }

  @override
  bool eventSaveBookmark({required ThreadDetailPresenterInput input}) {
    return useCase.saveBookmark(
        input: ThreadNovaDetailUseCaseInput(
            itemInfo: input.itemInfo, htmlText: input.htmlText));
  }
}
