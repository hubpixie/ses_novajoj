import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/thread_nova_web_api.dart';
import 'package:ses_novajoj/networking/response/thread_detalo_item_response.dart';
import 'package:ses_novajoj/networking/request/nova_detalo_parameter.dart';
import 'package:ses_novajoj/domain/entities/thread_nova_detail_item.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_detail_repository.dart';

class ThreadNovaDetailRepositoryImpl extends ThreadNovaDetailRepository {
  final ThreadNovaWebApi _api;

  // sigleton
  static final ThreadNovaDetailRepositoryImpl _instance =
      ThreadNovaDetailRepositoryImpl._internal();
  ThreadNovaDetailRepositoryImpl._internal() : _api = ThreadNovaWebApi();
  factory ThreadNovaDetailRepositoryImpl() => _instance;

  @override
  Future<Result<ThreadNovaDetailItem>> fetchThreadNovaDetail(
      {required FetchThreadNovaDetailRepoInput input}) async {
    Result<ThreadDetaloItemRes?> result = await _api.fetchThreadDetail(
        parameter: NovaDetaloParameter(
            itemInfo: input.itemInfo, docType: input.docType));

    late Result<ThreadNovaDetailItem> ret;
    late ThreadNovaDetailItem retVal;

    result.when(success: (response) {
      if (response != null) {
        retVal = ThreadNovaDetailItem(
            itemInfo: response.itemInfo, bodyString: response.bodyString);
      } else {
        assert(false, "Unresolved error: response is null");
      }
      ret = Result.success(data: retVal);
    }, failure: (error) {
      ret = Result.failure(error: error);
    });
    return ret;
  }
}
