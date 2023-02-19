import 'package:ses_novajoj/domain/entities/comment_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchCommentListRepoInput {
  NovaItemInfo itemInfo;
  NovaDocType docType;

  FetchCommentListRepoInput({required this.itemInfo, required this.docType});
}

abstract class CommentListRepository {
  Future<Result<CommentListItem>> fetchCommentList(
      {required FetchCommentListRepoInput input});
}
