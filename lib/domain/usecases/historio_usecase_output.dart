import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class HistorioUseCaseOutput {}

class PresentModel extends HistorioUseCaseOutput {
  final List<HistorioUseCaseModel>? models;
  final AppError? error;
  PresentModel({this.models, this.error});
}

class HistorioUseCaseModel {
  HistorioInfo hisInfo;

  HistorioUseCaseModel(this.hisInfo);
}
