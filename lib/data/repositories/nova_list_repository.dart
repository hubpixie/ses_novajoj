import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/nova_web_api.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/nova_list_repository.dart';
import 'package:ses_novajoj/networking/response/nova_list_response.dart';

class NovaListRepositoryImpl extends NovaListRepository {
  final NovaWebApi _api;

  // sigleton
  static final NovaListRepositoryImpl _instance =
      NovaListRepositoryImpl._internal();
  NovaListRepositoryImpl._internal() : _api = NovaWebApi();
  factory NovaListRepositoryImpl() => _instance;

  @override
  Future<Result<List<NovaListItem>>> fetchNewsList(
      {required FetchNewsListRepoInput input}) async {
    // Future.delayed(
    //     Duration(milliseconds: NumberUtil().randomInt(min: 2500, max: 3500)));
    Result<List<NovaListItemRes>> result = await _api.fetchNovaList(
        parameter: NovaItemParameter(
            targetUrl: input.targetUrl, docType: input.docType));

    late Result<List<NovaListItem>> ret;
    List<NovaListItem> novaItems = <NovaListItem>[];
    result.when(success: (response) {
      for (var item in response) {
        NovaListItem retItem = NovaListItem(
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
      {required FetchNewsListRepoInput input}) async {
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
