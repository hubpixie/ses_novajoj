import 'dart:io';

enum NovaDocType { none, list, table, thumb, detail }

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

class NetworkType {}

extension ExceptionExt on Exception {
  int getCode() {
    String str = toString().split(":").last.trim();
    return int.tryParse(str) ?? 0;
  }
}

enum AppErrorType {
  network,
  badRequest,
  unauthorized,
  cancel,
  timeout,
  server,
  dataError,
  unknown,
}

enum FailureReason {
  none,
  missingRootNode,
  missingImgNode,
  missingListNode,
  missingTableNode,
  exception,
}

class AppError {
  String message;
  String innerMessage;
  AppErrorType type;
  FailureReason reason;

  AppError(
      {required this.type,
      this.message = '',
      this.innerMessage = '',
      this.reason = FailureReason.none});

  @override
  String toString() {
    String retStr = "AppError type:$type";
    if (message.isNotEmpty) {
      retStr += " message=$message";
    }
    if (reason != FailureReason.none) {
      retStr += " reason=$reason";
    }
    if (innerMessage.isNotEmpty) {
      retStr += " message=$innerMessage";
    }
    return retStr;
  }

  factory AppError.fromException(Exception error) {
    AppErrorType type = AppErrorType.unknown;
    String msg = '';
    String innerMsg = '';
    FailureReason reason = FailureReason.exception;
    if (error is SocketException) {
      SocketException err = error;
      type = AppErrorType.network;
      innerMsg = err.message;
    }

    return AppError(
        type: type, message: msg, innerMessage: innerMsg, reason: reason);
  }

  factory AppError.fromStatusCode(int statusCode) {
    AppErrorType type = AppErrorType.unknown;
    String msg = '';
    String innerMsg = '';
    FailureReason reason = FailureReason.exception;

    switch (statusCode) {
      case HttpStatus.badRequest: // 400
        type = AppErrorType.badRequest;
        break;
      case HttpStatus.unauthorized: // 401
        type = AppErrorType.unauthorized;
        break;
      case HttpStatus.requestTimeout: // 408
        type = AppErrorType.timeout;
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
    return AppError(
        type: type, message: msg, innerMessage: innerMsg, reason: reason);
  }
}
