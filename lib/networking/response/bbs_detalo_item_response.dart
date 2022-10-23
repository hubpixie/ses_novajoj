import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'nova_detalo_item_response.dart';

class BbsDetaloItemRes {
  late NovaItemInfo itemInfo;
  late String bodyString;

  BbsDetaloItemRes({
    required this.itemInfo,
    required this.bodyString,
  });

  BbsDetaloItemRes.copy({required NovaDetaloItemRes from}) {
    itemInfo = from.itemInfo;
    bodyString = from.bodyString;
  }
}
