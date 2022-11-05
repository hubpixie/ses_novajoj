import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/favorites_repository.dart';
import 'package:ses_novajoj/data/repositories/favorites_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'favorites_usecase_output.dart';

class FavoritesUseCaseInput {

}

abstract class FavoritesUseCase with SimpleBloc<FavoritesUseCaseOutput> {
  void fetchFavorites({required FavoritesUseCaseInput input});
}

class FavoritesUseCaseImpl extends FavoritesUseCase {
  final FavoritesRepositoryImpl repository;
  FavoritesUseCaseImpl() : repository = FavoritesRepositoryImpl();

  @override
  void fetchFavorites({required FavoritesUseCaseInput input}) async {
    final result = await repository.fetchFavorites(
        input: FetchFavoritesRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: FavoritesUseCaseModel(9999, value.toString() /* // TODO: dummy code*/)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
