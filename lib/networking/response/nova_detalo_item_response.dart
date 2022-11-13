import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';

class NovaDetaloItemRes {
  NovaItemInfo itemInfo;
  String bodyString;

  NovaDetaloItemRes({
    required this.itemInfo,
    required this.bodyString,
  });

  static NovaDetaloItemRes fromJson(Map<String, dynamic> json) {
    final itemInfo = NovaItemInfoRes.fromJson(json['nova_item_info']);
    return NovaDetaloItemRes(
        itemInfo: itemInfo, bodyString: json['html_text'] ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nova_item_info'] = itemInfo.toJson();
    data['body_string'] = bodyString;
    return data;
  }
}

extension NovaItemInfoRes on NovaItemInfo {
  static NovaItemInfo fromJson(Map<String, dynamic>? data) {
    NovaItemInfo itemInfo =
        NovaItemInfo(id: 0, title: "", urlString: "", createAt: DateTime.now());

    if (data != null) {
      itemInfo.id = data['id'];
      itemInfo.serviceType =
          ServiceTypeDescript.fromString(data['service_type']);
      itemInfo.title = data['title'];
      itemInfo.urlString = data['url_string'];
      itemInfo.thunnailUrlString = data['thunnail_url_string'];
      itemInfo.title = data['title'];
      itemInfo.source = data['source'];
      itemInfo.author = data['author'];
      itemInfo.createAt = DateTime.parse(data['create_at']);
      itemInfo.orderIndex = data['order_index'];
      itemInfo.loadCommentAt = data['load_comment_at'];
      itemInfo.commentUrlString = data['comment_url_string'];
      itemInfo.commentCount = data['comment_count'];
      itemInfo.reads = data['reads'];
      itemInfo.isFavorite = data['is_favorite'] ?? false;
      itemInfo.isRead = data['is_read'];
      itemInfo.isNew = data['is_new'];
    }
    return itemInfo;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['service_type'] = serviceType.stringClass;
    data['title'] = title;
    data['url_string'] = urlString;
    data['thunnail_url_string'] = thunnailUrlString;
    data['source'] = source;
    data['author'] = author;
    data['create_at'] = createAt.toString();
    data['order_index'] = orderIndex;
    data['load_comment_at'] = loadCommentAt;
    data['comment_url_string'] = commentUrlString;
    data['comment_count'] = commentCount;
    data['reads'] = reads;
    data['is_favorite'] = isFavorite;
    data['is_read'] = isRead;
    data['is_new'] = isNew;
    return data;
  }
}
