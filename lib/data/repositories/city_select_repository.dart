import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/weather_web_api.dart';
import 'package:ses_novajoj/networking/response/city_select_item_response.dart';
import 'package:ses_novajoj/networking/request/city_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/city_select_item.dart';
import 'package:ses_novajoj/domain/repositories/city_select_repository.dart';

class CitySelectRepositoryImpl extends CitySelectRepository {
  final WeatherWebApi _api;

  // sigleton
  static final CitySelectRepositoryImpl _instance =
      CitySelectRepositoryImpl._internal();
  CitySelectRepositoryImpl._internal() : _api = WeatherWebApi();
  factory CitySelectRepositoryImpl() => _instance;

  @override
  Future<Result<CitySelectItem>> fetchCityInfos(
      {required FetchCitySelectRepoInput input}) async {
    Result<CitySelectItemRes> result = await _api.getWeatherCities(
        paramter: CitytItemParameter(cityInfo: input.cityInfo));

    late Result<CitySelectItem> ret;
    late CitySelectItem retVal;

    result.when(success: (response) {
      if (response.cityInfos != null) {
        retVal = CitySelectItem(cityInfos: response.cityInfos ?? []);
      } else {
        assert(false, "Unresolved error: response is null");
      }
      ret = Result.success(data: retVal);
    }, failure: (error) {
      ret = Result.failure(error: error);
    });
    return ret;
  }
}
