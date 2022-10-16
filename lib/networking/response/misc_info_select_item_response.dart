import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';

class MiscInfoSelectItemItemRes {
  late UrlSelectInfo urlSelectInfo;

  MiscInfoSelectItemItemRes({required urlSelectInfo});

  MiscInfoSelectItemItemRes.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    int order = json['order'];
    ServiceType serviceType =
        ServiceTypeDescript.fromString(json['service_type'] ?? 'none');
    final urlItemList = (List<dynamic>? inList) {
      return inList != null
          ? inList
              .map((elem) => SimpleUrlInfo(
                  title: elem['title'], urlString: elem['url_string']))
              .toList()
          : <SimpleUrlInfo>[];
    }(json['select'] as List?);

    // set members.
    urlSelectInfo = UrlSelectInfo(
        id: id,
        order: order,
        serviceType: serviceType,
        urlItemList: urlItemList);
  }
}
