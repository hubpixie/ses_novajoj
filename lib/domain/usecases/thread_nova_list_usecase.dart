import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_list_repository.dart';
import 'package:ses_novajoj/data/repositories/thread_nova_list_repository.dart';
import 'package:ses_novajoj/domain/entities/thread_nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'thread_nova_list_usecase_output.dart';

class ThreadNovaListUseCaseInput {
  int itemIndex;
  int targetPageIndex;
  String itemUrl;
  String searchedKeyword;

  ThreadNovaListUseCaseInput(
      {required this.itemIndex,
      this.targetPageIndex = 1,
      this.itemUrl = "",
      this.searchedKeyword = ""});
}

abstract class ThreadNovaListUseCase
    with SimpleBloc<ThreadNovaListUseCaseOutput> {
  void fetchThreadNovaList({required ThreadNovaListUseCaseInput input});
  Future<String> fetchThumbUrl({required ThreadNovaListUseCaseInput input});
}

class ThreadNovaListUseCaseImpl extends ThreadNovaListUseCase {
  final ThreadNovaListRepositoryImpl repository;
  ThreadNovaListUseCaseImpl() : repository = ThreadNovaListRepositoryImpl();

  static final List<FetchThreadNovaListRepoInput> _inputUrlData = [
    FetchThreadNovaListRepoInput(
        // Hots (searched: false)
        targetUrl: "https://club.6parkbbs.com/index.php",
        searchedUrl: "",
        docType: NovaDocType.threadList),
    FetchThreadNovaListRepoInput(
        // Kidding (searched: true)
        targetUrl:
            "https://club.6parkbbs.com/enter1/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/enter1/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // LifeStyle (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/life2/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/life2/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // ChatIdly (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/pk/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/pk/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // MarriageLife (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/life9/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/life9/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}  ",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // TalkHistory (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/chan1/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/chan1/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // Entertainment (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/enter8/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/enter8/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // TalkArmchair (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/military/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/military/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // Economics (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/finance/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/finance/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // Dissertation (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/bolun/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/bolun/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // Gourmet (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/life6/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/life6/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
    FetchThreadNovaListRepoInput(
        // Travel (searched: false)
        targetUrl:
            "https://club.6parkbbs.com/life7/index.php?app=forum&act=cachepage&cp=tree{{page}}",
        searchedUrl:
            "https://club.6parkbbs.com/life7/index.php?action=search&bbsdr=life6&act=threadsearch&app=forum&keywords={{keywords}}&p={{page}}",
        docType: NovaDocType.list),
  ];

  @override
  void fetchThreadNovaList({required ThreadNovaListUseCaseInput input}) async {
    _inputUrlData[input.itemIndex].pageIndex = input.targetPageIndex;
    final result = await repository.fetchThreadNovaList(input: () {
      FetchThreadNovaListRepoInput input_ = _inputUrlData[input.itemIndex];
      input_.searchedKeyword = input.searchedKeyword;
      input_.docType = input.searchedKeyword.isNotEmpty
          ? NovaDocType.threadList
          : NovaDocType.list;
      return input_;
    }());

    result.when(success: (value) {
      List<ThreadNovaListItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => ThreadNovaListUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  Future<String> fetchThumbUrl(
      {required ThreadNovaListUseCaseInput input}) async {
    final result = await repository.fetchThumbUrl(
        input: FetchThreadNovaListRepoInput(
            targetUrl: input.itemUrl,
            searchedUrl: "",
            docType: NovaDocType.thumb));
    String retUrl = '';
    result.when(
        success: (value) {
          retUrl = value;
        },
        failure: (error) {});
    return retUrl;
  }
}
