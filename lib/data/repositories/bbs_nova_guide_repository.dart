import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/bbs_nova_web_api.dart';
import 'package:ses_novajoj/networking/response/bbs_nova_guide_response.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/bbs_guide_list_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_guide_repository.dart';

class MyWebApi {}

class BbsNovaGuideRepositoryImpl extends BbsNovaGuideRepository {
  final BbsNovaWebApi _api;

  // sigleton
  static final BbsNovaGuideRepositoryImpl _instance =
      BbsNovaGuideRepositoryImpl._internal();
  BbsNovaGuideRepositoryImpl._internal() : _api = BbsNovaWebApi();
  factory BbsNovaGuideRepositoryImpl() => _instance;

  @override
  Future<Result<List<BbsGuideListItem>>> fetchBbsNovaGuideList(
      {required FetchBbsGuideRepoInput input}) async {
    Result<List<BbsNovaGuideItemRes>> result = await _api.fetchNovaList(
        parameter: NovaItemParameter(
            targetUrl: input.targetUrl, docType: input.docType));

    late Result<List<BbsGuideListItem>> ret;
    List<BbsGuideListItem> novaItems = <BbsGuideListItem>[];
    result.when(success: (response) {
      for (var item in response) {
        BbsGuideListItem retItem = BbsGuideListItem(
          itemInfo: item.itemInfo,
        );
        novaItems.add(retItem);
      }
      ret = Result.success(data: novaItems);
    }, failure: (error) {
      ret = Result.failure(error: error);
    });

    return ret;
  }

  @override
  Future<Result<String>> fetchThumbUrl(
      {required FetchBbsGuideRepoInput input}) async {
    Result<String> result = await _api.fetchNovaItemThumbUrl(
        parameter: NovaItemParameter(
            targetUrl: input.targetUrl, docType: input.docType));

    late Result<String> ret;
    String retUrl = "";
    result.when(success: (response) {
      retUrl = response;
      ret = Result.success(data: retUrl);
    }, failure: (error) {
      ret = Result.failure(error: error);
    });

    return ret;
  }
}
