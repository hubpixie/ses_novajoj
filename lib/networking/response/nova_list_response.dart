class NovaListItemRes {
  int id;
  String thunnailUrlString;
  String title;
  String urlString;
  String source;
  String commentUrlString;
  int commentCount;
  DateTime createAt;
  int reads;
  bool isRead;
  bool isNew;

  NovaListItemRes(
      {required this.id,
      required this.thunnailUrlString,
      required this.title,
      required this.urlString,
      required this.source,
      required this.commentUrlString,
      required this.commentCount,
      required this.createAt,
      required this.reads,
      this.isRead = false,
      this.isNew = false});
}
