import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/networking/api/nova_web_api.dart';
import 'package:ses_novajoj/networking/response/thread_nova_detail_response.dart';
import 'package:ses_novajoj/networking/request/thread_nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/thread_nova_detail_item.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_detail_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class ThreadNovaDetailRepositoryImpl extends ThreadNovaDetailRepository {
  final NovaWebApi _api;

  // sigleton
  static final ThreadNovaDetailRepositoryImpl _instance =
      ThreadNovaDetailRepositoryImpl._internal();
  ThreadNovaDetailRepositoryImpl._internal() : _api = NovaWebApi();
  factory ThreadNovaDetailRepositoryImpl() => _instance;

  @override
  Future<Result<ThreadNovaDetailItem>> fetchThreadNovaDetail(
      {required FetchThreadNovaDetailRepoInput input}) async {
    NovaItemInfo itemInfo = NovaItemInfo(
        id: 0,
        thunnailUrlString: "https://google.com",
        title: "title",
        urlString: "https://google.com",
        source: "source",
        author: '',
        createAt: DateTime.now(),
        loadCommentAt: '',
        commentUrlString: "commentUrlString",
        commentCount: 0,
        reads: 0,
        isNew: false,
        isRead: false);
    Result<ThreadNovaDetailItem> result = Result.success(
        data: ThreadNovaDetailItem(
            itemInfo: itemInfo, bodyString: "bodyString")); // TODO: call api
    // TODO: change api result for `ThreadNovaDetail' repository
    return result;
  }
}
