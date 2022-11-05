import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'nova_detalo_item_response.dart';

class ThreadDetaloItemRes {
  late NovaItemInfo itemInfo;
  late String bodyString;

  ThreadDetaloItemRes({
    required this.itemInfo,
    required this.bodyString,
  });

  ThreadDetaloItemRes.copy({required NovaDetaloItemRes from}) {
    itemInfo = from.itemInfo;
    bodyString = from.bodyString;
  }
}
