import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/thread_nova_web_api.dart';
import 'package:ses_novajoj/networking/response/thread_nova_list_response.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/thread_nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_list_repository.dart';

class ThreadNovaListRepositoryImpl extends ThreadNovaListRepository {
  final ThreadNovaWebApi _api;

  // sigleton
  static final ThreadNovaListRepositoryImpl _instance =
      ThreadNovaListRepositoryImpl._internal();
  ThreadNovaListRepositoryImpl._internal() : _api = ThreadNovaWebApi();
  factory ThreadNovaListRepositoryImpl() => _instance;

  @override
  Future<Result<List<ThreadNovaListItem>>> fetchThreadNovaList(
      {required FetchThreadNovaListRepoInput input}) async {
    Result<List<ThreadNovaListItemRes>> result = await _api.fetchNovaList(
        parameter: NovaItemParameter(
            targetUrl: input.targetUrl, docType: input.docType));

    late Result<List<ThreadNovaListItem>> ret;
    List<ThreadNovaListItem> novaItems = <ThreadNovaListItem>[];
    result.when(success: (response) {
      for (var item in response) {
        ThreadNovaListItem retItem = ThreadNovaListItem(
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
      {required FetchThreadNovaListRepoInput input}) async {
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
