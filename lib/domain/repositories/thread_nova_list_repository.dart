import 'package:ses_novajoj/domain/entities/thread_nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchThreadNovaListRepoInput {
  String targetUrl;
  NovaDocType docType;

  FetchThreadNovaListRepoInput(
      {required this.targetUrl, required this.docType});
}

abstract class ThreadNovaListRepository {
  Future<Result<List<ThreadNovaListItem>>> fetchThreadNovaList(
      {required FetchThreadNovaListRepoInput input});
  Future<Result<String>> fetchThumbUrl(
      {required FetchThreadNovaListRepoInput input});
}
