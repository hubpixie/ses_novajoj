import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/local_nova_web_api.dart';
import 'package:ses_novajoj/networking/response/local_nova_list_response.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/local_nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/local_nova_list_repository.dart';

class LocalNovaListRepositoryImpl extends LocalNovaListRepository {
  final LocalNovaWebApi _api;

  // sigleton
  static final LocalNovaListRepositoryImpl _instance =
      LocalNovaListRepositoryImpl._internal();
  LocalNovaListRepositoryImpl._internal() : _api = LocalNovaWebApi();
  factory LocalNovaListRepositoryImpl() => _instance;

  @override
  Future<Result<List<LocalNovaListItem>>> fetchLocalNovaList(
      {required FetchLocalNovaListRepoInput input}) async {
    String targetUrl =
        input.targetUrl.replaceAll('{{page}}', '${input.pageIndex}');
    Result<List<LocalNovaListItemRes>> result = await _api.fetchNovaList(
        parameter:
            NovaItemParameter(targetUrl: targetUrl, docType: input.docType));

    late Result<List<LocalNovaListItem>> ret;
    List<LocalNovaListItem> novaItems = <LocalNovaListItem>[];
    result.when(success: (response) {
      for (var item in response) {
        LocalNovaListItem retItem = LocalNovaListItem(
          itemInfo: item.itemInfo,
        );
        retItem.itemInfo.pageCount =
            targetUrl == input.targetUrl ? 1 : 10; //default
        retItem.itemInfo.pageNumber = input.pageIndex;
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
      {required FetchLocalNovaListRepoInput input}) async {
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
