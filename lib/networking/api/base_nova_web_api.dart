import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:html/parser.dart' as html_parser;
import 'package:ses_novajoj/foundation//log_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api_client/base_api_client.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';
import 'package:ses_novajoj/networking/response/misc_info_select_item_response.dart';

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
  /// api entry: fetchNovaItemThumbUrl
  ///
  /// <div id='shownewsc' style="margin:15px;">
  ///       新闻新闻新闻新闻新闻。<br />
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
  ///       <div>
  ///         <div class="OUTBRAIN" data-src="DROP_PERMALINK_HERE" data-widget-id="AR_1"></div> <script type="text/javascript" async="async" src="//widgets.outbrain.com/outbrain.js"></script>
  ///       </div>
  ///       </div>
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

  Future<Result<String>> fetchNovaItemTitle(
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

  String reshapeDetailBodyTags(dynamic inElement) {
    // reshape img tags
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

    // reshape other tags
    Codec<String, String> codec = utf8.fuse(base64);
    final codes = codec
        .decode(kSampleReplacedPkCode.substring(
            0, kSampleReplacedPkCode.length - 2))
        .split('//');
    String retStr = inElement?.innerHtml ?? '';
    retStr = retStr.replaceAll(RegExp(r'' + codes.first), codes.last);
    return retStr;
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

      // make POST request
      final response = await BaseApiClient.client
          .post(Uri.parse(codec.decode(BaseNovaWebApi.kSampleUrlStr)),
              /*headers: headers,*/
              body: dataBody);
      // check the status code for the result
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
      // fetch bbs munu settings
      final response = await BaseApiClient.client
          .get(Uri.parse(BaseNovaWebApi.kBbsMenuSettingUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }

      // set result from response.body.

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
      // fetch bbs munu settings
      final response = await BaseApiClient.client
          .get(Uri.parse(BaseNovaWebApi.kMiscInfoSelectSettingUrl));
      if (response.statusCode >= HttpStatus.badRequest) {
        return Result.failure(
            error: AppError.fromStatusCode(response.statusCode));
      }

      // set result from response.body.
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
