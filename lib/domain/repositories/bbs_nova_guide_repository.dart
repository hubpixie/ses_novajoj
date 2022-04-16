import 'package:ses_novajoj/domain/entities/bbs_guide_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchBbsGuideRepoInput {
  String targetUrl;
  NovaDocType docType;

  FetchBbsGuideRepoInput({required this.targetUrl, required this.docType});
}

abstract class BbsNovaGuideRepository {
  Future<Result<List<BbsGuideListItem>>> fetchBbsNovaGuideList(
      {required FetchBbsGuideRepoInput input});
  Future<Result<String>> fetchThumbUrl({required FetchBbsGuideRepoInput input});
}
