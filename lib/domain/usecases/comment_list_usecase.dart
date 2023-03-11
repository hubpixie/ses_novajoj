import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/data/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'comment_list_usecase_output.dart';

class CommentListUseCaseInput {
  NovaItemInfo itemInfo;
  bool sortingByStepAsc;

  CommentListUseCaseInput(
      {required this.itemInfo, this.sortingByStepAsc = true});
}

abstract class CommentListUseCase with SimpleBloc<CommentListUseCaseOutput> {
  void fetchCommentList({required CommentListUseCaseInput input});
  void sortCommentList({required CommentListUseCaseInput input});
}

class CommentListUseCaseImpl extends CommentListUseCase {
  final CommentListRepositoryImpl repository;
  CommentListUseCaseImpl() : repository = CommentListRepositoryImpl();

  List<NovaComment>? _originalCommentList;
  @override
  void fetchCommentList({required CommentListUseCaseInput input}) async {
    final result = await repository.fetchCommentList(
        input: FetchCommentListRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.none));

    result.when(success: (value) {
      _originalCommentList = value.itemInfo.comments;
      value.itemInfo.comments = _originalCommentList?.reversed.toList();

      streamAdd(PresentModel(model: CommentListUseCaseModel(value.itemInfo)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  void sortCommentList({required CommentListUseCaseInput input}) {
    if (input.sortingByStepAsc) {
      input.itemInfo.comments = _originalCommentList?.reversed.toList();
    } else {
      input.itemInfo.comments = _originalCommentList;
    }
    streamAdd(PresentModel(model: CommentListUseCaseModel(input.itemInfo)));
  }
}
