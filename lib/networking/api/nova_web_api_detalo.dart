part of 'nova_web_api.dart';

extension NovaWebApiDetail on NovaWebApi {
  ///
  /// api entry: fetchNovaDetail
  ///
  Future<Result<NovaDetaloItemRes?, NovaDomainReason>> fetchNovaDetail(
      {required NovaItemParameter parameter}) async {
    try {
      // send request for fetching nova list.
      final response =
          await BaseApiClient.client.get(Uri.parse(parameter.targetUrl));
      // prepares to parse nova list from response.body.
      final document = html_parser.parse(response.body);
      NovaDetaloItemRes? retVal;

      if (parameter.docType == NovaDocType.detail) {
        return _parseDetailItems(
            parameter: parameter,
            rootElement: document.getElementById("d_list"));
      }

      return Result.success(retVal);
    } on NovaDomainReason catch (reason) {
      return Result.domainIssue(reason);
    } catch (e) {
      return Result.failure(0, e.toString());
    }
  }

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
  Future<Result<NovaDetaloItemRes?, NovaDomainReason>> _parseDetailItems(
      {required NovaItemParameter parameter, Element? rootElement}) async {
    try {
      NovaDetaloItemRes? retVal;

      if (rootElement?.children == null) {
        throw Exception(NovaDomainReason.notFound);
      }
      final ulElement = rootElement?.children
          .firstWhere((element) => element.localName == 'ul');

      if (ulElement?.children == null) {
        throw Exception(NovaDomainReason.notFound);
      }
      int index = 0;
      for (Element li in ulElement?.children ?? []) {
        NovaListItemRes? novaListItemRes = await _createNovaDetailItem(
            parameter.targetUrl,
            index: index,
            li: li);
        if (novaListItemRes != null) {
          //retArr.add(novaListItemRes);
          index++;
        }
      }

      return Result.success(retVal);
    } on NovaDomainReason catch (reason) {
      return Result.domainIssue(reason);
    } catch (e) {
      return Result.failure(0, e.toString());
    }
  }

  Future<NovaListItemRes?> _createNovaDetailItem(String url,
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
      if (urlString.isNotEmpty && index < NovaWebApi._kThumbLimit) {
        Result<String, NovaDomainReason> thumbUrlResult =
            await fetchNovaItemThumbUrl(
                parameter: NovaItemParameter(
                    targetUrl: urlString, docType: NovaDocType.thumb));
        thumbUrlResult.when(
            success: (value) {
              thunnailUrlString = value;
            },
            failure: (code, description) {},
            domainIssue: (reason) {});
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
}
