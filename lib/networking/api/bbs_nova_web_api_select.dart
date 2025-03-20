part of 'bbs_nova_web_api.dart';

extension BbsNovaWebApiSelect on BbsNovaWebApi {
  ///
  /// api entry: fetchBbsSelectList
  ///
  static const int _kThumbLimit = 5;

  ///
  /// api entry: fetchNovaList
  ///
  Future<Result<List<BbsNovaSelectListItemRes>>> fetchSelectList(
      {required NovaItemParameter parameter}) async {
    _itemParameter = parameter;
    _responsedInfo ??= {};

    try {
      // prepares to parse nova list from response.body.
      // load response data from its cache if needs.
      print("aaaa-2.1=${parameter.targetUrl}");
      String bodyString = await loadResponseDataFromCache(
          urlString: parameter.targetUrl,
          cacheFolder: "bbs_select",
          cacheIsCleared: parameter.fetchedBlockItemIndex >= 1);

      print("aaaa-2.2=${parameter.targetUrl}");
      // prepares to parse nova list from response.body.
      final document = Document.html(bodyString);
      List<BbsNovaSelectListItemRes> retArr = [];
      AppError? retErr;
      if (parameter.docType == NovaDocType.bbsSelect) {
        future_ext.FutureGroup<Result<List<BbsNovaSelectListItemRes>>> group =
            future_ext.FutureGroup<Result<List<BbsNovaSelectListItemRes>>>();
        group.add(_parseTrItems(
            parameter: parameter,
            rootElement: document.getElementById("d_gold_list")));
        group.add(_parseLiItems(
            parameter: parameter,
            rootElement: document.getElementById("d_list"),
            startId: 100));
        group.close();
        final responses = await group.future;
        for (var item in responses) {
          item.when(success: (value) {
            retArr.addAll(value);
          }, failure: (error) {
            retErr = error;
          });
          if (retErr != null) {
            return Result.failure(error: retErr!);
          }
        }
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
  Future<Result<List<BbsNovaSelectListItemRes>>> _parseLiItems(
      {required NovaItemParameter parameter,
      Element? rootElement,
      int startId = 0}) async {
    try {
      List<BbsNovaSelectListItemRes> retArr = [];
      Map<int, BbsNovaSelectListItemRes> keepedResponseInfo =
          _responsedInfo?[parameter.targetUrl.hashCode] ?? {};

      if (rootElement?.children == null) {
        log.severe('rootElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }
      final ulElement = rootElement?.children.firstWhere(
          (element) => element.localName == 'ul',
          orElse: () => Element.tag('ul'));

      // ul --> div list
      if (ulElement?.children.isEmpty ?? true) {
        print("totolItemCount= _parseDivItems ...  START");
        return _parseDivItems(
            parameter: parameter, rootElement: rootElement, startId: 100);
      }

      int index = 0;
      int totolItemCount = ulElement?.children.length ?? 0;
      int limitPerBlock = parameter.limitPerBlock > totolItemCount
          ? totolItemCount
          : parameter.limitPerBlock;
      int pageBlockIndex =
          parameter.pageBlockIndex < 1 ? 1 : parameter.pageBlockIndex;
      int takenStart = (pageBlockIndex - 1) * limitPerBlock;
      // int takenEnd = totolItemCount;
      int takenEnd = min(pageBlockIndex * limitPerBlock, totolItemCount);
      print(
          "[0]totolItemCount=$totolItemCount, limitPerBlock=$limitPerBlock, blockIndex = ${parameter.pageBlockIndex}, takenStart=$takenStart, takenEnd=$takenEnd");
      List<Element> subList =
          ulElement?.children.sublist(takenStart, takenEnd) ?? [];
      for (Element li in subList) {
        // if (parameter.fetchedBlockItemIndex < 1 && index >= 20) {
        //   break;
        // }
        if (keepedResponseInfo[li.innerHtml.hashCode] != null) {
          retArr.add(keepedResponseInfo[li.innerHtml.hashCode]
              as BbsNovaSelectListItemRes);
          index++;
        } else {
          BbsNovaSelectListItemRes? novaListItemRes = await _createNovaLiItem(
              parameter.targetUrl,
              index: index,
              li: li,
              totolItemCount: totolItemCount);
          if (novaListItemRes != null) {
            retArr.add(novaListItemRes);
            retArr[index].itemInfo.id = retArr[index].itemInfo.id + startId;
            retArr[index].itemInfo.children = await () async {
              Element subLi = li.children.firstWhere(
                  (element) => element.localName == 'ul',
                  orElse: () => Element.tag('ul'));
              if (subLi.children.isNotEmpty) {
                BbsNovaSelectListItemRes? subListItemRes =
                    await _createNovaLiItem(parameter.targetUrl,
                        index: 0,
                        li: subLi.children.first,
                        totolItemCount: totolItemCount);
                if (subListItemRes != null) {
                  return [subListItemRes.itemInfo];
                }
              }
              return null;
            }();
            keepedResponseInfo[li.innerHtml.hashCode] = novaListItemRes;
            index++;
          }
        }
      }
      _responsedInfo?[parameter.targetUrl.hashCode] = keepedResponseInfo;

      return Result.success(data: retArr);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  /// <div id="d_list"  class="main_right_margin">
  /// 		<div class="repl-body">
  /// 				<div class="repl-list repl-list-one" style="margin-left:40px">
  /// 						<a href="index.php?app=forum&act=view&tid=2784258">XXXXXXXXXXXXX</a> - <a href=https://www.6parkbbs.com/index.php?act=bloghome&uname=NTEzMDg1Njg%3D><font color=black>xanfan</font></a> (10347 bytes) <i>05/04/22</i> <span class="t_views_14515800">(242 reads)</span>
  /// 				</div>
  ///     </div>
  /// </div>

  Future<Result<List<BbsNovaSelectListItemRes>>> _parseDivItems(
      {required NovaItemParameter parameter,
      Element? rootElement,
      int startId = 0}) async {
    try {
      List<BbsNovaSelectListItemRes> retArr = [];

      if (rootElement?.children == null) {
        log.severe('rootElement?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }
      final divListBody = rootElement?.children.firstWhere(
          (element) =>
              element.localName == 'div' &&
              element.attributes['class'] == 'repl-body',
          orElse: () => Element.tag('div'));

      if (divListBody?.children.isEmpty ?? true) {
        log.severe('divListBody?.children');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingListNode);
      }
      int index = 0;
      for (Element divLi in divListBody?.children ?? []) {
        BbsNovaSelectListItemRes? novaListItemRes = await _createNovaLiItem(
            parameter.targetUrl,
            index: index,
            li: divLi,
            totolItemCount: 0);
        if (novaListItemRes != null) {
          retArr.add(novaListItemRes);
          retArr[index].itemInfo.id = retArr[index].itemInfo.id + startId;
          retArr[index].itemInfo.children = await () async {
            Element subDivLi = divLi.children.firstWhere(
                (element) =>
                    element.localName == 'div' &&
                    element.attributes['class'] == 'repl-list repl-list-sen',
                orElse: () => Element.tag('div'));
            if (subDivLi.attributes.isNotEmpty) {
              BbsNovaSelectListItemRes? subListItemRes =
                  await _createNovaLiItem(parameter.targetUrl,
                      index: 0, li: subDivLi, totolItemCount: 0);
              if (subListItemRes != null) {
                return [subListItemRes.itemInfo];
              }
            }
            return null;
          }();

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

  Future<BbsNovaSelectListItemRes?> _createNovaLiItem(String url,
      {required int index,
      required Element li,
      required int totolItemCount}) async {
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
      title = liSubElements[0].text;
      urlString = () {
        String retStr = liSubElements[0].attributes["href"] ?? "";
        if (!retStr.contains(RegExp(r'http(s)*:\/\/'))) {
          retStr = "$parentUrl/$retStr";
        }
        return retStr;
      }();

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

    // source
    if (liCount > 1 && liSubElements[1].localName == 'a') {
      source = liSubElements[1].children.first.innerHtml;
    }

    // createAt
    if (liCount > 2 && liSubElements[2].localName == 'i') {
      createAt = DateUtil().fromString(liSubElements[2].innerHtml);
    }

    // reads
    if (liCount > 3 && liSubElements[3].localName == 'span') {
      reads = () {
        String str = StringUtil()
            .substring(liSubElements[3].innerHtml, start: ">(", end: " reads)");
        return NumberUtil().parseInt(string: str) ?? 0;
      }();
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
        isRead: isRead,
        blockIndex: _itemParameter!.pageBlockIndex,
        fetchedBlockItemIndex: index,
        limitPerBlock: _itemParameter!.limitPerBlock,
        totolItemClount: totolItemCount);
    return BbsNovaSelectListItemRes(itemInfo: itemInfo);
  }

  /// <div id="d_gold_list"  class="main_right_margin" style="height:100px">
  /// 	<table width="998px" border="0">
  /// 		<tr>
  /// 		<td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616697">🇺🇸📷女同事半夜和老公吵架了</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616677">🎅6句就逗笑女孩子开心的短笑话</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616657">⭕️ 喵：大王叫我来巡山啊🌹</a></td></tr><tr><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616568">🐦❤️此时无声胜有声</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616326">每次打这里过都觉得自己像巨星一样🎣👨</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616583">🐂🐄练习舞蹈，妹子表示已经累晕了...</a></td></tr><tr><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616568">🐦此时无声胜有声❤️</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616518">亚洲辣妹都流行「倒V劈叉」拍照？⛵️</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616363">妹子上课时总这样偷偷对我笑</a></td></tr><tr><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616324">🎣👨妹子你是来学习呢还是打坐修行呢</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616489">📷🙏猫：这傻女 啥时候能嫁出去啊</a></td><td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616305">🥚🎅用会计术语吵架，要笑喷了！</a></td></tr><tr>					</tr>
  /// 	</table>
  /// </div>
  Future<Result<List<BbsNovaSelectListItemRes>>> _parseTrItems(
      {required NovaItemParameter parameter, Element? rootElement}) async {
    try {
      List<BbsNovaSelectListItemRes> retArr = [];

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

      // novaListItemRes
      int index = 0;
      for (Element tr in tableElement?.children ?? []) {
        List<Element> alinkList = tr.getElementsByTagName('a');
        if (alinkList.isEmpty) {
          continue;
        }

        for (final alink in alinkList) {
          BbsNovaSelectListItemRes? novaListItemRes = await _createNovaTrItem(
              parameter.targetUrl,
              index: index,
              td: tr.children.first,
              alink: alink);
          if (novaListItemRes != null) {
            retArr.add(novaListItemRes);
            index++;
          }
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
  ///<td width=33% class='gold_td'><a href="index.php?app=forum&act=threadview&tid=14616697">xxxx</a></td>
  ///
  Future<BbsNovaSelectListItemRes?> _createNovaTrItem(String url,
      {required int index, required Element td, required Element alink}) async {
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

    String parentUrl = _parentUrl(url: url);

    // title, urlString
    if (td.children.isNotEmpty && alink.localName == 'a') {
      // title
      title = alink.text;

      // urlString
      urlString = () {
        String retStr = alink.attributes["href"] ?? "";
        if (!retStr.contains(RegExp(r'http(s)*:\/\/'))) {
          retStr = "$parentUrl/$retStr";
        }
        return retStr;
      }();
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
    return BbsNovaSelectListItemRes(itemInfo: itemInfo);
  }

  String _parentUrl({required String url}) {
    int lastIndex = url.lastIndexOf('/');
    return url.substring(0, lastIndex);
  }
}
