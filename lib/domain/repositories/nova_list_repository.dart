import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/utilities/data/user_types.dart';

class FetchNewsListRepoInput {
  String targetUrl;
  NovaDocType docType;

  FetchNewsListRepoInput({required this.targetUrl, required this.docType});
}

abstract class NovaListRepository {
  Future<List<NovaListItem>> fetchNewsList(
      {required FetchNewsListRepoInput input});
  Future<String> fetchThumbUrl({required FetchNewsListRepoInput input});
}
