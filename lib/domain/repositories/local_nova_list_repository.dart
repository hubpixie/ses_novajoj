import 'package:ses_novajoj/domain/entities/local_nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchLocalNovaListRepoInput {
  String targetUrl;
  int pageIndex;
  NovaDocType docType;

  FetchLocalNovaListRepoInput(
      {required this.targetUrl, this.pageIndex = 1, required this.docType});
}

abstract class LocalNovaListRepository {
  Future<Result<List<LocalNovaListItem>>> fetchLocalNovaList(
      {required FetchLocalNovaListRepoInput input});
  Future<Result<String>> fetchThumbUrl(
      {required FetchLocalNovaListRepoInput input});
}
