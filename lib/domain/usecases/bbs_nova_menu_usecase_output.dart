import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/entities/bbs_nova_menu_item.dart';

abstract class BbsNovaMenuUseCaseOutput {}

class PresentModel extends BbsNovaMenuUseCaseOutput {
  final List<BbsNovaMenuUseCaseRowModel>? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class BbsNovaMenuUseCaseRowModel {
  int id;
  String sectionTitle;
  String title;
  String urlString;
  bool accessFlag;

  BbsNovaMenuUseCaseRowModel(BbsNovaMenuItem entity)
      : id = entity.id,
        sectionTitle = entity.sectionTitle,
        title = entity.title,
        urlString = entity.urlString,
        accessFlag = entity.accessFlag;
}
