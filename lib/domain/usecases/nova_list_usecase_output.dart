import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

class NovaListUseCaseOutput {}

class PresentModel extends NovaListUseCaseOutput {
  final List<NovaListUseCaseRowModel> model;
  PresentModel(this.model);
}

class NovaListUseCaseRowModel {
  NovaItemInfo itemInfo;

  NovaListUseCaseRowModel(NovaListItem entity) : itemInfo = entity.itemInfo;
}
