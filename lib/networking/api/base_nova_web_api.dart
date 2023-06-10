import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:ses_novajoj/foundation//log_util.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api_client/base_api_client.dart';
import 'package:ses_novajoj/networking/request/comment_item_parameter.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/networking/response/comment_list_item_response.dart';
import 'package:ses_novajoj/networking/response/misc_info_select_item_response.dart';
import 'package:ses_novajoj/networking/response/nova_detalo_item_response.dart';
import 'package:ses_novajoj/networking/response/nova_list_response.dart';

class BaseNovaWebApi {
  static const String kSampleUrlStr =
      'aHR0cHM6Ly9ob21lLjZwYXJrLmNvbS9pbmRleC5waHA/YXBwPWxvZ2luJmFjdD1kb2xvZ2lu';
  //'aHR0cHM6Ly93ZWIuNnBhcmtiYnMuY29tL3B1Yl9wYWdlL2hvbWVfbG9naW4ucGhw';
  static const String kSampleUrlParams = 'cGljaG82cGFya0A6d2FoYWhhQF8=';
  static const String kSampleReplacedPkCode =
      'Pihjb29sMTh8NnBhcmspXC5jb208Ly8+IDw=@@';
  static bool _logined = false;
  static const String kBbsMenuSettingUrl =
      'https://qczkbaujyxmh9zzbl82kzq.on.drv.tw/www2.pixie.net/www/apps/ses_novajoj/assets/json/bbs_menu.json.txt';
  static const String kMiscInfoSelectSettingUrl =
      'https://qczkbaujyxmh9zzbl82kzq.on.drv.tw/www2.pixie.net/www/apps/ses_novajoj/assets/json/misc_info_select.json.txt';

