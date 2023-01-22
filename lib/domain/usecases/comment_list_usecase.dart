import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/data/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'comment_list_usecase_output.dart';

class CommentListUseCaseInput {

}

abstract class CommentListUseCase with SimpleBloc<CommentListUseCaseOutput> {
  void fetchCommentList({required CommentListUseCaseInput input});
}

class CommentListUseCaseImpl extends CommentListUseCase {
  final CommentListRepositoryImpl repository;
  CommentListUseCaseImpl() : repository = CommentListRepositoryImpl();

  @override
  void fetchCommentList({required CommentListUseCaseInput input}) async {
    final result = await repository.fetchCommentList(
        input: FetchCommentListRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: CommentListUseCaseModel(9999, value.toString() /* // TODO: dummy code*/)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
