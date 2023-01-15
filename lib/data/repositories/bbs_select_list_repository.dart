import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/bbs_nova_web_api.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_select_list_repository.dart';

class BbsNovaSelectListRepositoryImpl extends BbsNovaSelectListRepository {
  final BbsNovaWebApi _api;

  // sigleton
  static final BbsNovaSelectListRepositoryImpl _instance =
      BbsNovaSelectListRepositoryImpl._internal();
  BbsNovaSelectListRepositoryImpl._internal() : _api = BbsNovaWebApi();
  factory BbsNovaSelectListRepositoryImpl() => _instance;

  @override
  Future<Result<List<BbsNovaSelectListItem>>> fetchBbsNovaSelectList(
      {required FetchBbsNovaSelectListRepoInput input}) async {
    String targetUrl =
        input.targetUrl.replaceAll('{{page}}', '${input.pageIndex}');
    final result = await _api.fetchSelectList(
        parameter:
            NovaItemParameter(targetUrl: targetUrl, docType: input.docType));
    List<BbsNovaSelectListItem> list = [];
    late Result<List<BbsNovaSelectListItem>> ret;

    result.when(success: (response) {
      for (var item in response) {
        BbsNovaSelectListItem retItem = BbsNovaSelectListItem(
          itemInfo: item.itemInfo,
        );
        retItem.itemInfo.pageCount =
            targetUrl == input.targetUrl ? 1 : 10; //default
        retItem.itemInfo.pageNumber = input.pageIndex;
        list.add(retItem);
      }
      ret = Result.success(data: list);
    }, failure: (error) {
      ret = Result.failure(error: error);
    });

    return ret;
  }
}
