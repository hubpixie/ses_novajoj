import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/bbs_nova_item_response.dart';
// import 'package:ses_novajoj/networking/request/bbs_nova_detail_parameter.dart';
import 'package:ses_novajoj/domain/entities/bbs_nova_detail_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_detail_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class BbsNovaDetailRepositoryImpl extends BbsNovaDetailRepository {
  final MyWebApi _api;

  // sigleton
  static final BbsNovaDetailRepositoryImpl _instance =
      BbsNovaDetailRepositoryImpl._internal();
  BbsNovaDetailRepositoryImpl._internal() : _api = MyWebApi();
  factory BbsNovaDetailRepositoryImpl() => _instance;

  @override
  Future<Result<BbsNovaDetailItem>> fetchBbsNovaDetail(

      {required FetchBbsNovaDetailRepoInput input}) async {
    Result<BbsNovaDetailItem> result =
        Result.success(data: BbsNovaDetailItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `BbsNovaDetail' repository
    return result;
  }
}
