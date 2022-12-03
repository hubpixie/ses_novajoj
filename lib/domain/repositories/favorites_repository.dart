import 'package:ses_novajoj/domain/entities/favorites_item.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

class FetchFavoritesRepoInput {
  HistorioInfo? bookmark;
  FetchFavoritesRepoInput({this.bookmark});
}

abstract class FavoritesRepository {
  Future<Result<List<FavoritesItem>>> fetchFavorites(
      {required FetchFavoritesRepoInput input});
  bool saveBookmark({required FetchFavoritesRepoInput input});
}
