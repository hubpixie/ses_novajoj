import 'package:ses_novajoj/domain/entities/favorites_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchFavoritesRepoInput {}

abstract class FavoritesRepository {
  Future<Result<List<FavoritesItem>>> fetchFavorites(
      {required FetchFavoritesRepoInput input});
}
