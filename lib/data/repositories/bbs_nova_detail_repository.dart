import 'dart:convert';

import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/networking/api/bbs_nova_web_api.dart';
import 'package:ses_novajoj/networking/response/bbs_detalo_item_response.dart';
import 'package:ses_novajoj/networking/request/nova_detalo_parameter.dart';
import 'package:ses_novajoj/domain/entities/bbs_nova_detail_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_detail_repository.dart';
import 'package:ses_novajoj/networking/response/historio_item_response.dart';

class BbsNovaDetailRepositoryImpl extends BbsNovaDetailRepository {
  final BbsNovaWebApi _api;

  // sigleton
  static final BbsNovaDetailRepositoryImpl _instance =
      BbsNovaDetailRepositoryImpl._internal();
  BbsNovaDetailRepositoryImpl._internal() : _api = BbsNovaWebApi();
  factory BbsNovaDetailRepositoryImpl() => _instance;

  @override
  Future<Result<BbsNovaDetailItem>> fetchBbsNovaDetail(
      {required FetchBbsNovaDetailRepoInput input}) async {
    Result<BbsDetaloItemRes?> result = await _api.fetchBbsDetail(
        parameter: NovaDetaloParameter(
            itemInfo: input.itemInfo, docType: input.docType));

    late Result<BbsNovaDetailItem> ret;
    late BbsNovaDetailItem retVal;

    result.when(success: (response) {
      if (response != null) {
        retVal = BbsNovaDetailItem(
            itemInfo: response.itemInfo, bodyString: response.bodyString);
        // save historio
        _saveHistory(detailItem: retVal);
      } else {
        assert(false, "Unresolved error: response is null");
      }
      ret = Result.success(data: retVal);
    }, failure: (error) {
      ret = Result.failure(error: error);
    });
    return ret;
  }

  void _saveHistory({BbsNovaDetailItem? detailItem}) {
    if (detailItem != null) {
      HistorioInfo historioInfo = () {
        HistorioInfo info = HistorioInfo();
        info.category = 'bbs';
        info.id = info.hashCode;
        info.createdAt = DateTime.now();
        info.itemInfo = detailItem.itemInfo;
        return info;
      }();
      HistorioItemRes historioItemRes = HistorioItemRes.as(info: historioInfo);
      final json = historioItemRes.toJson();
      final encoded = jsonEncode(json);
      UserData().insertHistorio(historio: encoded);
    }
  }
}
