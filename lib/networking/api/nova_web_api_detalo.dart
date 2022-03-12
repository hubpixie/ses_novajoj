part of 'nova_web_api.dart';

extension NovaWebApiDetail on NovaWebApi {
  ///
  /// api entry: fetchNovaDetail
  ///
  Future<Result<NovaDetaloItemRes>> fetchNovaDetail(
      {required NovaDetaloParameter parameter}) async {
    try {
      // check network state
      final networkState = await BaseApiClient.connectivityState();
      if (networkState == ConnectivityResult.none) {
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
        return _parseDetailItems(
            parameter: parameter,
            rootElement: document.getElementById("newscontent_2"),
            detailElement: document.getElementById("shownewsc"));
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
          bodyString: detailElement?.innerHtml ?? '');
      String source = parameter.itemInfo.source;
      if (rootElement?.children == null) {
        log.severe('rootElement?.children == null');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }

      // createAt (detail)
      retVal.itemInfo.createAt = (DateTime value) {
        final plElement = rootElement?.children
            .firstWhere((element) => element.localName == 'p');
        if (plElement != null && plElement.innerHtml.isNotEmpty) {
          String createAtStr = StringUtil()
              .substring(plElement.innerHtml, start: source, end: ' \n');
          createAtStr = StringUtil().subfix(createAtStr, width: 18);
          return DateUtil()
                  .fromString(createAtStr, format: 'yyyy-MM-dd H:mm:ss') ??
              value;
        }
        return value;
      }(retVal.itemInfo.createAt);

      // author
      retVal.itemInfo.author = () {
        String retStr = '';
        var tablelElement = rootElement?.children
            .firstWhere((element) => element.localName == 'table');
        if (tablelElement?.children != null) {
          if (tablelElement?.children.first.localName == 'tbody') {
            tablelElement = tablelElement?.children.first;
          }
        }

        for (Element tr in tablelElement?.children ?? []) {
          for (Element td in tr.children) {
            final alink =
                td.children.firstWhere((element) => element.localName == 'a');
            if (alink.attributes['name'] == 'postfp') {
              retStr = StringUtil()
                  .substring(td.innerHtml, start: '：', end: alink.outerHtml);
              return retStr;
            }
          }
        }
        return retStr;
      }();

      return Result.success(data: retVal);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }
}
