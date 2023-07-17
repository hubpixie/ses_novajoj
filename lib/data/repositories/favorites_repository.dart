import 'dart:convert';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
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
    final historioStrings = await UserData().miscFavoritesList;
    final list = historioStrings.map((elem) {
      final jsonData = json.decode(elem);
      HistorioItemRes itemRes = HistorioItemRes.fromJson(jsonData);
      return FavoritesItem.copy(from: itemRes);
    }).toList();
    Result<List<FavoritesItem>> result = Result.success(data: list);
    return result;
  }

  @override
  bool saveBookmark({required FetchFavoritesRepoInput input}) {
    if (input.bookmark == null) {
      return true;
    }
    _saveBookmark(bookmark: input.bookmark);
    return true;
  }

  void _saveBookmark({HistorioInfo? bookmark}) async {
    String htmlText = bookmark?.htmlText ?? '';
    if (bookmark != null) {
      HistorioInfo historioInfo = () {
        HistorioInfo info = HistorioInfo();
        info.category = bookmark.category;
        info.id = bookmark.id;
        info.createdAt = bookmark.createdAt;
        info.htmlText = '';
        info.itemInfo = bookmark.itemInfo;
        info.itemInfo.isFavorite = !bookmark.itemInfo.isFavorite;
        return info;
      }();
      HistorioItemRes historioItemRes = HistorioItemRes.as(info: historioInfo);
      final json = historioItemRes.toJson();
      final encoded = jsonEncode(json);

      UserData().saveFavorites(
          bookmark: encoded,
          bookmarkIsOn: historioInfo.itemInfo.isFavorite,
          url: !historioInfo.itemInfo.isInnerLink
              ? historioInfo.itemInfo.urlString
              : historioInfo.itemInfo.previousUrlString,
          innerUrl: historioInfo.itemInfo.isInnerLink
              ? historioInfo.itemInfo.urlString
              : null,
          htmlText: htmlText);
    }
  }
}
