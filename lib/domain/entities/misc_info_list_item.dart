import 'package:ses_novajoj/foundation/data/user_types.dart';

class MiscInfoListItem {
  NovaItemInfo itemInfo;
  HistorioInfo? hisInfo;
  HistorioInfo? bookmark;

  MiscInfoListItem({required this.itemInfo, this.hisInfo, this.bookmark});
}
