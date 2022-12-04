import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/networking/api/nova_web_api.dart';
import 'package:ses_novajoj/networking/response/nova_detalo_item_response.dart';
import 'package:ses_novajoj/networking/request/nova_detalo_parameter.dart';
import 'package:ses_novajoj/domain/entities/nova_detail_item.dart';
import 'package:ses_novajoj/domain/repositories/nova_detail_repository.dart';

class NovaDetailRepositoryImpl extends NovaDetailRepository {
  final NovaWebApi _api;

  // sigleton
  static final NovaDetailRepositoryImpl _instance =
      NovaDetailRepositoryImpl._internal();
  NovaDetailRepositoryImpl._internal() : _api = NovaWebApi();
  factory NovaDetailRepositoryImpl() => _instance;

  @override
  Future<Result<NovaDetailItem>> fetchNewsDetail(
      {required FetchNewsDetailRepoInput input}) async {
    Result<NovaDetaloItemRes?> result = await _api.fetchNovaDetail(
        parameter: NovaDetaloParameter(
            itemInfo: input.itemInfo, docType: input.docType));

    late Result<NovaDetailItem> ret;
    late NovaDetailItem retVal;

    result.when(success: (response) {
      if (response != null) {
        retVal = NovaDetailItem(
            itemInfo: () {
              NovaItemInfo info = response.itemInfo;
              final fnd = UserData()
                  .miscFavoritesList
                  .indexWhere((elem) => elem.contains(info.urlString));
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
