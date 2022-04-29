import 'package:ses_novajoj/domain/entities/bbs_nova_menu_item.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchBbsNovaMenuRepoInput {
  String langCode;

  FetchBbsNovaMenuRepoInput({required this.langCode});
}

abstract class BbsNovaMenuRepository {
  Future<Result<List<BbsNovaMenuItem>>> fetchBbsNovaMenuList(
      {required FetchBbsNovaMenuRepoInput input});
}
