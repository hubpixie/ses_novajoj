import 'dart:convert';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/domain/entities/historio_item.dart';
import 'package:ses_novajoj/domain/repositories/historio_repository.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/networking/response/historio_item_response.dart';

class HistorioRepositoryImpl extends HistorioRepository {
  // sigleton
  static final HistorioRepositoryImpl _instance =
      HistorioRepositoryImpl._internal();
  HistorioRepositoryImpl._internal();
  factory HistorioRepositoryImpl() => _instance;

  @override
  Future<Result<List<HistorioItem>>> fetchHistorio(
      {required FetchHistorioRepoInput input}) async {
    // fetch historio
    final favoriteStrings = UserData().miscFavoritesList;
    final bookmarks = favoriteStrings.map((elem) {
      final jsonData = json.decode(elem);
      HistorioItemRes itemRes = HistorioItemRes.fromJson(jsonData);
      return HistorioItem.copy(from: itemRes);
    }).toList();
    // check hisInfo item is in Favorites.
    bool _isFavorites(String url) {
      final arr = bookmarks
          .where((element) => element.itemInfo.urlString == url)
          .toList();
      return arr.isNotEmpty;
    }

    // fetch historio
    final historioStrings = UserData().miscHistorioList;
    final list = historioStrings.map((elem) {
      final jsonData = json.decode(elem);
      HistorioItemRes itemRes = HistorioItemRes.fromJson(jsonData);
      HistorioItem ret = HistorioItem.copy(from: itemRes);
      ret.itemInfo.isFavorite = _isFavorites(ret.itemInfo.urlString);
      return ret;
    }).toList();
    Result<List<HistorioItem>> result = Result.success(data: list);
    return result;
  }

  @override
  void saveNovaDetailHistory({required FetchHistorioRepoInput input}) {
    if (input.detailItem != null) {
      HistorioInfo historioInfo = () {
        HistorioInfo info = HistorioInfo();
        info.category = input.category ?? '';
        info.id = info.hashCode;
        info.createdAt = DateTime.now();
        info.htmlText = input.detailItem!.toHtmlString();
        info.itemInfo = input.detailItem!.itemInfo;
        return info;
      }();
      HistorioItemRes historioItemRes = HistorioItemRes.as(info: historioInfo);
      final json = historioItemRes.toJson();
      final encoded = jsonEncode(json);

      UserData().insertHistorio(
          historio: encoded,
          url: historioInfo.itemInfo.urlString,
          htmlText: historioInfo.htmlText);
    }
  }
}
