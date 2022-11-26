import 'package:ses_novajoj/domain/entities/nova_detail_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchNewsDetailRepoInput {
  NovaItemInfo itemInfo;
  NovaDocType docType;
  String? htmlText;

  FetchNewsDetailRepoInput(
      {required this.itemInfo, required this.docType, this.htmlText});
}

abstract class NovaDetailRepository {
  Future<Result<NovaDetailItem>> fetchNewsDetail(
      {required FetchNewsDetailRepoInput input});
  bool saveBookmark({required FetchNewsDetailRepoInput input});
}
