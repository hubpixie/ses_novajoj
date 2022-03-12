import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:ses_novajoj/foundation//log_util.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/number_ntil.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api_client/base_api_client.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/networking/request/nova_detalo_parameter.dart';
import 'package:ses_novajoj/networking/response/nova_list_response.dart';
import 'package:ses_novajoj/networking/response/nova_detalo_item_response.dart';

part 'nova_web_api_detalo.dart';

class NovaWebApi {
  static const int _kThumbLimit = 5;

  ///
  /// api entry: fetchNovaList
  ///
  Future<Result<List<NovaListItemRes>>> fetchNovaList(
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
      List<NovaListItemRes> retArr = [];

      if (parameter.docType == NovaDocType.list) {
        return _parseLiItems(
            parameter: parameter,
            rootElement: document.getElementById("d_list"));
      } else if (parameter.docType == NovaDocType.table) {
        return _parseTrItems(
            parameter: parameter,
            rootElement: document.getElementById("d_list"));
      }

      return Result.success(data: retArr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ///
  /// api entry: fetchNovaItemThumbUrl
  ///
  /// <div id='shownewsc' style="margin:15px;">
  /// 			新闻新闻新闻新闻新闻。<br />
  /// <br />
  /// 新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  /// <br />
  /// <center><img onload='javascript:if(this.width>600) this.width=600'  src="https://web.popo8.com/202202/13/0/47c5918239type_jpeg_size_220_100_end.jpg"/><br />
  /// </center><br />
  /// 新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  /// <br />
  /// 新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  /// <br />
  /// 新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻<br />
  /// <center><br />
  /// <img onload='javascript:if(this.width>600) this.width=600'  src="https://web.popo8.com/202202/13/9/54795a8d62type_jpeg_size_1080_210_end.jpg"/><br />
  /// <br />
  /// 图源：Hello BC</center><br />
  /// <br />
  /// 新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  /// 			<div>
  /// 				<div class="OUTBRAIN" data-src="DROP_PERMALINK_HERE" data-widget-id="AR_1"></div> <script type="text/javascript" async="async" src="//widgets.outbrain.com/outbrain.js"></script>
  /// 			</div>
  /// 			</div>
  ///
  Future<Result<String>> fetchNovaItemThumbUrl(
      {required NovaItemParameter parameter}) async {
    try {
      // send request for fetching nova item's thumb url.
      final response =
          await BaseApiClient.client.get(Uri.parse(parameter.targetUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }

      // prepares to parse nova list from response.body.
      final document = html_parser.parse(response.body);
      final imgElements = document.getElementsByTagName('img');
      if (imgElements.isEmpty) {
        log.warning('imgElements.isEmpty');
        throw AppError(
            type: AppErrorType.dataError, reason: FailureReason.missingImgNode);
      }
      final imgElement = imgElements
          .firstWhere((element) => element.attributes['onload'] != null);
      String retStr = imgElement.attributes['src'] ?? '';
      return Result.success(data: retStr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ///  <div id="d_list"  class="main_right_margin">
  /// 		<div style='height:30px;line-height:30px;background:#EDEDED;'>
  /// 			<center>
  ///        <font color="#990000">◇<a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=532605">[最新评论新闻] 新闻新闻新闻新闻新闻新闻</a> ◇ <a href="index.php?act=newsreply&nid=532605">-->查看评论 [目前共226个评论]</a> ◇ <a href="index.php?act=gonggao">--> 新闻公告 <--</a>◇</font>
  ///       </center>
  /// 		</div>
  /// 		<ul>
  /// 			<li><a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=532639">新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻(组图)</a> - 阑夕  (12224 bytes)  - <i>02/13/22</i>  (108 reads)</li>
  ///       <li><a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=532638">新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻(图)</a> - 加拿大留学生问吧  (5348 bytes)  - <i>02/13/22</i>  (2099 reads)  <a class='list_reimg' href='index.php?act=newsreply&nid=532638'>1</a></li>
  ///     </ul>
  /// </div>
  Future<Result<List<NovaListItemRes>>> _parseLiItems(
      {required NovaItemParameter parameter, Element? rootElement}) async {
    try {
      List<NovaListItemRes> retArr = [];

      if (rootElement?.children == null) {
        log.severe('rootElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }
      final ulElement = rootElement?.children
          .firstWhere((element) => element.localName == 'ul');

      if (ulElement?.children == null) {
        log.severe('ulElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingListNode);
      }
      int index = 0;
      for (Element li in ulElement?.children ?? []) {
        NovaListItemRes? novaListItemRes =
            await _createNovaLiItem(parameter.targetUrl, index: index, li: li);
        if (novaListItemRes != null) {
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

  Future<NovaListItemRes?> _createNovaLiItem(String url,
      {required int index, required Element li}) async {
    NovaListItemRes? retNovaItem;
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

    List<Element> liSubElements = li.children;
    int liCount = liSubElements.length;
    String parentUrl = _parentUrl(url: url);

    // title, urlString
    if (liCount > 0 && liSubElements[0].localName == 'a') {
      title = liSubElements[0].innerHtml;
      urlString = liSubElements[0].attributes["href"] ?? "";
      if (!urlString.contains(parentUrl)) {
        return retNovaItem;
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
    }

    // createAt
    if (liCount > 1 && liSubElements[1].localName == 'i') {
      createAt = DateUtil().fromString(liSubElements[1].innerHtml);
    }

    // commentUrlString, commentCount
    if (liCount > 2 && liSubElements[2].localName == 'a') {
      String tmpUrl = liSubElements[2].attributes["href"] ?? "";
      commentUrlString = parentUrl + tmpUrl;

      commentCount =
          NumberUtil().parseInt(string: liSubElements[2].innerHtml) ?? 0;
    }

    // source, reads
    if (li.innerHtml.isNotEmpty) {
      source =
          StringUtil().substring(li.innerHtml, start: "</a> - ", end: "  (");

      String readsStr = StringUtil()
          .substring(li.innerHtml, start: "</i>  (", end: " reads)");
      reads = NumberUtil().parseInt(string: readsStr) ?? 0;
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
    return NovaListItemRes(itemInfo: itemInfo);
  }

  ///  <div id="d_list"  class="main_right_margin">
  /// 		<table  width="100%" cols="3" align="center" class=dc_bar cellspacing="3" cellpadding="5" bgcolor="#FFFFFF">
  /// 		...
  ///       <tr bgcolor=#EDEDED><td>第1位</td><td><a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=534088">新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻(组图)</a> <i>02/21/22</i></td><td><center>269856 reads</center></td><td><center>439 次</center></td><td><center><a href="index.php?act=newsreply&nid=534088">查看评论</a></center></td></tr>
  /// 	    <tr ><td>第2位</td><td><a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=533413">新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻(组图)</a> <i>02/17/22</i></td><td><center>195733 reads</center></td><td><center>102 次</center></td><td><center><a href="index.php?act=newsreply&nid=533413">查看评论</a></center></td></tr>
  /// 	    <tr bgcolor=#EDEDED><td>第3位</td><td><a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=533870">新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻(组图)</a> <i>02/20/22</i></td><td><center>169381 reads</center></td><td><center>161 次</center></td><td><center><a href="index.php?act=newsreply&nid=533870">查看评论</a></center></td></tr>
  /// 	    <tr ><td>第4位</td><td><a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=533246">新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻(组图)</a> <i>02/16/22</i></td><td><center>161002 reads</center></td><td><center>89 次</center></td><td><center><a href="index.php?act=newsreply&nid=533246">查看评论</a></center></td></tr>
  ///     </table>
  /// </div>
  Future<Result<List<NovaListItemRes>>> _parseTrItems(
      {required NovaItemParameter parameter, Element? rootElement}) async {
    try {
      List<NovaListItemRes> retArr = [];

      if (rootElement?.children == null) {
        log.severe('rootElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }

      Element? tableElement = rootElement?.children
          .firstWhere((element) => element.localName == 'table');
      if (tableElement?.children == null) {
        log.severe('tableElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingTableNode);
      } else if (tableElement?.children.first.localName == 'tbody') {
        tableElement = tableElement?.children.first;
      }
      int index = 0;
      int aLinkFound = 0;
      String parentUrl = _parentUrl(url: parameter.targetUrl);
      for (Element tr in tableElement?.children ?? []) {
        List<Element> alinkList = tr.getElementsByTagName('a');
        Element? alink = alinkList.firstWhere(
            (element) => (element.attributes['href'] ?? '').contains(parentUrl),
            orElse: () => Element.tag('a'));
        if (alink.attributes['href'] == null) {
          continue;
        } else {
          aLinkFound++;
        }
        if (aLinkFound < 2) {
          continue;
        }
        NovaListItemRes? novaListItemRes =
            await _createNovaTrItem(parameter.targetUrl, index: index, tr: tr);
        if (novaListItemRes != null) {
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

  ///
  ///<table>
  ///     <tr bgcolor=#EDEDED>
  ///         <td>第1位</td>
  ///         <td><a href="https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=534088">新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻(组图)</a> <i>02/21/22</i></td>
  ///         <td>
  ///             <center>269856 reads</center>
  ///         </td>
  ///         <td>
  ///             <center>439 次</center>
  ///         </td>
  ///         <td>
  ///             <center><a href="index.php?act=newsreply&nid=534088">查看评论</a></center>
  ///         </td>
  ///     </tr>
  /// </table>
  Future<NovaListItemRes?> _createNovaTrItem(String url,
      {required int index, required Element tr}) async {
    NovaListItemRes? retNovaItem;
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

    List<Element> trSubElements = tr.children;
    int trCount = trSubElements.length;
    String parentUrl = _parentUrl(url: url);
    List<Element> tdSubElements = [];
    int tdCount = 0;

    // title, urlString
    if (trCount > 1 && trSubElements[1].localName == 'td') {
      tdSubElements = trSubElements[1].children;
      tdCount = tdSubElements.length;
      if (tdCount > 0 && tdSubElements[0].localName == 'a') {
        title = tdSubElements[0].innerHtml;
        urlString = tdSubElements[0].attributes["href"] ?? "";
        if (!urlString.contains(parentUrl)) {
          return retNovaItem;
        }
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

      // createAt
      if (tdCount > 1 && tdSubElements[1].localName == 'i') {
        createAt = DateUtil().fromString(tdSubElements[1].innerHtml);
      }
    }

    // reads
    if (trCount > 2 && trSubElements[2].localName == 'td') {
      String readsStr = StringUtil().substring(trSubElements[2].innerHtml,
          start: "<center>", end: " reads");
      reads = NumberUtil().parseInt(string: readsStr) ?? 0;
    }

    // commentCount
    if (trCount > 3 && trSubElements[3].localName == 'td') {
      String commentCountStr = StringUtil()
          .substring(trSubElements[3].innerHtml, start: "<center>", end: " ");
      reads = NumberUtil().parseInt(string: commentCountStr) ?? 0;
    }

    // commentUrlString
    if (trCount > 4 && trSubElements[4].localName == 'td') {
      Element alink = trSubElements[4].getElementsByTagName('a').first;
      String tmpUrl = alink.attributes["href"] ?? "";
      commentUrlString = parentUrl + tmpUrl;
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
    return NovaListItemRes(itemInfo: itemInfo);
  }

  String _parentUrl({required String url}) {
    int lastIndex = url.lastIndexOf('/');
    return url.substring(0, lastIndex);
  }
}
