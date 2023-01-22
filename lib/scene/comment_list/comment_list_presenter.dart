import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/comment_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/comment_list_usecase_output.dart';
import 'comment_list_presenter_output.dart';

import 'comment_list_router.dart';

class CommentListPresenterInput {

}

abstract class CommentListPresenter with SimpleBloc<CommentListPresenterOutput> {
  void eventViewReady({required CommentListPresenterInput input});
}

class CommentListPresenterImpl extends CommentListPresenter {
  final CommentListUseCase useCase;
  final CommentListRouter router;

  CommentListPresenterImpl({required this.router})
      : useCase = CommentListUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowCommentListPageModel(
              viewModel: CommentListViewModel(event.model!)));
        } else {
          streamAdd(ShowCommentListPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required CommentListPresenterInput input}) {
    useCase.fetchCommentList(input: CommentListUseCaseInput());
  }
}
