import 'dart:async';
import 'dart:io';
import 'package:async/async.dart' as future_ext;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:ses_novajoj/foundation//log_util.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/foundation/data/number_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api_client/base_api_client.dart';
import 'package:ses_novajoj/networking/api/base_nova_web_api.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/networking/request/nova_detalo_parameter.dart';
import 'package:ses_novajoj/networking/response/bbs_nova_guide_response.dart';
import 'package:ses_novajoj/networking/response/bbs_select_list_response.dart';
import 'package:ses_novajoj/networking/response/bbs_detalo_item_response.dart';

part 'bbs_nova_web_api_detalo.dart';
part 'bbs_nova_web_api_select.dart';

class BbsNovaWebApi extends BaseNovaWebApi {
  static const int _kThumbLimit = 5;

  ///
  /// api entry: fetchNovaList
  ///
  Future<Result<List<BbsNovaGuideItemRes>>> fetchNovaList(
      {required NovaItemParameter parameter}) async {
    try {
      // check network state
      final networkState = await BaseApiClient.connectivityState();
      if (networkState == ConnectivityResult.none) {
        throw const SocketException('Network is unavailable!');
      }

      // send request for fetching nova list.
      final response =
          await BaseApiClient.client.get(Uri.parse(parameter.targetUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }
      // prepares to parse nova list from response.body.
      final document = html_parser.parse(response.body);
      List<BbsNovaGuideItemRes> retArr = [];

      if (parameter.docType == NovaDocType.bbsList ||
          parameter.docType == NovaDocType.bbsEtcList) {
        return _parseLiItems(parameter: parameter, rootElement: document.body);
      }

      return Result.success(data: retArr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ///  <div id="d_list"  class="main_right_margin">
  /// document.write('　☉[XXXX]<a href=\"https://club.6parkbbs.com/nz/index.php?app=forum&act=threadview&tid=913842\">BBS BBS BBS</a><br>
  /// ☉[XXXX]<a href=\"https://club.6parkbbs.com/nz/index.php?app=forum&act=threadview&tid=915210\">(活动)邓胡赵恩怨对BBS BBS BBS</a><br>
  /// <span style=\"float:right;FONT-SIZE:12px\"><a href=https://club.6parkbbs.com/indexorgposts.php><font color=grey>More..</font></a></span><br>');
  Future<Result<List<BbsNovaGuideItemRes>>> _parseLiItems(
      {required NovaItemParameter parameter, Element? rootElement}) async {
    try {
      List<BbsNovaGuideItemRes> retArr = [];

      if (rootElement?.children == null) {
        log.severe('rootElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }

      int index = 0;
      for (Element al in rootElement?.children ?? []) {
        BbsNovaGuideItemRes? novaListItemRes;
        if (parameter.docType == NovaDocType.bbsList) {
          novaListItemRes = await _createBbsGuideLiItem(parameter.targetUrl,
              index: index, aLink: al);
        } else if (parameter.docType == NovaDocType.bbsEtcList) {
          novaListItemRes = await _createBbsGuideEtcLiItem(parameter.targetUrl,
              index: index, aLink: al);
        }
        if (novaListItemRes != null &&
            novaListItemRes.itemInfo.title.isNotEmpty) {
          retArr.add(novaListItemRes);
          index++;
        }
      }

      return Result.success(data: retArr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  Future<BbsNovaGuideItemRes?> _createBbsGuideLiItem(String url,
      {required int index, required Element aLink}) async {
    int id = index;
    String thunnailUrlString = "";
    String title = "";
    String urlString = "";
    String source = "";
    String commentUrlString = "";
    int commentCount = 0;
    DateTime? createAt;
    int reads = 0;
    bool isRead = false;
    bool isNew = false;

    // title, urlString
    if (aLink.innerHtml.isNotEmpty) {
      title = () {
        String retStr = '${index + 1} ';
        retStr += aLink.innerHtml;
        retStr = retStr.replaceAll('&nbsp;', ' ').trim();
        retStr = retStr.replaceAll('&amp;', '&');
        return retStr;
      }();

      urlString = () {
        String str = aLink.attributes['href'] ?? '';
        str = str.replaceAll('\\"', '');
        return str;
      }();
    }

    // source
    if (aLink.innerHtml.isNotEmpty) {
      source = () {
        return StringUtil().substring(aLink.innerHtml, start: '☉[', end: ']');
      }();
    }

    if (source.isEmpty || source.contains(RegExp(r'http(s)*:\/\/'))) {
      return null;
    }

    // thumbUrlString
    if (title.isNotEmpty) {
      if (urlString.isNotEmpty && index < _kThumbLimit) {
        Result<String> thumbUrlResult = await fetchNovaItemThumbUrl(
            parameter: NovaItemParameter(
                targetUrl: urlString, docType: NovaDocType.thumb));
        thumbUrlResult.when(
            success: (value) {
              thunnailUrlString = value;
            },
            failure: (value) {});
      }
    }

    NovaItemInfo itemInfo = NovaItemInfo(
        id: id,
        thunnailUrlString: thunnailUrlString,
        title: title,
        urlString: urlString,
        source: source,
        author: '',
        createAt: createAt ?? DateTime.now(),
        loadCommentAt: '',
        commentUrlString: commentUrlString,
        commentCount: commentCount,
        reads: reads,
        isNew: isNew,
        isRead: isRead);
    return BbsNovaGuideItemRes(itemInfo: itemInfo);
  }

  Future<BbsNovaGuideItemRes?> _createBbsGuideEtcLiItem(String url,
      {required int index, required Element aLink}) async {
    int id = index;
    String thunnailUrlString = "";
    String title = "";
    String urlString = "";
    String source = "";
    String commentUrlString = "";
    int commentCount = 0;
    DateTime? createAt;
    int reads = 0;
    bool isRead = false;
    bool isNew = false;

    // title, urlString
    if (aLink.innerHtml.isNotEmpty) {
      title = () {
        String retStr = '${index + 1} ';
        retStr +=
            '☉[${StringUtil().substring(aLink.innerHtml, start: '>[', end: ']<')}]'; //item_source type
        retStr += StringUtil()
            .substring(aLink.innerHtml, start: '', end: ' <span')
            .replaceAll(RegExp(r'^[0-9]*[0-9]{1} +'), '');
        retStr = retStr.replaceAll('&nbsp;', ' ').trim();
        retStr = retStr.replaceAll('&amp;', '&');
        return retStr;
      }();

      urlString = () {
        String str = aLink.attributes['href'] ?? '';
        str = str.replaceAll('\\"', '');
        return str;
      }();
    }

    // source
    if (aLink.innerHtml.isNotEmpty) {
      source = () {
        String retStr =
            StringUtil().substring(aLink.innerHtml, start: '>[', end: ']<');
        return retStr;
      }();
    }

    // thumbUrlString
    if (urlString.isNotEmpty && index < _kThumbLimit) {
      Result<String> thumbUrlResult = await fetchNovaItemThumbUrl(
          parameter: NovaItemParameter(
              targetUrl: urlString, docType: NovaDocType.thumb));
      thumbUrlResult.when(
          success: (value) {
            thunnailUrlString = value;
          },
          failure: (value) {});
    }

    NovaItemInfo itemInfo = NovaItemInfo(
        id: id,
        thunnailUrlString: thunnailUrlString,
        title: title,
        urlString: urlString,
        source: source,
        author: '',
        createAt: createAt ?? DateTime.now(),
        loadCommentAt: '',
        commentUrlString: commentUrlString,
        commentCount: commentCount,
        reads: reads,
        isNew: isNew,
        isRead: isRead);
    return BbsNovaGuideItemRes(itemInfo: itemInfo);
  }
}
