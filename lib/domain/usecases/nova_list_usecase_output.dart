import 'package:ses_novajoj/domain/entities/nova_list_item.dart';

class NovaListUseCaseOutput {}

class PresentModel extends NovaListUseCaseOutput {
  final List<NovaListUseCaseRowModel> model;
  PresentModel(this.model);
}

class PresentItemDetail extends NovaListUseCaseOutput {}

class NovaListUseCaseRowModel {
  int id;
  String thunnailUrlString;
  String title;
  String urlString;
  DateTime createAt;
  int reads;
  bool isRead;
  bool isNew;

  NovaListUseCaseRowModel(NovaListItem entity)
      : id = entity.id,
        thunnailUrlString = entity.thunnailUrlString,
        title = entity.title,
        urlString = entity.urlString,
        createAt = entity.createAt,
        reads = entity.reads,
        isRead = entity.isRead,
        isNew = entity.isNew;
}
