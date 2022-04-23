import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class BbsNovaDetailUseCaseOutput {}

class PresentModel extends BbsNovaDetailUseCaseOutput {
  final BbsNovaDetailUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class BbsNovaDetailUseCaseModel {
  NovaItemInfo itemInfo;
  String htmlText;

  BbsNovaDetailUseCaseModel(this.itemInfo, this.htmlText);
}
