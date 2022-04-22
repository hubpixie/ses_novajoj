import 'package:ses_novajoj/domain/entities/bbs_nova_detail_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchBbsNovaDetailRepoInput {
  Object id;
  String string;

  FetchBbsNovaDetailRepoInput({required this.id, required this.string});
}

abstract class BbsNovaDetailRepository {
  Future<Result<BbsNovaDetailItem>> fetchBbsNovaDetail(
      {required FetchBbsNovaDetailRepoInput input});
}
