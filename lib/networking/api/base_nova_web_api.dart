import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:html/parser.dart' as html_parser;
import 'package:ses_novajoj/foundation//log_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api_client/base_api_client.dart';
import 'package:ses_novajoj/networking/request/nova_item_parameter.dart';

class BaseNovaWebApi {
  static const String kSampleUrlStr =
      'aHR0cHM6Ly9ob21lLjZwYXJrLmNvbS9pbmRleC5waHA/YXBwPWxvZ2luJmFjdD1kb2xvZ2lu';
  //'aHR0cHM6Ly93ZWIuNnBhcmtiYnMuY29tL3B1Yl9wYWdlL2hvbWVfbG9naW4ucGhw';
  static const String kSampleUrlParams = 'cGljaG82cGFya0A6d2FoYWhhQF8=';
  static bool _logined = false;

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
      final imgElement = imgElements.firstWhere((element) {
        bool ret = false;
        if (element.attributes.keys.contains("src")) {
          String imgSrc = element.attributes["src"] ?? "";
          ret = imgSrc.contains("https://www.popo8.com/");
          if (ret) {
            return ret;
          }
          return imgSrc.contains(RegExp(r'^https://(.*)\.[a-z]+$'));
        }
        return ret;
      }, orElse: () => imgElements.first);
      String retStr = imgElement.attributes['src'] ?? '';
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

  Future<Result<bool>> performSampleLogin(
      String username, String password) async {
    try {
      if (_logined) {
        return Result.success(data: _logined);
      }
      Codec<String, String> codec = utf8.fuse(base64);
      //Map<String, String> headers = {"Content-type": "application/json"};

      Map<String, String> dataBody = {
        'username': codec.decode(kSampleUrlParams).split('@:').first,
        'password': (String str) {
          return str.substring(0, str.length - 2);
        }(codec.decode(kSampleUrlParams).split('@:').last),
        'dologin': '%20%E7%99%BB%E5%BD%95%20'
      };

      // make POST request
      final response = await BaseApiClient.client
          .post(Uri.parse(codec.decode(kSampleUrlStr)),
              /*headers: headers,*/
              body: dataBody);
      // check the status code for the result
      int statusCode = response.statusCode;

      if (statusCode < HttpStatus.badRequest) {
        _logined = true;
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
