import 'dart:io';

enum NovaDocType { list, table, thumb, detail }

class Comment {
  int id;
  String author;
  String createAt;
  String bodyHtmlString;

  Comment(
      {required this.id,
      required this.author,
      required this.createAt,
      required this.bodyHtmlString});
}

class NovaItemInfo {
  int id;
  String thunnailUrlString;
  String title;
  String urlString;
  String source;
  String author;
  DateTime createAt;
  String loadCommentAt;
  List<Comment>? comments;
  String commentUrlString;
  int commentCount;
  int reads;
  bool isRead;
  bool isNew;

  NovaItemInfo(
      {required this.id,
      required this.thunnailUrlString,
      required this.title,
      required this.urlString,
      required this.source,
      required this.author,
      required this.createAt,
      required this.loadCommentAt,
      required this.commentUrlString,
      required this.commentCount,
      required this.reads,
      this.isRead = false,
      this.isNew = false});
}

abstract class PresenterOutput {}

class PresentError extends PresenterOutput {
  final int code;
  final String message;
  final String reason;

  PresentError(this.code, this.message, this.reason);
}

class NetworkType {}

enum AppErrorType {
  network,
  badRequest,
  unauthorized,
  cancel,
  timeout,
  server,
  dataError,
  parserError,
  unknown,
}

class AppError {
  String message;
  String innerMessage;
  AppErrorType type;

  AppError({required this.type, this.message = '', this.innerMessage = ''});
  /*
    if (error is DioError) {
      debugPrint('AppError(DioError): '
          'type is ${error.type}, message is ${error.message}');
      message = error.message;
      switch (error.type) {
        case DioErrorType.other:
          if (error.error is SocketException) {
            // SocketException: Failed host lookup: '***'
            // (OS Error: No address associated with hostname, errno = 7)
            type = AppErrorType.network;
          } else {
            type = AppErrorType.unknown;
          }
          break;
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
          type = AppErrorType.timeout;
          break;
        case DioErrorType.sendTimeout:
          type = AppErrorType.network;
          break;
        case DioErrorType.response:
          // TODO_api: need define more http status;
          switch (error.response?.statusCode) {
            case HttpStatus.badRequest: // 400
              type = AppErrorType.badRequest;
              break;
            case HttpStatus.unauthorized: // 401
              type = AppErrorType.unauthorized;
              break;
            case HttpStatus.internalServerError: // 500
            case HttpStatus.badGateway: // 502
            case HttpStatus.serviceUnavailable: // 503
            case HttpStatus.gatewayTimeout: // 504
              type = AppErrorType.server;
              break;
            default:
              type = AppErrorType.unknown;
              break;
          }
          break;
        case DioErrorType.cancel:
          type = AppErrorType.cancel;
          break;
        default:
          type = AppErrorType.unknown;
      }
    } else {
      debugPrint('AppError(UnKnown): $error');
      type = AppErrorType.unknown;
      message = 'AppError: $error';
    }
    */
  factory AppError.from(Exception error) {
    AppErrorType type = AppErrorType.unknown;
    String msg = '';
    String innerMsg = '';
    if (error is SocketException) {
      SocketException err = error;
      type = AppErrorType.network;
      innerMsg = err.message;
    }
    return AppError(type: type, message: msg, innerMessage: innerMsg);
  }
}
