import 'package:ses_novajoj/domain/repositories/nova_list_repository.dart';
import 'package:ses_novajoj/domain/utilities/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/data/repositories/nova_list_repository.dart';
import 'package:ses_novajoj/utilities/data/user_types.dart';

import 'nova_list_usecase_output.dart';

class NewsListUseCase with SimpleBloc<NovaListUseCaseOutput> {
  final NovaListRepositoryImpl repository;
  NewsListUseCase() : repository = NovaListRepositoryImpl();

  static final List<FetchNewsListRepoInput> _inputUrlData = [
    FetchNewsListRepoInput(
        targetUrl: "https://www.6parknews.com/newspark/index.php",
        docType: NovaDocType.list),
    FetchNewsListRepoInput(
        targetUrl: "https://www.6parknews.com/newspark/index.php?act=longview",
        docType: NovaDocType.list),
    FetchNewsListRepoInput(
        targetUrl: "https://www.6parknews.com/newspark/index.php?act=gold",
        docType: NovaDocType.list),
    FetchNewsListRepoInput(
        targetUrl: "https://www.6parknews.com/newspark/index.php?act=hotview",
        docType: NovaDocType.table),
    FetchNewsListRepoInput(
        targetUrl:
            "https://www.6parknews.com/newspark/index.php?app=news&act=hotreply",
        docType: NovaDocType.table),
  ];

  void fetchNewsList({required int targetUrlIndex, String? prefixTitle}) async {
    List<NovaListItem> list =
        await repository.fetchNewsList(input: _inputUrlData[targetUrlIndex]);
    String prefixTitle_ = prefixTitle ?? '';
    for (var index = 0; index < list.length; index++) {
      if (index < 4) {
        list[index].itemInfo.title = prefixTitle_ + list[index].itemInfo.title;
      }
    }

    streamAdd(PresentModel(
        list.map((entity) => NovaListUseCaseRowModel(entity)).toList()));
  }

  Future<String> fetchThumbUrl({required String itemUrl}) async {
    String retUrl = await repository.fetchThumbUrl(
        input: FetchNewsListRepoInput(
            targetUrl: itemUrl, docType: NovaDocType.thumb));
    return retUrl;
  }
}
