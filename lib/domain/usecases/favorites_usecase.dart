import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/favorites_repository.dart';
import 'package:ses_novajoj/data/repositories/favorites_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'favorites_usecase_output.dart';

class FavoritesUseCaseInput {
  HistorioInfo? bookmark;

  FavoritesUseCaseInput({this.bookmark});
}

abstract class FavoritesUseCase with SimpleBloc<FavoritesUseCaseOutput> {
  Future<FavoritesUseCaseOutput> fetchFavorites(
      {required FavoritesUseCaseInput input});
  bool saveBookmark({required FavoritesUseCaseInput input});
}

class FavoritesUseCaseImpl extends FavoritesUseCase {
  final FavoritesRepositoryImpl repository;
  FavoritesUseCaseImpl() : repository = FavoritesRepositoryImpl();

  @override
  Future<FavoritesUseCaseOutput> fetchFavorites(
      {required FavoritesUseCaseInput input}) async {
    final result =
        await repository.fetchFavorites(input: FetchFavoritesRepoInput());
    late List<FavoritesUseCaseModel> list;
    result.when(
        success: (value) {
          list = value.map((elem) => FavoritesUseCaseModel(elem)).toList();
        },
        failure: (error) {});

    return PresentModel(models: list);
  }

  @override
  bool saveBookmark({required FavoritesUseCaseInput input}) {
    return repository.saveBookmark(
        input: FetchFavoritesRepoInput(bookmark: input.bookmark));
  }
}
