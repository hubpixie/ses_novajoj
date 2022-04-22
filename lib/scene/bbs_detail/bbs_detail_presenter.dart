import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_detail_usecase.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_detail_usecase_output.dart';
import 'bbs_detail_presenter_output.dart';

import 'bbs_detail_router.dart';

class BbsDetailPresenterInput {

}

abstract class BbsDetailPresenter with SimpleBloc<BbsDetailPresenterOutput> {
  void eventViewReady({required BbsDetailPresenterInput input});
}

class BbsDetailPresenterImpl extends BbsDetailPresenter {
  final BbsNovaDetailUseCase useCase;
  final BbsDetailRouter router;

  BbsDetailPresenterImpl({required this.router})
      : useCase = BbsNovaDetailUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowBbsDetailPageModel(
              viewModel: BbsDetailViewModel(event.model!)));
        } else {
          streamAdd(ShowBbsDetailPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required BbsDetailPresenterInput input}) {
    useCase.fetchBbsNovaDetail(input: BbsNovaDetailUseCaseInput());
  }
}
