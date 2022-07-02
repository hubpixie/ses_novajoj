import 'package:ses_novajoj/domain/entities/detail_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

class NovaDetailItem extends DetailItem {
  NovaDetailItem({required NovaItemInfo itemInfo, required String bodyString})
      : super(itemInfo: itemInfo, bodyString: bodyString);
}
