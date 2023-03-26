import 'package:ses_novajoj/foundation/data/user_types.dart';

abstract class CommentListUseCaseOutput {}

class PresentModel extends CommentListUseCaseOutput {
  final CommentListUseCaseModel? model;
  final AppError? error;
  PresentModel({this.model, this.error});
}

class CommentListUseCaseModel {
  NovaItemInfo itemInfo;

  CommentListUseCaseModel(this.itemInfo);
}
