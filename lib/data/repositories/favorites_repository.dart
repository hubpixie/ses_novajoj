import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/favorites_item_response.dart';
// import 'package:ses_novajoj/networking/request/favorites_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/favorites_item.dart';
import 'package:ses_novajoj/domain/repositories/favorites_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class FavoritesRepositoryImpl extends FavoritesRepository {
  final MyWebApi _api;

  // sigleton
  static final FavoritesRepositoryImpl _instance =
      FavoritesRepositoryImpl._internal();
  FavoritesRepositoryImpl._internal() : _api = MyWebApi();
  factory FavoritesRepositoryImpl() => _instance;

  @override
  Future<Result<FavoritesItem>> fetchFavorites(

      {required FetchFavoritesRepoInput input}) async {
    Result<FavoritesItem> result =
        Result.success(data: FavoritesItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `Favorites' repository
    return result;
  }
}
