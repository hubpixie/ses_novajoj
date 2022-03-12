import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/domain/entities/nova_list_item.dart';

class FetchNewsListRepoInput {
  String targetUrl;
  NovaDocType docType;

  FetchNewsListRepoInput({required this.targetUrl, required this.docType});
}

abstract class NovaListRepository {
  Future<Result<List<NovaListItem>>> fetchNewsList(
      {required FetchNewsListRepoInput input});
  Future<Result<String>> fetchThumbUrl({required FetchNewsListRepoInput input});
}
