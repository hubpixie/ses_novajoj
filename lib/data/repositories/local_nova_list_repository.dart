import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/local_nova_item_response.dart';
// import 'package:ses_novajoj/networking/request/local_nova_list_parameter.dart';
import 'package:ses_novajoj/domain/entities/local_nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/local_nova_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class LocalNovaListRepositoryImpl extends LocalNovaListRepository {
  final MyWebApi _api;

  // sigleton
  static final LocalNovaListRepositoryImpl _instance =
      LocalNovaListRepositoryImpl._internal();
  LocalNovaListRepositoryImpl._internal() : _api = MyWebApi();
  factory LocalNovaListRepositoryImpl() => _instance;

  @override
  Future<Result<List<LocalNovaListItem>>> fetchLocalNovaList(
      {required FetchLocalNovaListRepoInput input}) async {
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

    Result<List<LocalNovaListItem>> result = Result.success(
        data: [LocalNovaListItem(itemInfo: itemInfo)]); // TODO: call api

    // TODO: change api result for `LocalNovaList' repository
    return result;
  }

  Future<Result<String>> fetchThumbUrl(
      {required FetchLocalNovaListRepoInput input}) async {
    String retUrl = "";
    return Result.success(data: retUrl);
  }
}
