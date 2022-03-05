import 'package:ses_novajoj/networking/api_client/api_result.dart';
import 'package:ses_novajoj/networking/api/nova_web_api.dart';
import 'package:ses_novajoj/networking/request/nova_detalo_parameter.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/nova_detail_item.dart';
import 'package:ses_novajoj/domain/repositories/nova_detail_repository.dart';
import 'package:ses_novajoj/networking/response/nova_detalo_item_response.dart';

class NovaDetailRepositoryImpl extends NovaDetailRepository {
  final NovaWebApi _api;

  // sigleton
  static final NovaDetailRepositoryImpl _instance =
      NovaDetailRepositoryImpl._internal();
  NovaDetailRepositoryImpl._internal() : _api = NovaWebApi();
  factory NovaDetailRepositoryImpl() => _instance;

  @override
  Future<NovaDetailItem> fetchNewsDetail(
      {required FetchNewsDetailRepoInput input}) async {
    Result<NovaDetaloItemRes?, NovaDomainReason> result =
        await _api.fetchNovaDetail(
            parameter: NovaDetaloParameter(
                itemInfo: input.itemInfo, docType: input.docType));

    late NovaDetailItem retVal;
    result.when(success: (response) {
      if (response != null) {
        retVal = NovaDetailItem(
            itemInfo: response.itemInfo, bodyString: response.bodyString);
      } else {
        assert(false, "Unresolved error: response is null");
      }
    }, failure: (code, description) {
      assert(false, "Unresolved error: $description");
    }, domainIssue: (reason) {
      assert(false, "Unexpected Semantic error: reason $reason");
    });
    return retVal;
  }
}
