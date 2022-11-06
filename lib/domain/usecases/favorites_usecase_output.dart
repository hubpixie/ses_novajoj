import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class  FavoritesUseCaseOutput {}

class PresentModel extends FavoritesUseCaseOutput {
  final FavoritesUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class FavoritesUseCaseModel {
  int id;
  String string;

  FavoritesUseCaseModel(this.id, this.string);
}
