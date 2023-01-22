import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/comment_list_usecase_output.dart';

abstract class CommentListPresenterOutput {}

class ShowCommentListPageModel extends CommentListPresenterOutput {
  final CommentListViewModel? viewModel;
  final AppError? error;
  ShowCommentListPageModel({this.viewModel, this.error});
}

class CommentListViewModel {
  int id; 

  CommentListViewModel(CommentListUseCaseModel model)
      : id = model.id/*,
       name = model.name,
      ...
      */;
}