import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class  ImageLoaderUseCaseOutput {}

class PresentModel extends ImageLoaderUseCaseOutput {
  final ImageLoaderUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class ImageLoaderUseCaseModel {
  int id;
  String string;

  ImageLoaderUseCaseModel(this.id, this.string);
}
