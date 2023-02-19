import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/data/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'comment_list_usecase_output.dart';

class CommentListUseCaseInput {
  NovaItemInfo itemInfo;

  CommentListUseCaseInput({required this.itemInfo});
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
            itemInfo: input.itemInfo, docType: NovaDocType.none));

    result.when(success: (value) {
      streamAdd(PresentModel(model: CommentListUseCaseModel(value.itemInfo)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
