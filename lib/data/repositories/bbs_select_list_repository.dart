import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/bbs_nova_web_api.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_select_list_repository.dart';

class BbsNovaSelectListRepositoryImpl extends BbsNovaSelectListRepository {
  final BbsNovaWebApi _api;
  int _estimatedPageCnt = 10;
  String _prevSearchedKeyword = '';

  // sigleton
  static final BbsNovaSelectListRepositoryImpl _instance =
      BbsNovaSelectListRepositoryImpl._internal();
  BbsNovaSelectListRepositoryImpl._internal() : _api = BbsNovaWebApi();
  factory BbsNovaSelectListRepositoryImpl() => _instance;

  @override
  Future<Result<List<BbsNovaSelectListItem>>> fetchBbsNovaSelectList(
      {required FetchBbsNovaSelectListRepoInput input}) async {
    String targetUrl =
        input.targetUrl.replaceAll('{{page}}', '${input.pageIndex}');

    List<BbsNovaSelectListItem> list = [];
    late Result<List<BbsNovaSelectListItem>> ret;

    Result<List<BbsNovaSelectListItem>> setReturnVal<T>(
        T response, bool searched) {
      if (response is List) {
        for (var item in response) {
          BbsNovaSelectListItem retItem = BbsNovaSelectListItem(
            itemInfo: item.itemInfo,
          );
          retItem.itemInfo.pageCount = () {
            int retCnt =
                targetUrl == input.targetUrl ? 1 : _estimatedPageCnt; //default
            if (searched) {
              if (response.length > 90) {
                retCnt = input.pageIndex + 1;
              } else {
                retCnt = 1;
              }
              _estimatedPageCnt = retCnt;
            }
            retCnt = _estimatedPageCnt > retCnt ? _estimatedPageCnt : retCnt;
            return retCnt;
          }();
          retItem.itemInfo.pageNumber = input.pageIndex;
          list.add(retItem);
        }
        return Result.success(data: list);
      } else {
        return const Result.success(data: []);
      }
    }

    if (targetUrl.contains('{{keywords}}')) {
      if (_prevSearchedKeyword.isEmpty) {
        _prevSearchedKeyword = input.searchedKeyword;
      }
      // if targetUrl is different from previos one except '&p99', reset _estimatedPageCnt as default.
      if (_prevSearchedKeyword != input.searchedKeyword) {
        _prevSearchedKeyword = input.searchedKeyword;
        _estimatedPageCnt = 10; // defalut value
      }
      // fetch next page data
      targetUrl = targetUrl.replaceAll('{{keywords}}', input.searchedKeyword);
      final result = await _api.fetchSearchedResult(
          parameter:
              NovaItemParameter(targetUrl: targetUrl, docType: input.docType));
      result.when(success: (response) {
        ret = setReturnVal(response, true);
      }, failure: (error) {
        ret = Result.failure(error: error);
      });
    } else {
      _estimatedPageCnt = 10; // default value
      // fetch next page data
      final result = await _api.fetchSelectList(
          parameter:
              NovaItemParameter(targetUrl: targetUrl, docType: input.docType));
      result.when(success: (response) {
        ret = setReturnVal(response, false);
      }, failure: (error) {
        ret = Result.failure(error: error);
      });
    }

    return ret;
  }
}
