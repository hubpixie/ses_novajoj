import 'package:ses_novajoj/domain/entities/misc_info_list_item.dart';
// import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchMiscInfoListRepoInput {
  // Object id;
  // String string;

  // FetchMiscInfoListRepoInput({required this.id, required this.string});
}

abstract class MiscInfoListRepository {
  Future<Result<List<MiscInfoListItem>>> fetchMiscInfoList(
      {required FetchMiscInfoListRepoInput input});
}
