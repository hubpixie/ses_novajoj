import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class ThreadNovaDetailUseCaseOutput {}

class PresentModel extends ThreadNovaDetailUseCaseOutput {
  final ThreadNovaDetailUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class ThreadNovaDetailUseCaseModel {
  NovaItemInfo itemInfo;
  String htmlText;

  ThreadNovaDetailUseCaseModel(this.itemInfo, this.htmlText);
}
