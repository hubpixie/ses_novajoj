import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class  CitySelectUseCaseOutput {}

class PresentModel extends CitySelectUseCaseOutput {
  final CitySelectUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class CitySelectUseCaseModel {
  int id;
  String string;

  CitySelectUseCaseModel(this.id, this.string);
}
