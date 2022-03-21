import 'package:ses_novajoj/domain/entities/local_nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class LocalNovaListUseCaseOutput {}

class PresentModel extends LocalNovaListUseCaseOutput {
  final List<LocalNovaListUseCaseRowModel>? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class LocalNovaListUseCaseRowModel {
  NovaItemInfo itemInfo;

  LocalNovaListUseCaseRowModel(LocalNovaListItem entity)
      : itemInfo = entity.itemInfo;
}
