import 'package:ses_novajoj/domain/entities/thread_nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class ThreadNovaListUseCaseOutput {}

class PresentModel extends ThreadNovaListUseCaseOutput {
  final List<ThreadNovaListUseCaseRowModel>? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class ThreadNovaListUseCaseRowModel {
  NovaItemInfo itemInfo;

  ThreadNovaListUseCaseRowModel(ThreadNovaListItem entity)
      : itemInfo = entity.itemInfo;
}
