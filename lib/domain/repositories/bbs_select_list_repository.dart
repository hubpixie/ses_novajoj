import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchBbsNovaSelectListRepoInput {
  Object id;
  String string;

  FetchBbsNovaSelectListRepoInput({required this.id, required this.string});
}

abstract class BbsNovaSelectListRepository {
  Future<Result<List<BbsNovaSelectListItem>>> fetchBbsNovaSelectList(
      {required FetchBbsNovaSelectListRepoInput input});
}
