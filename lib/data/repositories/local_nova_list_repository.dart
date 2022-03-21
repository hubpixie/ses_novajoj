import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/local_nova_web_api.dart';
import 'package:ses_novajoj/networking/response/local_nova_list_response.dart';
import 'package:ses_novajoj/networking/request/local_nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/local_nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/local_nova_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`

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
    Result<List<LocalNovaListItemRes>> result = await _api.fetchNovaList(
        parameter: LocalNovaItemParameter(
            targetUrl: input.targetUrl, docType: input.docType));

    late Result<List<LocalNovaListItem>> ret;
    List<LocalNovaListItem> novaItems = <LocalNovaListItem>[];
    result.when(success: (response) {
      for (var item in response) {
        LocalNovaListItem retItem = LocalNovaListItem(
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

  Future<Result<String>> fetchThumbUrl(
      {required FetchLocalNovaListRepoInput input}) async {
    Result<String> result = await _api.fetchNovaItemThumbUrl(
        parameter: LocalNovaItemParameter(
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
