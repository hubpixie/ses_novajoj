import 'package:ses_novajoj/domain/entities/nova_detail_item.dart';
import 'package:ses_novajoj/utilities/data/user_types.dart';

class FetchNewsDetailRepoInput {
  NovaItemInfo itemInfo;
  NovaDocType docType;

  FetchNewsDetailRepoInput({required this.itemInfo, required this.docType});
}

abstract class NovaDetailRepository {
  Future<NovaDetailItem> fetchNewsDetail(
      {required FetchNewsDetailRepoInput input});
}
