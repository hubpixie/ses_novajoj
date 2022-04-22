import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class  BbsNovaDetailUseCaseOutput {}

class PresentModel extends BbsNovaDetailUseCaseOutput {
  final BbsNovaDetailUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class BbsNovaDetailUseCaseModel {
  int id;
  String string;

  BbsNovaDetailUseCaseModel(this.id, this.string);
}
