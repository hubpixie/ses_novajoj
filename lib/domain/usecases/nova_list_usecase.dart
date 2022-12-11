import 'package:ses_novajoj/domain/repositories/nova_list_repository.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/data/repositories/nova_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

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
        targetUrl: "https:/www.6parknews.com/newspark/index.php?act=hotview",
        docType: NovaDocType.table),
    FetchNewsListRepoInput(
        targetUrl:
            "https://www.6parknews.com/newspark/index.php?app=news&act=hotreply",
        docType: NovaDocType.table),
  ];

  void fetchNewsList({required int targetUrlIndex, String? prefixTitle}) async {
    final result =
        await repository.fetchNewsList(input: _inputUrlData[targetUrlIndex]);

    result.when(success: (value) {
      List<NovaListItem> list = value;
      String prefixTitle_ = prefixTitle ?? '';
      for (var index = 0; index < list.length; index++) {
        if (index < 4) {
          list[index].itemInfo.title =
              prefixTitle_ + list[index].itemInfo.title;
        }
      }
      streamAdd(PresentModel(
          model:
              list.map((entity) => NovaListUseCaseRowModel(entity)).toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  Future<String> fetchThumbUrl({required String itemUrl}) async {
    final result = await repository.fetchThumbUrl(
        input: FetchNewsListRepoInput(
            targetUrl: itemUrl, docType: NovaDocType.thumb));
    String retUrl = '';
    result.when(
        success: (value) {
          retUrl = value;
        },
        failure: (error) {});
    return retUrl;
  }
}
