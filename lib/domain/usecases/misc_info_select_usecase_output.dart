import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class  MiscInfoSelectUseCaseOutput {}

class PresentModel extends MiscInfoSelectUseCaseOutput {
  final MiscInfoSelectUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class MiscInfoSelectUseCaseModel {
  int id;
  String string;

  MiscInfoSelectUseCaseModel(this.id, this.string);
}