  ///
  ////api name: fetchNovaItemThumbUrl
  ///
  ////<div id='shownewsc' style="margin:15px;">
  ////      新闻新闻新闻新闻新闻。<br />
  ////<br />
  ////新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  ////<br />
  ////<center><img onload='javascript:if(this.width>600) this.width=600'  src="https://web.popo8.com/202202/13/0/47c5918239type_jpeg_size_220_100_end.jpg"/><br />
  ////</center><br />
  ////新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  ////<br />
  ////新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  ////<br />
  ////新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻<br />
  ////<center><br />
  ////<img onload='javascript:if(this.width>600) this.width=600'  src="https://web.popo8.com/202202/13/9/54795a8d62type_jpeg_size_1080_210_end.jpg"/><br />
  ////<br />
  ////图源：Hello BC</center><br />
  ////<br />
  ////新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  ////      <div>
  ////        <div class="OUTBRAIN" data-src="DROP_PERMALINK_HERE" data-widget-id="AR_1"></div> <script type="text/javascript" async="async" src="//widgets.outbrain.com/outbrain.js"></script>
  ////      </div>
  ////      </div>
  ///
  Future<Result<String>> fetchNovaItemThumbUrl(
      {required NovaItemParameter parameter}) async {
    try {
      ///send request for fetching nova item's thumb url.
      final response =
          await BaseApiClient.client.get(Uri.parse(parameter.targetUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }

      ///prepares to parse nova list from response.body.
      final document = html_parser.parse(response.body);
      final imgElements = document.getElementsByTagName('img');
      if (imgElements.isEmpty) {
        log.warning('imgElements.isEmpty');
        throw AppError(
            type: AppErrorType.dataError, reason: FailureReason.missingImgNode);
      }
      final imgElement = imgElements.firstWhere((element) {
        bool ret = false;
        if (element.attributes.keys.contains("src")) {
          String imgSrc = element.attributes["src"] ?? "";
          ret = imgSrc.contains("https://www.popo8.com/") ||
              element.attributes['mydatasrc'] != null;
          if (ret) {
            return ret;
          }
          return imgSrc.contains(RegExp(r'^https://(.*)\.[a-z]+$'));
        }
        return ret;
      }, orElse: () => imgElements.first);

      String retStr = (dynamic inElement) {
        String ret = imgElement.attributes['src'] ?? '';
        if (inElement.attributes['mydatasrc'] != null) {
          ret = inElement.attributes['mydatasrc'] ?? '';
        }
        return ret;
      }(imgElement);

      return Result.success(data: retStr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ////api name: fetchNovaItemTitle
  ///
  ////<title>Title - subTitle</title>
  ///
  Future<Result<String>> fetchNovaItemTitle(
      {required NovaItemParameter parameter}) async {
    try {
      ///send request for fetching nova item's thumb url.
      final response =
          await BaseApiClient.client.get(Uri.parse(parameter.targetUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }

      ///prepares to parse nova list from response.body.
      String retStr = '';
      final document = html_parser.parse(response.body);
      final titleElement = document.getElementsByTagName("title").first;
      if (titleElement.innerHtml.isNotEmpty) {
        retStr = titleElement.innerHtml.split(" -").first;
      }
      retStr = retStr.replaceAll('&nbsp;', ' ').trim();
      retStr = retStr.replaceAll('&amp;', '&');

      return Result.success(data: retStr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ///
  ////reshapeDetailBodyTags
  ///
  String reshapeDetailBodyTags(dynamic inElement) {
    ///reshape img tags
    var subElements = inElement?.getElementsByTagName('img');
    final osVer = Platform.operatingSystemVersion
        .toLowerCase()
        .replaceAll('version ', '');
    bool imgSrcChangable =
        Platform.isIOS && osVer.startsWith('9.') ? false : true;

    for (dynamic item in subElements ?? []) {
      if (item.attributes['mydatasrc'] != null) {
        item.attributes['src'] = item.attributes['mydatasrc'] ?? '';
      }
      item.attributes['data-src'] = item.attributes['src'] ?? '';
      if (imgSrcChangable) {
        item.attributes['src'] = '';
      }
    }

    ///reshape other tags
    Codec<String, String> codec = utf8.fuse(base64);
    final codes = codec
        .decode(kSampleReplacedPkCode.substring(
            0, kSampleReplacedPkCode.length - 2))
        .split('//');
    String retStr = inElement?.innerHtml ?? '';
    retStr = retStr.replaceAll(RegExp(r'' + codes.first), codes.last);
    return retStr;
  }

  ///
  ////api name: fetchCommentInfos
  ///
  Future<Result<CommentListItemItemRes>> fetchCommentInfos(
      {required CommentItemParameter parameter}) async {
    try {
      ///check network state
      final networkState = await BaseApiClient.connectivityState();
      if (networkState == ConnectivityResult.none) {
        throw const SocketException('Network is unavailable!');
      }

      ///send request for fetching nova list.
      ///
      List<NovaComment> comments = [];
      List<String> urlStrArr = [
        parameter.itemInfo.commentUrlString,
        '${parameter.itemInfo.commentUrlString}&p=2',
        '${parameter.itemInfo.commentUrlString}&p=3',
      ];
      bool breakFlg = false;
      late CommentListItemItemRes resp;

      for (var url in urlStrArr) {
        final response = await BaseApiClient.client.get(Uri.parse(url));
        if (response.statusCode >= HttpStatus.badRequest) {
          return Result.failure(
              error: AppError.fromStatusCode(response.statusCode));
        }

        ///prepares to parse nova list from response.body.
        final document = html_parser.parse(response.body);
        final result = await _parseLiItems(
            parameter: parameter,
            commentElements:
                document.getElementById("reply_list_all")?.children);
        List<NovaComment> commentArr = [];
        result.when(
            success: (value) {
              resp = value;
              commentArr = value.itemInfo.comments ?? [];
              String step = value.itemInfo.comments?.last.step ?? '';
              if (step == '1') {
                breakFlg = true;
              }
            },
            failure: (error) {});
        if (comments.length != commentArr.length) {
          comments.addAll(commentArr);
        }
        if (breakFlg) {
          break;
        }
      }
      resp.itemInfo.comments = comments;
      return Result.success(data: resp);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ///<!--bodybegin-->
  ///
  ///<div id='reply_list_all'>
  ///	<div class='reply_list_div ureply_51101378' id='reply_list_div_13488102'>
  ///		<div class='reply_auther_info'>
  ///			<span class='r_step'>[<b><a name='step27'>27</a></b>楼]</span><span class='r_auther'><b>评论人:</b><a
  ///					href="https://home.parkpark.com/index.php?app=home&act=chatnew&uname=NTExMDEzNzg%3D">duacha</a></span>
  ///			<span class='r_date'><b>发送时间:</b> 2023年01月22日 4:40:05</span>
  ///			<span><a href='javascript:void(0)' onclick='replyto(13488102,27)'>【回复】</a></span>
  ///		</div>
  ///		<div class='reply_auther_content'>
  ///			<span class='r_reply_span'>&nbsp;</span><span class='r_reply_a'>回复<a
  ///					href=#step26>26</a>楼:</span><br />
  ///			内容内容内容内容内容内容内容内容内容内容内容
  ///		</div>
  ///		<div class='reply_control'>
  ///			<span class="r_mar10"><a href='javascript:void(0)' onclick='dolike(13488102)'><img
  ///						src='./public/img/like.png' /><span id="rlike_13488102">支持</span></a></span>&nbsp;
  ///			<span class="r_mar10"><a href='javascript:void(0)' onclick='dislike(13488102)'><img class="dislike"
  ///						src='./public/img/like.png' /><span id="rdislike_13488102">不支持</span></a></span>&nbsp;
  ///		</div>
  ///	</div>
  ///	<div class='reply_list_div ureply_52057351' style='background:#E6E6DD;' id='reply_list_div_13488033'>
  ///		<div class='reply_auther_info'>
  ///			<span class='r_step'>[<b><a name='step26'>26</a></b>楼]</span><span class='r_auther'><b>评论人:</b><a
  ///					href="https://home.parkpark.com/index.php?app=home&act=chatnew&uname=NTIwNTczNTE%3D">夜雨濛</a></span>
  ///			<span class='r_link'>[品衔R2☆]</span>
  ///			<span class='r_link'>[<a href="https://www.parkparkbbs.com/index.php?act=bloghome&uname=NTIwNTczNTE%3D"
  ///			<span class='r_date'><b>发送时间:</b> 2023年01月22日 3:52:47</span>
  ///			<span><a href='javascript:void(0)' onclick='replyto(13488033,26)'>【回复】</a></span>
  ///		</div>
  ///		<div class='reply_auther_content'>
  ///			外交部长都是国务委员<p><b><a href="https://home.parkpark.com/client/" target="_blank">来自留园官方客户端</a></b></p>
  ///		</div>
  ///		<div class='reply_control'>
  ///		</div>
  ///	</div>
  /// ...
  ///	<div class='reply_list_div ureply_50415139' id='reply_list_div_13487459'>
  ///		<div class='reply_auther_info'>
  ///			<span class='r_step'>[<b><a name='step23'>23</a></b>楼]</span><span class='r_auther'><b>评论人:</b><a
  ///					href="https://home.parkpark.com/index.php?app=home&act=chatnew&uname=NTA0MTUxMzk%3D">壮男</a></span>
  ///			<span class='r_link'>[☆发送人]</span>
  ///			<span class='r_date'><b>发送时间:</b> 2023年01月21日 22:37:16</span>
  ///		</div>
  ///		<div class='reply_auther_content'>
  ///			内容内容内容内容内容内容内容内容内容 </div>
  ///		<div class='reply_control'>
  ///			<span class="r_mar10"><a href='javascript:void(0)' onclick='dolike(13487459)'><img
  ///						src='./public/img/like.png' /><span id="rlike_13487459">4</span></a></span>&nbsp;
  ///			<span class="r_mar10"><a href='javascript:void(0)' onclick='dislike(13487459)'><img class="dislike"
  ///						src='./public/img/like.png' /><span id="rdislike_13487459">1</span></a></span><span
  ///				class="r_mar20"><a href="index.php?act=newsreply&nid=589044&viewRid=13487459"><img
  ///						src="./public/img/replies.png"><span>1</span></a></span>&nbsp;
  ///		</div>
  ///	</div>
  ///	<div class='reply_list_div ureply_51151594' style='background:#E6E6DD;' id='reply_list_div_13487437'>
  ///		<div class='reply_auther_info'>
  ///		</div>
  ///		<div class='reply_auther_content'>
  ///			oooooooooooooo </div>
  ///		<div class='reply_control'>
  ///		</div>
  ///	</div>
  ///	<div class='reply_list_div ureply_52380811' style='background:#E6E6DD;' id='reply_list_div_13487045'>
  ///		<div class='reply_auther_info'>
  ///			<span class='r_step'>[<b><a name='step14'>14</a></b>楼]</span><span class='r_auther'><b>评论人:</b><a
  ///					href="https://home.parkpark.com/index.php?app=home&act=chatnew&uname=NTIzODA4MTE%3D">o祖宗o</a></span>
  ///			<span class='r_date'><b>发送时间:</b> 2023年01月21日 19:25:13</span>
  ///			<span><a href='javascript:void(0)' onclick='replyto(13487045,14)'>【回复】</a></span>
  ///		</div>
  ///		<div class='reply_auther_content'>
  ///			<span class='r_reply_span'>&nbsp;</span><span class='r_reply_a'>回复<a
  ///					href=#step13>13</a>楼:</span><br />
  ///			内容内容内容内容内容内容内容内容😉<br />
  ///			<span class='r_reply_span'>&nbsp;</span><span class='r_reply_a'>回复<a
  ///					href=#step12>12</a>楼:</span><br />
  ///			~<br />
  ///			内容内容内容内容内容内容内容内容😉<br />
  ///			.<br />
  ///			内容内容内容内容内容内容内容内容😉<br />
  ///			.<br />
  ///		</div>
  ///		<div class='reply_control'>
  ///		</div>
  ///	</div>
  ///	<br>
  ///</div>
  ///<!--bodyend-->
  Future<Result<CommentListItemItemRes>> _parseLiItems(
      {required CommentItemParameter parameter,
      List<Element>? commentElements}) async {
    try {
      final itemInfo = NovaItemInfoRes.fromJson(parameter.itemInfo.toJson());
      CommentListItemItemRes ret = CommentListItemItemRes(itemInfo: itemInfo);

      if (commentElements?.isEmpty ?? true) {
        log.severe('commentElements is empty');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }

      //
      // make comment list
      //
      ret.itemInfo.comments = [];
      for (Element elem in commentElements ?? []) {
        NovaComment novaComment = NovaComment();
        //
        // author info
        //
        final authDivs = elem.getElementsByClassName('reply_auther_info');
        if (authDivs.isEmpty) {
          break;
        }
        final authDiv = authDivs.first;
        // step
        novaComment.step = (Element inElem) {
          return StringUtil()
              .substring(inElem.innerHtml, start: 'name="step', end: '">');
        }(authDiv.getElementsByClassName('r_step').first);
        // author
        novaComment.author = (Element inElem) {
          final alinks = inElem.getElementsByTagName('a');
          if (alinks.isEmpty) {
            return '';
          }
          return alinks.first.innerHtml;
        }(authDiv.getElementsByClassName('r_auther').first);
        // createdAt
        novaComment.createAt = (Element inElem) {
          String retStr =
              StringUtil().substring(inElem.innerHtml, start: "</b> ", end: "");
          return retStr.length - 3 > 0
              ? retStr.substring(0, retStr.length - 3)
              : retStr;
        }(authDiv.getElementsByClassName('r_date').first);

        //
        // auther_content info
        //
        final contentDiv =
            elem.getElementsByClassName('reply_auther_content').first;
        final replyElemInfos = contentDiv.getElementsByClassName('r_reply_a');
        // plainString
        novaComment.plainString =
            (Element inElem, List<Element> inReplyElemInfos) {
          var retStr = inElem.innerHtml;
          for (final subElem in contentDiv.children) {
            if (['span', 'a'].contains(subElem.localName)) {
              retStr = retStr.replaceAll(subElem.outerHtml, '');
            }
          }
          retStr = StringUtil().substring(retStr, start: '', end: '<p><b>');
          return retStr
              .replaceFirst(':<br>', '\n')
              .replaceAll('<br>', '\n')
              .replaceAll('\n\n', '\n')
              .trim();
        }(contentDiv, replyElemInfos);

        // replyList
        novaComment.replyList =
            (Element inElem, List<Element> inReplyElemInfos) {
          if (inReplyElemInfos.isEmpty) {
            return <NovaComment>[];
          }
          List<NovaComment> subComments = [];
          for (final subElem in inReplyElemInfos) {
            NovaComment subComment = NovaComment();
            subComment.pageNumber = -1;
            subComment.author = '';
            subComment.createAt = '';
            subComment.step = subElem.getElementsByTagName('a').first.innerHtml;

            subComment.plainString = StringUtil()
                .substring(inElem.innerHtml, start: subElem.outerHtml, end: '');
            if (subComment.plainString.isEmpty) {
              subComment.plainString = StringUtil().substring(inElem.innerHtml,
                  start: subElem.outerHtml, end: '<');
            }
            subComment.plainString = StringUtil()
                .substring(subComment.plainString, start: '', end: '<p><b>');
            subComment.plainString = subComment.plainString
                .replaceFirst(':<br>', '\n')
                .replaceAll('<br>', '\n')
                .replaceAll('\n\n', '\n')
                .trim();

            subComments.add(subComment);
          }

          return subComments;
        }(contentDiv, replyElemInfos);

        // add comment into list
        ret.itemInfo.comments?.add(novaComment);
      }
      return Result.success(data: ret);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ///
  ////api name: fetchSearchedResult
  ///
  Future<Result<List<NovaListItemRes>>> fetchSearchedResult(
      {required NovaItemParameter parameter}) async {
    ///send request for fetching searched result.
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
      // final document = html_parser.parse(response.body);
      // List<NovaListItemRes> retArr = [];
      // return Result.success(data: retArr);
      final document = html_parser.parse(response.body);
      return _parseSearchedItems(
          parameter: parameter,
          rootElement: document.getElementsByClassName('dc_bar2').first);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      log.severe('$error');
      return Result.failure(error: AppError.fromException(error));
    }
  }

  ///	<table width=998 align=center bgcolor=#FFFFFF class=dc_bar2>
  ///			<tr>
  ///				<td>
  ///					<b style='margin-right:60px;'><span style="color:red;">文本</span> 搜索结果:</b>
  ///					[<a
  ///						href='index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords=%E5%A7%91%E5%A8%98&first=1'>只看社区主贴</a>]
  ///					<hr>
  ///					<div class="t_l" style="margin-left:5px;margin-top:15px;">
  ///						<span class="t_subject"><img src="./public/list_style/li_3.gif"
  ///								style='vertical-align:middle;margin-left:25px;margin-right:10px;' /><a
  ///								href="index.php?app=forum&act=threadview&tid=13978907"><span class='keyword'>文</span><span
  ///									class='keyword'>本</span>的搜索结果的搜索结果</a></span> -
  ///						<span class="t_author">ming98</span>
  ///						<span class="t_dateline"><i>08/24/22</i></span>
  ///					</div>
  ///	...
  ///					<div class="t_l" style="margin-left:5px;margin-top:15px;">
  ///						<span class="t_subject"><img src="./public/list_style/li_3.gif"
  ///								style='vertical-align:middle;margin-left:25px;margin-right:10px;' /><a
  ///								href="index.php?app=forum&act=threadview&tid=13861518">O<span class='keyword'>姑</span><span
  ///									class='keyword'>娘</span> XXXXXXXXXX</a></span> -
  ///						<span class="t_author">O姑娘</span>
  ///						<span class="t_dateline"><i>03/09/15</i></span>
  ///					</div>
  ///				</td>
  ///			</tr>
  ///		</table>
  Future<Result<List<NovaListItemRes>>> _parseSearchedItems(
      {required NovaItemParameter parameter, Element? rootElement}) async {
    try {
      List<NovaListItemRes> retArr = [];

      if (rootElement?.children == null || rootElement?.localName != 'table') {
        log.severe('rootElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }
      final divElememts = rootElement?.getElementsByClassName('t_l');

      if (divElememts?.isEmpty ?? true) {
        log.severe('divElememts?.isEmpty');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingListNode);
      }
      String parentUrl = _parentUrl(url: parameter.targetUrl);
      int index = 0;
      for (Element divRow in divElememts ?? []) {
        NovaListItemRes? novaListItemRes;
        String title = '';
        String urlString = '';
        DateTime createdAt;
        String author = '';
        String source = '';
        //
        // subject
        //
        final subjectElems = divRow.getElementsByClassName('t_subject');
        if (subjectElems.isEmpty) {
          continue;
        }
        final alink = subjectElems.first.children.firstWhere(
            (elem) => elem.localName == 'a',
            orElse: () => Element.tag('a'));
        if (alink.attributes['href'] == null) {
          continue;
        }
        // urlString
        urlString = '$parentUrl/${alink.attributes['href'] ?? ''}';

        // title
        title = alink.text;

        // author
        author = () {
          final elems = divRow.getElementsByClassName('t_author');
          if (elems.isEmpty) {
            return '';
          }
          return elems.first.innerHtml;
        }();

        // createdAt
        createdAt = () {
          final elems = divRow.getElementsByClassName('t_dateline');
          if (elems.isEmpty) {
            return DateTime.now();
          }
          final str = elems.first.innerHtml;
          return DateUtil().fromString(str, format: 'MM/dd/yy') ??
              DateTime.now();
        }();

        novaListItemRes = NovaListItemRes(
            itemInfo: NovaItemInfo(
                id: index,
                title: title,
                urlString: urlString,
                author: author,
                createAt: createdAt,
                source: source));
        retArr.add(novaListItemRes);
        index++;
      }

      return Result.success(data: retArr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  String _parentUrl({required String url}) {
    int lastIndex = url.lastIndexOf('/');
    return url.substring(0, lastIndex);
  }
}

extension BaseNovaWebApiForAuth on BaseNovaWebApi {
  Future<Result<bool>> performSampleLogin(
      String username, String password) async {
    try {
      if (BaseNovaWebApi._logined) {
        return Result.success(data: BaseNovaWebApi._logined);
      }
      Codec<String, String> codec = utf8.fuse(base64);
      //Map<String, String> headers = {"Content-type": "application/json"};

      Map<String, String> dataBody = {
        'username':
            codec.decode(BaseNovaWebApi.kSampleUrlParams).split('@:').first,
        'password': (String str) {
          return str.substring(0, str.length - 2);
        }(codec.decode(BaseNovaWebApi.kSampleUrlParams).split('@:').last),
        'dologin': '%20%E7%99%BB%E5%BD%95%20'
      };

      ///make POST request
      final response = await BaseApiClient.client
          .post(Uri.parse(codec.decode(BaseNovaWebApi.kSampleUrlStr)),
              /*headers: headers,*/
              body: dataBody);

      ///check the status code for the result
      int statusCode = response.statusCode;

      if (statusCode < HttpStatus.badRequest) {
        BaseNovaWebApi._logined = true;
        return const Result.success(data: true);
      } else {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }
}

extension BaseNovaWebSettings on BaseNovaWebApi {
  Future<Result<String>> fetchBbsMenuSettings() async {
    try {
      ///fetch bbs munu settings
      final response = await BaseApiClient.client
          .get(Uri.parse(BaseNovaWebApi.kBbsMenuSettingUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }

      ///set result from response.body.

      return Result.success(data: utf8.decode(response.bodyBytes));
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  Future<Result<List<MiscInfoSelectItemItemRes>>>
      fetchMiscInfoSelectSettings() async {
    try {
      ///fetch bbs munu settings
      final response = await BaseApiClient.client
          .get(Uri.parse(BaseNovaWebApi.kMiscInfoSelectSettingUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }

      ///set result from response.body.
      final ret = (dynamic res) {
        final parsed = jsonDecode(utf8.decode(res));
        final list = parsed?['misc_select_menu'] as List?;
        return list != null
            ? list
                .map((elem) => MiscInfoSelectItemItemRes.fromJson(elem))
                .toList()
            : <MiscInfoSelectItemItemRes>[];
      }(response.bodyBytes);

      return Result.success(data: ret);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }
}
