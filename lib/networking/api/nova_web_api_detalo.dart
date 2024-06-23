part of 'nova_web_api.dart';

extension NovaWebApiDetail on NovaWebApi {
  ///
  /// api entry: fetchNovaDetail
  ///
  Future<Result<NovaDetaloItemRes>> fetchNovaDetail(
      {required NovaDetaloParameter parameter}) async {
    try {
      // check network state
      if (await ConnectUtil.isUnavailable(checksAgain: true)) {
        throw const SocketException('Network is unavailable!');
      }

      // send request for fetching nova list.
      final response = await BaseApiClient.client
          .get(Uri.parse(parameter.itemInfo.urlString));

      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }
      // prepares to parse nova list from response.body.
      final document = html_parser.parse(response.body);
      NovaDetaloItemRes? retVal;

      if (parameter.docType == NovaDocType.detail) {
        var rootElement = document.getElementById("newscontent_2");
        rootElement ??=
            document.getElementsByClassName("art-main-body-auth").first;
        var detailElement = document.getElementById("shownewsc");
        detailElement ??= document.getElementById("news_content");
        return _parseDetailItems(
            parameter: parameter,
            rootElement: rootElement,
            detailElement: detailElement);
      }

      return Result.success(data: retVal!);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    } catch (error) {
      return Result.failure(error: AppError.fromException(Exception()));
    }
  }

  ///
  /// <div class="td3" id="newscontent_2">
  /// 	<h2 style="margin:15px;text-align:center;">乌克兰情侣立刻结婚 拿起步枪:希望在死前在一起(图)</h2>
  /// 	<p style="padding:5px;">
  /// 		新闻来源: ETtoday 于2022-02-25 22:54:35
  /// 		<span style="FONT-SIZE: 11px">
  /// 		</span>
  /// 	</p>
  /// 	<div id='shownewsc' style="margin:15px;">
  /// 		<center><img onload='javascript:if(this.width>600) this.width=600'
  /// 				src='https://web.popo8.com/20220225/20220225225423_24311type_jpeg_size_1000_150_end.jpg' /><br />
  /// 		</center><br />
  /// 		新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  /// 		新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻。<br />
  ///    ...
  /// 		<!--内容下-->
  /// 		<div>
  /// 			<div class="OUTBRAIN" data-src="DROP_PERMALINK_HERE" data-widget-id="AR_1"></div>
  /// 			<script type="text/javascript" async="async" src="//widgets.outbrain.com/outbrain.js"></script>
  /// 		</div>
  /// 	</div>
  /// 	<table width=100%>
  /// 		<tr>
  /// 			<td align='left' width='150px'>
  /// 				网编：author<a name=postfp></a>
  /// 			</td>
  /// 			<td align='center' style=''>
  /// 			</td>
  /// 			<td width='150px'>
  /// 				<a href="index.php?act=newsreply&nid=534849" class='reply_link_img'><span>43 条</span></a>
  /// 			</td>
  /// 		</tr>
  ///   </table>
  /// </div>
  ///
  Future<Result<NovaDetaloItemRes>> _parseDetailItems(
      {required NovaDetaloParameter parameter,
      Element? rootElement,
      Element? detailElement}) async {
    try {
      NovaDetaloItemRes retVal = NovaDetaloItemRes(
          itemInfo: parameter.itemInfo,
          bodyString: reshapeDetailBodyTags(detailElement));
      //String source = parameter.itemInfo.source;
      if (rootElement?.children == null) {
        log.severe('rootElement?.children == null');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }
      // parentUrl
      String parentUrl = _parentUrl(url: parameter.itemInfo.urlString);

      // createAt (detail)
      retVal.itemInfo.createAt = (DateTime value) {
        final plElements =
            rootElement?.children.where((element) => element.localName == 'p');
        String infoStr = plElements != null && plElements.isNotEmpty
            ? plElements.first.innerHtml
            : rootElement!.innerHtml;

        String dateStr = '';
        final dateLoc = infoStr.indexOf(
            RegExp(r' [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{1,}:[0-9]{1,}.*[0-9]+ '),
            0);
        if (dateLoc >= 0) {
          dateStr = infoStr.substring(dateLoc + 1, dateLoc + 17);
        }

        return dateStr.isEmpty
            ? value
            : DateUtil().fromString(dateStr, format: 'yyyy-MM-dd H:mm') ??
                value;
      }(retVal.itemInfo.createAt);

      // author
      retVal.itemInfo.author = () {
        String retStr = '';
        final tablelElements = rootElement?.children
            .where((element) => element.localName == 'table');
        final tablelElement = (tablelElements == null || tablelElements.isEmpty)
            ? rootElement
            : tablelElements.first;
        if (tablelElement?.children.isNotEmpty ?? false) {
          for (Element tr in tablelElement?.children ?? []) {
            for (Element td in tr.children) {
              final alink = td.children.firstWhere(
                  (element) => element.localName == 'a',
                  orElse: () => Element.tag('a'));
              if (alink.attributes['name'] == 'postfp') {
                retStr = StringUtil()
                    .substring(td.innerHtml, start: '：', end: alink.outerHtml);
                return retStr;
              }
            }
          }
        } else {
          retStr = StringUtil()
              .substring(rootElement!.innerHtml, start: '：', end: " \u4e8e ");
        }
        return retStr;
      }();

      // commentUrlString
      final commentLinkTag =
          rootElement?.getElementsByClassName('reply_link_img');
      if (commentLinkTag != null && commentLinkTag.isNotEmpty) {
        retVal.itemInfo.commentUrlString = (Element? aLink) {
          // reply_link_img
          String str = aLink?.attributes['href'] ?? '';
          str = "$parentUrl/${str.replaceAll('\\"', '')}";
          return str;
        }(commentLinkTag.first);
      }

      // commentCount
      retVal.itemInfo.commentCount =
          rootElement?.getElementsByClassName('reply_auther_info').length ?? 0;
      return Result.success(data: retVal);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }
}
