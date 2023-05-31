import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
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
    final favorList = await UserData().miscFavoritesList;

    result.when(success: (response) {
      if (response != null) {
        retVal = ThreadNovaDetailItem(
            itemInfo: () {
              NovaItemInfo info = response.itemInfo;
              final fnd =
                  favorList.indexWhere((elem) => elem.contains(info.urlString));
              info.isFavorite = fnd >= 0;
              return info;
            }(),
            bodyString: response.bodyString);
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
