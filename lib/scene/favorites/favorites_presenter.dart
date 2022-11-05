import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase_output.dart';
import 'favorites_presenter_output.dart';

import 'favorites_router.dart';

class FavoritesPresenterInput {

}

abstract class FavoritesPresenter with SimpleBloc<FavoritesPresenterOutput> {
  void eventViewReady({required FavoritesPresenterInput input});
}

class FavoritesPresenterImpl extends FavoritesPresenter {
  final FavoritesUseCase useCase;
  final FavoritesRouter router;

  FavoritesPresenterImpl({required this.router})
      : useCase = FavoritesUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowFavoritesPageModel(
              viewModel: FavoritesViewModel(event.model!)));
        } else {
          streamAdd(ShowFavoritesPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required FavoritesPresenterInput input}) {
    useCase.fetchFavorites(input: FavoritesUseCaseInput());
  }
}
