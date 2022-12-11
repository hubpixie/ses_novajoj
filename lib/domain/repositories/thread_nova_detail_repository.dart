import 'package:ses_novajoj/domain/entities/thread_nova_detail_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchThreadNovaDetailRepoInput {
  NovaItemInfo itemInfo;
  NovaDocType docType;
  String? htmlText;

  FetchThreadNovaDetailRepoInput(
      {required this.itemInfo, required this.docType, this.htmlText});
}

abstract class ThreadNovaDetailRepository {
  Future<Result<ThreadNovaDetailItem>> fetchThreadNovaDetail(
      {required FetchThreadNovaDetailRepoInput input});
}
