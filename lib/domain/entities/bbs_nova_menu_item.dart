class BbsNovaMenuItem {
  late int id;
  late String sectionTitle;
  late String title;
  late String urlString;
  late String searchUrlString;
  late bool accessFlag;

  BbsNovaMenuItem({
    required this.id,
    required this.sectionTitle,
    required this.title,
    required this.urlString,
    required this.searchUrlString,
    required this.accessFlag,
  });

  BbsNovaMenuItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    sectionTitle = json['section_title'] ?? '';
    title = json['title'] ?? '';
    urlString = json['url_string'] ?? '';
    searchUrlString = json['search_url_string'] ?? '';
    accessFlag = (json['access_flag'] ?? 0) == 0 ? false : true;
  }
}
