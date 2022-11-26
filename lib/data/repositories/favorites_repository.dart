import 'dart:convert';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/networking/response/historio_item_response.dart';
import 'package:ses_novajoj/domain/entities/favorites_item.dart';
import 'package:ses_novajoj/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl extends FavoritesRepository {
  // sigleton
  static final FavoritesRepositoryImpl _instance =
      FavoritesRepositoryImpl._internal();
  FavoritesRepositoryImpl._internal();
  factory FavoritesRepositoryImpl() => _instance;

  @override
  Future<Result<List<FavoritesItem>>> fetchFavorites(
      {required FetchFavoritesRepoInput input}) async {
    final historioStrings = UserData().miscFavoritesList;
    final list = historioStrings.map((elem) {
      final jsonData = json.decode(elem);
      HistorioItemRes itemRes = HistorioItemRes.fromJson(jsonData);
      return FavoritesItem.copy(from: itemRes);
    }).toList();
    Result<List<FavoritesItem>> result = Result.success(data: list);
    return result;
  }
}
