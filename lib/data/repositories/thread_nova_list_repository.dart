import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/thread_nova_item_response.dart';
// import 'package:ses_novajoj/networking/request/thread_nova_list_parameter.dart';
import 'package:ses_novajoj/domain/entities/thread_nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class ThreadNovaListRepositoryImpl extends ThreadNovaListRepository {
  final MyWebApi _api;

  // sigleton
  static final ThreadNovaListRepositoryImpl _instance =
      ThreadNovaListRepositoryImpl._internal();
  ThreadNovaListRepositoryImpl._internal() : _api = MyWebApi();
  factory ThreadNovaListRepositoryImpl() => _instance;

  @override
  Future<Result<List<ThreadNovaListItem>>> fetchThreadNovaList(
      {required FetchThreadNovaListRepoInput input}) async {
    int id = 9999;
    String thunnailUrlString = "";
    String title = "";
    String urlString = "";
    String source = "";
    String commentUrlString = "";
    int commentCount = 0;
    DateTime? createAt;
    int reads = 0;
    bool isRead = false;
    bool isNew = false;

    NovaItemInfo itemInfo = NovaItemInfo(
        id: id,
        thunnailUrlString: thunnailUrlString,
        title: title,
        urlString: urlString,
        source: source,
        author: '',
        createAt: createAt ?? DateTime.now(),
        loadCommentAt: '',
        commentUrlString: commentUrlString,
        commentCount: commentCount,
        reads: reads,
        isNew: isNew,
        isRead: isRead);

    Result<List<ThreadNovaListItem>> result = Result.success(
        data: [ThreadNovaListItem(itemInfo: itemInfo)]); // TODO: call api

    // TODO: change api result for `ThreadNovaList' repository
    return result;
  }

  @override
  Future<Result<String>> fetchThumbUrl(
      {required FetchThreadNovaListRepoInput input}) async {
    String retUrl = "";
    return Result.success(data: retUrl);
  }
}
