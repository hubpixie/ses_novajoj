import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/comment_list_item_response.dart';
// import 'package:ses_novajoj/networking/request/comment_list_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/comment_list_item.dart';
import 'package:ses_novajoj/domain/repositories/comment_list_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class CommentListRepositoryImpl extends CommentListRepository {
  final MyWebApi _api;

  // sigleton
  static final CommentListRepositoryImpl _instance =
      CommentListRepositoryImpl._internal();
  CommentListRepositoryImpl._internal() : _api = MyWebApi();
  factory CommentListRepositoryImpl() => _instance;

  @override
  Future<Result<CommentListItem>> fetchCommentList(

      {required FetchCommentListRepoInput input}) async {
    Result<CommentListItem> result =
        Result.success(data: CommentListItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `CommentList' repository
    return result;
  }
}
