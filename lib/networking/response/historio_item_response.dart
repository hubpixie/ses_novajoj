import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'nova_detalo_item_response.dart';

class HistorioItemRes extends HistorioInfo {
  HistorioItemRes.as({required HistorioInfo info}) {
    id = info.id;
    category = info.category;
    createdAt = info.createdAt;
    htmlText = info.htmlText;
    itemInfo = info.itemInfo;
  }

  HistorioItemRes.fromJson(Map<String, dynamic> json) {
    NovaDetaloItemRes detaloItemRes = NovaDetaloItemRes.fromJson(json);
    id = json['id'];
    category = json['category'];
    createdAt = DateTime.parse(json['created_at']);
    htmlText = '--'; //detaloItemRes.bodyString;
    itemInfo = detaloItemRes.itemInfo;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    NovaDetaloItemRes detaloItemRes =
        NovaDetaloItemRes(bodyString: htmlText ?? '', itemInfo: itemInfo);
    Map<String, dynamic> detaloItemResData = detaloItemRes.toJson();
    data['id'] = id;
    data['category'] = category;
    data['created_at'] = createdAt.toString();
    data['html_text'] = '--';
    data['nova_item_info'] = detaloItemResData['nova_item_info'];
    return data;
  }
}
