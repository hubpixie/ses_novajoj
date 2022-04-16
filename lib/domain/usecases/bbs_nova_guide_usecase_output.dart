import 'package:ses_novajoj/domain/entities/bbs_guide_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class BbsNovaGuideUseCaseOutput {}

class PresentModel extends BbsNovaGuideUseCaseOutput {
  final List<BbsNovaGuideUseCaseRowModel>? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class BbsNovaGuideUseCaseRowModel {
  NovaItemInfo itemInfo;

  BbsNovaGuideUseCaseRowModel(BbsGuideListItem entity)
      : itemInfo = entity.itemInfo;
}
