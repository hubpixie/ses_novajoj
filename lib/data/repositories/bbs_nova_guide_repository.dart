import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/bbs_guide_item_response.dart';
// import 'package:ses_novajoj/networking/request/bbs_nova_guide_parameter.dart';
import 'package:ses_novajoj/domain/entities/bbs_guide_list_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_guide_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class BbsNovaGuideRepositoryImpl extends BbsNovaGuideRepository {
  final MyWebApi _api;

  // sigleton
  static final BbsNovaGuideRepositoryImpl _instance =
      BbsNovaGuideRepositoryImpl._internal();
  BbsNovaGuideRepositoryImpl._internal() : _api = MyWebApi();
  factory BbsNovaGuideRepositoryImpl() => _instance;

  @override
  Future<Result<List<BbsGuideListItem>>> fetchBbsNovaGuideList(
      {required FetchBbsGuideRepoInput input}) async {
    NovaItemInfo itemInfo = NovaItemInfo(
        id: 0,
        thunnailUrlString: 'http://www.google.com',
        title: 'title',
        urlString: 'http://www.google.com',
        source: 'source',
        author: '',
        createAt: DateTime.now(),
        loadCommentAt: '',
        commentUrlString: 'commentUrlString',
        commentCount: 0,
        reads: 0,
        isNew: false,
        isRead: false);

    Result<List<BbsGuideListItem>> result = Result.success(
        data: [BbsGuideListItem(itemInfo: itemInfo)]); // TODO: call api

    return result;
  }

  @override
  Future<Result<String>> fetchThumbUrl(
      {required FetchBbsGuideRepoInput input}) async {
    String retUrl = "";
    return Result.success(data: retUrl);
  }
}
