import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/bbs_select_list_item_response.dart';
// import 'package:ses_novajoj/networking/request/bbs_select_list_parameter.dart';
import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_select_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class BbsNovaSelectListRepositoryImpl extends BbsNovaSelectListRepository {
  final MyWebApi _api;

  // sigleton
  static final BbsNovaSelectListRepositoryImpl _instance =
      BbsNovaSelectListRepositoryImpl._internal();
  BbsNovaSelectListRepositoryImpl._internal() : _api = MyWebApi();
  factory BbsNovaSelectListRepositoryImpl() => _instance;

  @override
  Future<Result<List<BbsNovaSelectListItem>>> fetchBbsNovaSelectList(
      {required FetchBbsNovaSelectListRepoInput input}) async {
    List<BbsNovaSelectListItem> ret = [];

    Result<List<BbsNovaSelectListItem>> result = Result.success(data: ret);

    return result;
  }
}
