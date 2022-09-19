import 'package:ses_novajoj/domain/entities/city_select_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchCitySelectRepoInput {
  CityInfo cityInfo;

  FetchCitySelectRepoInput({required this.cityInfo});
}

abstract class CitySelectRepository {
  Future<Result<CitySelectItem>> fetchCityInfos(
      {required FetchCitySelectRepoInput input});
}
