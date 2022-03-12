import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/nova_detail_usecase.dart';
import 'package:ses_novajoj/domain/usecases/nova_detail_usecase_output.dart';
import 'top_detail_presenter_output.dart';

import 'top_detail_router.dart';

abstract class TopDetailPresenter with SimpleBloc<TopDetailPresenterOutput> {
  bool get isProcessing;
  void eventViewReady(NovaItemInfo itemInfo);
}

class TopDetailPresenterImpl extends TopDetailPresenter {
  final NewsDetailUseCase useCase;
  final TopDetailRouter router;

  bool _isProcessing = true;

  TopDetailPresenterImpl({required this.router})
      : useCase = NewsDetailUseCase() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowNovaDetailPageModel(
              viewModel: NovaDetailViewModel(event.model!)));
        } else {
          streamAdd(ShowNovaDetailPageModel(error: event.error));
        }
      }
      _isProcessing = false;
    });
  }

  @override
  bool get isProcessing => _isProcessing;

  @override
  void eventViewReady(NovaItemInfo itemInfo) {
    useCase.fetchNewsDetail(info: itemInfo);
  }
}
