import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class FavoritesUseCaseOutput {}

class PresentModel extends FavoritesUseCaseOutput {
  final List<FavoritesUseCaseModel>? models;
  final AppError? error;
  PresentModel({this.models, this.error});
}

class FavoritesUseCaseModel {
  HistorioInfo bookmark;

  FavoritesUseCaseModel(this.bookmark);
}
