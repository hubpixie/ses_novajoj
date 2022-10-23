import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';

class HistorioItem extends HistorioInfo {
  HistorioItem.copy({required HistorioInfo from}) {
    id = from.id;
    createdAt = from.createdAt;
    category = from.category;
    itemInfo = from.itemInfo;
  }
}
