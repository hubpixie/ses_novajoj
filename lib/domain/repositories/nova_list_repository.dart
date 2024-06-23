import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/domain/entities/nova_list_item.dart';

class FetchNewsListRepoInput {
  String targetUrl;
  String searchedUrl;
  String searchedKeyword;
  int pageIndex;
  int pageBlockIndex;
  int limitPerBlock;
  int fetchedBlockItemIndex;
  NovaDocType docType;

  FetchNewsListRepoInput(
      {required this.targetUrl,
      this.searchedUrl = '',
      this.searchedKeyword = '',
      this.pageIndex = 1,
      this.pageBlockIndex = 1,
      this.limitPerBlock = 10,
      this.fetchedBlockItemIndex = 0,
      required this.docType});
}

abstract class NovaListRepository {
  Future<Result<List<NovaListItem>>> fetchNewsList(
      {required FetchNewsListRepoInput input});
  Future<Result<String>> fetchThumbUrl({required FetchNewsListRepoInput input});
}
