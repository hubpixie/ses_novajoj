import 'package:ses_novajoj/domain/entities/comment_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchCommentListRepoInput {
  Object id;
  String string;

  FetchCommentListRepoInput({required this.id, required this.string});
}

abstract class CommentListRepository {
  Future<Result<CommentListItem>> fetchCommentList(
      {required FetchCommentListRepoInput input});
}
