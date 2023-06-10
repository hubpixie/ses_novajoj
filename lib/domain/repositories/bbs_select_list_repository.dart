import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchBbsNovaSelectListRepoInput {
  String targetUrl;
  String searchedKeyword;
  int pageIndex;
  NovaDocType docType;

  FetchBbsNovaSelectListRepoInput(
      {required this.targetUrl,
      this.searchedKeyword = '',
      this.pageIndex = 1,
      required this.docType});
}

abstract class BbsNovaSelectListRepository {
  Future<Result<List<BbsNovaSelectListItem>>> fetchBbsNovaSelectList(
      {required FetchBbsNovaSelectListRepoInput input});
}
