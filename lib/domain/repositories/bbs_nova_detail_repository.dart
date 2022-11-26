import 'package:ses_novajoj/domain/entities/bbs_nova_detail_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchBbsNovaDetailRepoInput {
  NovaItemInfo itemInfo;
  NovaDocType docType;
  String? htmlText;

  FetchBbsNovaDetailRepoInput(
      {required this.itemInfo, required this.docType, this.htmlText});
}

abstract class BbsNovaDetailRepository {
  Future<Result<BbsNovaDetailItem>> fetchBbsNovaDetail(
      {required FetchBbsNovaDetailRepoInput input});
  bool saveBookmark({required FetchBbsNovaDetailRepoInput input});
}
