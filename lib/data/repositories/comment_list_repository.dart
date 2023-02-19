import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/comment_list_item_response.dart';
// import 'package:ses_novajoj/networking/request/comment_list_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/comment_list_item.dart';
import 'package:ses_novajoj/domain/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/networking/api/base_nova_web_api.dart';
import 'package:ses_novajoj/networking/request/comment_item_parameter.dart';

class CommentListRepositoryImpl extends CommentListRepository {
  final BaseNovaWebApi _api;

  // sigleton
  static final CommentListRepositoryImpl _instance =
      CommentListRepositoryImpl._internal();
  CommentListRepositoryImpl._internal() : _api = BaseNovaWebApi();
  factory CommentListRepositoryImpl() => _instance;

  @override
  Future<Result<CommentListItem>> fetchCommentList(
      {required FetchCommentListRepoInput input}) async {
    final ret = await _api.fetchCommentInfos(
        parameter: CommentItemParameter(
            itemInfo: input.itemInfo, docType: input.docType));

    late Result<CommentListItem> result;
    ret.when(success: (response) {
      result =
          Result.success(data: CommentListItem(itemInfo: response.itemInfo));
    }, failure: (error) {
      result = Result.failure(error: error);
    });
    return result;
  }
}
