import 'package:ses_novajoj/domain/entities/city_select_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchCitySelectRepoInput {
  Object id;
  String string;

  FetchCitySelectRepoInput({required this.id, required this.string});
}

abstract class CitySelectRepository {
  Future<Result<CitySelectItem>> fetchCitySelect(
      {required FetchCitySelectRepoInput input});
}
