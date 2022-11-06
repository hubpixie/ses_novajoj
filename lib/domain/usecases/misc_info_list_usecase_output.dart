import 'package:ses_novajoj/domain/entities/misc_info_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class MiscInfoListUseCaseOutput {}

class PresentModel extends MiscInfoListUseCaseOutput {
  final List<MiscInfoListUseCaseRowModel>? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class MiscInfoListUseCaseRowModel {
  NovaItemInfo itemInfo;
  HistorioInfo? hisInfo;
  HistorioInfo? bookmark;
  MiscInfoListUseCaseRowModel(MiscInfoListItem entity)
      : itemInfo = entity.itemInfo,
        hisInfo = entity.hisInfo,
        bookmark = entity.bookmark;
}
