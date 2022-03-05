import 'package:ses_novajoj/domain/entities/nova_detail_item.dart';
import 'package:ses_novajoj/utilities/data/user_types.dart';

class NovaDetailUseCaseOutput {}

class PresentModel extends NovaDetailUseCaseOutput {
  final NovaDetailUseCaseModel model;
  PresentModel(this.model);
}

class NovaDetailUseCaseModel {
  NovaItemInfo itemInfo;
  String htmlText;

  NovaDetailUseCaseModel(this.itemInfo, this.htmlText);
}
