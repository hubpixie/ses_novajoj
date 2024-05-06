import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class BbsNovaDetailUseCaseOutput {}

class BbsNovaDetaiPresentModel extends BbsNovaDetailUseCaseOutput {
  final BbsNovaDetailUseCaseModel? model;
  final AppError? error;
  BbsNovaDetaiPresentModel({this.model, this.error});
}

class BbsNovaDetailUseCaseModel {
  NovaItemInfo itemInfo;
  String htmlText;

  BbsNovaDetailUseCaseModel(this.itemInfo, this.htmlText);
}
