import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class BbsSelectListUseCaseOutput {}

class PresentModel extends BbsSelectListUseCaseOutput {
  final List<BbsSelectListUseCaseRowModel>? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class BbsSelectListUseCaseRowModel {
  NovaItemInfo itemInfo;

  BbsSelectListUseCaseRowModel(BbsNovaSelectListItem entity)
      : itemInfo = entity.itemInfo;
}
