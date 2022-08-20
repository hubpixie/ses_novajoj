import 'package:ses_novajoj/domain/entities/misc_info_select_item.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchMiscInfoSelectRepoInput {}

abstract class MiscInfoSelectRepository {
  Future<Result<List<MiscInfoSelectItem>>> fetchMiscInfoSelectData(
      {required FetchMiscInfoSelectRepoInput input});
}
