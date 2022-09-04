import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/city_select_parameter_response.dart';
// import 'package:ses_novajoj/networking/request/city_select_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/city_select_item.dart';
import 'package:ses_novajoj/domain/repositories/city_select_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class CitySelectRepositoryImpl extends CitySelectRepository {
  final MyWebApi _api;

  // sigleton
  static final CitySelectRepositoryImpl _instance =
      CitySelectRepositoryImpl._internal();
  CitySelectRepositoryImpl._internal() : _api = MyWebApi();
  factory CitySelectRepositoryImpl() => _instance;

  @override
  Future<Result<CitySelectItem>> fetchCitySelect(

      {required FetchCitySelectRepoInput input}) async {
    Result<CitySelectItem> result =
        Result.success(data: CitySelectItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `CitySelect' repository
    return result;
  }
}
