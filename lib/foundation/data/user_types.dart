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
