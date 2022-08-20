import 'package:ses_novajoj/domain/entities/misc_info_select_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class MiscInfoSelectUseCaseOutput {}

class PresentModel extends MiscInfoSelectUseCaseOutput {
  final List<MiscInfoSelectUseCaseRowModel>? models;
  final AppError? error;
  PresentModel({this.models, this.error});
}

class MiscInfoSelectUseCaseRowModel {
  UrlSelectInfo urlSelectInfo;

  MiscInfoSelectUseCaseRowModel(MiscInfoSelectItem entity)
      : urlSelectInfo = entity.urlSelectInfo;
}
