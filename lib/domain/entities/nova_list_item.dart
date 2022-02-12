class NovaListItem {
  int id;
  String thunnailUrlString;
  String title;
  String urlString;
  DateTime createAt;
  int reads;
  bool isRead;
  bool isNew;

  NovaListItem(
      {required this.id,
      required this.thunnailUrlString,
      required this.title,
      required this.urlString,
      required this.createAt,
      required this.reads,
      this.isRead = false,
      this.isNew = false});
}
