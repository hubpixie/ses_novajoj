import 'package:ses_novajoj/domain/entities/favorites_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchFavoritesRepoInput {
  Object id;
  String string;

  FetchFavoritesRepoInput({required this.id, required this.string});
}

abstract class FavoritesRepository {
  Future<Result<FavoritesItem>> fetchFavorites(
      {required FetchFavoritesRepoInput input});
}
