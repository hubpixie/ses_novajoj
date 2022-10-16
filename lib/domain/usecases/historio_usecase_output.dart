import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class  HistorioUseCaseOutput {}

class PresentModel extends HistorioUseCaseOutput {
  final HistorioUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class HistorioUseCaseModel {
  int id;
  String string;

  HistorioUseCaseModel(this.id, this.string);
}
