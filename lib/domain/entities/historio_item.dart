import 'package:ses_novajoj/foundation/data/user_types.dart';

class HistorioItem extends HistorioInfo {
  HistorioItem.copy({required HistorioInfo from}) {
    id = from.id;
    createdAt = from.createdAt;
    category = from.category;
    itemInfo = from.itemInfo;
    htmlText = from.htmlText;
  }
}
