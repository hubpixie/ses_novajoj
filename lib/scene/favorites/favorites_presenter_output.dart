import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase_output.dart';

abstract class FavoritesPresenterOutput {}

class ShowFavoritesPageModel extends FavoritesPresenterOutput {
  final FavoritesViewModel? viewModel;
  final AppError? error;
  ShowFavoritesPageModel({this.viewModel, this.error});
}

class FavoritesViewModel {
  int id; 

  FavoritesViewModel(FavoritesUseCaseModel model)
      : id = model.id/*,
       name = model.name,
      ...
      */;
}