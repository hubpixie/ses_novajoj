import 'package:ses_novajoj/foundation/data/user_types.dart';

class NovaDetailUseCaseOutput {}

class PresentModel extends NovaDetailUseCaseOutput {
  final NovaDetailUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class NovaDetailUseCaseModel {
  NovaItemInfo itemInfo;
  String htmlText;

  NovaDetailUseCaseModel(this.itemInfo, this.htmlText);
}
