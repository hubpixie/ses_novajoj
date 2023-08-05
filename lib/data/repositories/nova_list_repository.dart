import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/nova_web_api.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/nova_list_repository.dart';
import 'package:ses_novajoj/networking/response/nova_list_response.dart';

class NovaListRepositoryImpl extends NovaListRepository {
  final NovaWebApi _api;
  int _estimatedPageCnt = 50;
  String _prevSearchedKeyword = '';

  // sigleton
  static final NovaListRepositoryImpl _instance =
      NovaListRepositoryImpl._internal();
  NovaListRepositoryImpl._internal() : _api = NovaWebApi();
  factory NovaListRepositoryImpl() => _instance;

  @override
  Future<Result<List<NovaListItem>>> fetchNewsList(
      {required FetchNewsListRepoInput input}) async {
    String targetUrl = input.searchedKeyword.isNotEmpty
        ? input.searchedUrl.replaceAll('{{page}}', '${input.pageIndex}')
        : input.targetUrl.replaceAll('{{page}}', '${input.pageIndex}');

    List<NovaListItem> list = [];
    late Result<List<NovaListItem>> ret;

    Result<List<NovaListItem>> setReturnVal<T>(T response, bool searched) {
      if (response is List) {
        for (var item in response) {
          NovaListItem retItem = NovaListItem(
            itemInfo: item.itemInfo,
          );
          retItem.itemInfo.pageCount = () {
            int retCnt =
                targetUrl == input.targetUrl ? 1 : _estimatedPageCnt; //default
            if (searched) {
              if (response.length >= 100) {
                retCnt = 10;
              } else {
                retCnt = input.pageIndex;
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
        _estimatedPageCnt = 10; // default value
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
      _estimatedPageCnt = 50; // default value
      // fetch next page data
      Result<List<NovaListItemRes>> result = await _api.fetchNovaList(
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
