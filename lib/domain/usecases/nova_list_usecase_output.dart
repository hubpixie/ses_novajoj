import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

class NovaListUseCaseOutput {}

class PresentModel extends NovaListUseCaseOutput {
  final List<NovaListUseCaseRowModel>? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class NovaListUseCaseRowModel {
  NovaItemInfo itemInfo;

  NovaListUseCaseRowModel(NovaListItem entity) : itemInfo = entity.itemInfo;
}
