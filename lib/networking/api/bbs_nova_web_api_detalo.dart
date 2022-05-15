part of 'bbs_nova_web_api.dart';

extension BbsNovaWebApiDetail on BbsNovaWebApi {
  ///
  /// api entry: fetchBbsDetail
  ///
  Future<Result<BbsDetaloItemRes>> fetchBbsDetail(
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
      BbsDetaloItemRes? retVal;

      final rootElement = () {
        final elements = document.getElementsByClassName('show_content');
        if (elements.isEmpty) {
          return document.getElementsByClassName('c-box').first;
        }
        return elements.first;
      }();

      if (parameter.docType == NovaDocType.detail) {
        final infoElements = rootElement.getElementsByClassName('c-box-a');
        if (infoElements.isEmpty) {
          return _parseDetailItems(
              parameter: parameter,
              rootElement: rootElement,
              infoElement: rootElement.getElementsByClassName('tab5').first);
        } else {
          return _parseDetailDivItems(
              parameter: parameter,
              rootElement: rootElement,
              infoElement: infoElements.first);
        }
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
  ///<table border=0 align=center>
  ///...
  ///    <tr bgcolor='#E6E6DD'>
  ///        <td class="show_content">
  ///            <center>
  ///                <font size=6><b>Title</b></font>
  ///            </center>
  ///            <!--#echo banner=""-->
  ///            <table cellpadding=5 cellspacing=0 border=0 class="tab5">
  ///                <tr>
  ///                    <td height='23px'>
  ///                        送交者: <a
  ///                            href='https://home.6park.com/index.php?app=home&act=chatnew&uname=NTA4NDc1NDM%3D'>狂心中</a>[<a
  ///                            href=https://home.6park.com/index.php?app=home#selfg>
  ///                            <font color=black>♂☆★★★★如狂★★★★☆♂</font>
  ///                        </a>] 于 2022-04-07 19:10 已读 5332 次 15 赞 <button
  ///                            onclick="changefont(this)">大字阅读</button>&nbsp;</td>
  ///                    <td></td>
  ///                    <td class="w10"></td>
  ///                </tr>
  ///            </table>
  ///            <!--bodybegin-->
  ///            <pre>
  ///<p>【1】XXXXXX<br /><p><center><img myDataSrc="https://www.popo8.com/host/data/202204/07/21/p1649376704_376type_jpeg_size_1080_80_end.jpg"  src="https://tva4.sinaimg.cn/mw2000/bc922383gy1h113d6z8zyj20u011i1kx.jpg"></center><br />
  ///...</pre>
  ///            <!--bodyend-->
  ///        </td>
  ///    </tr>
  ///    <tr bgcolor='#E6E6DD'>
  ///        <td height=50 valign=middle>
  ///        </td>
  ///    </tr>
  ///    ...
  ///</table>
  ///
  Future<Result<BbsDetaloItemRes>> _parseDetailItems(
      {required NovaDetaloParameter parameter,
      Element? rootElement,
      Element? infoElement}) async {
    try {
      BbsDetaloItemRes retVal = BbsDetaloItemRes(
          itemInfo: parameter.itemInfo,
          bodyString: reshapeDetailBodyTags(
              rootElement?.getElementsByTagName('pre').first));
      if (rootElement?.children == null) {
        log.severe('rootElement?.children == null');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }

      // <table><tr><td>
      //  <a>author</a>
      //  <a>xxx-xx-xx xx:xx </a>
      // </td></tr></table>
      Element? tdAuthor = (Element? inElement) {
        final element = inElement?.children.first;
        if (element != null && element.children.isNotEmpty) {
          if (element.localName == 'tbody') {
            return element.children.first.children.first;
          } else {
            return element.children.first;
          }
        }
        return null;
      }(infoElement);

      // createAt (detail)
      retVal.itemInfo.createAt = (DateTime value) {
        String infoStr = tdAuthor?.innerHtml ?? '';
        if (infoStr.isEmpty) {
          return value;
        }
        // XXXX-XX-XX XX:XX *** XXXX
        String dateStr = '';
        final dateLoc = infoStr.indexOf(
            RegExp(r' [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}.*[0-9]+ '),
            0);
        if (dateLoc >= 0) {
          dateStr = infoStr.substring(dateLoc + 1, dateLoc + 17);
        }
        return DateUtil().fromString(dateStr, format: 'yyyy-MM-dd H:mm') ??
            value;
      }(retVal.itemInfo.createAt);

      // author
      retVal.itemInfo.author = () {
        final aLink = tdAuthor?.children
            .firstWhere((element) => element.localName == 'a');
        return aLink?.innerHtml ?? '';
      }();

      return Result.success(data: retVal);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }

  Future<Result<BbsDetaloItemRes>> _parseDetailDivItems(
      {required NovaDetaloParameter parameter,
      Element? rootElement,
      Element? infoElement}) async {
    try {
      String bodyString =
          reshapeDetailBodyTags(rootElement?.getElementsByTagName('pre').first);

      BbsDetaloItemRes retVal = BbsDetaloItemRes(
          itemInfo: parameter.itemInfo, bodyString: bodyString);
      if (rootElement?.children == null) {
        log.severe('rootElement?.children == null');
        throw AppError(
            type: AppErrorType.dataError,
            reason: FailureReason.missingRootNode);
      }

      // <div class="c-box-a"><div>
      //  <a>author</a>
      //  <a>xxx-xx-xx xx:xx </a>
      // </div></div>
      Element? divAuthor = (Element? inElement) {
        final element = inElement?.children.first;
        if (element != null && element.children.isNotEmpty) {
          return element;
        }
        return null;
      }(infoElement);

      // createAt (detail)
      retVal.itemInfo.createAt = (DateTime value) {
        String infoStr = divAuthor?.innerHtml ?? '';
        if (infoStr.isEmpty) {
          return value;
        }
        // XXXX-XX-XX XX:XX *** XXXX
        String dateStr = '';
        final dateLoc = infoStr.indexOf(
            RegExp(r' [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}.*[0-9]+ '),
            0);
        if (dateLoc >= 0) {
          dateStr = infoStr.substring(dateLoc + 1, dateLoc + 17);
        }
        return DateUtil().fromString(dateStr, format: 'yyyy-MM-dd H:mm') ??
            value;
      }(retVal.itemInfo.createAt);

      // author
      retVal.itemInfo.author = () {
        if (divAuthor?.children.isEmpty ?? true) {
          return '';
        }
        final aLink = divAuthor?.children
            .firstWhere((element) => element.localName == 'a');
        return aLink?.innerHtml ?? '';
      }();

      return Result.success(data: retVal);
    } on AppError catch (error) {
      return Result.failure(error: error);
    } on Exception catch (error) {
      return Result.failure(error: AppError.fromException(error));
    }
  }
}
