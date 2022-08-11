import 'package:ses_novajoj/domain/entities/misc_info_select_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchMiscInfoSelectRepoInput {
  Object id;
  String string;

  FetchMiscInfoSelectRepoInput({required this.id, required this.string});
}

abstract class MiscInfoSelectRepository {
  Future<Result<MiscInfoSelectItem>> fetchMiscInfoSelect(
      {required FetchMiscInfoSelectRepoInput input});
}
