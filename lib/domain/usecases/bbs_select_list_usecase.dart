import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/bbs_select_list_repository.dart';
import 'package:ses_novajoj/data/repositories/bbs_select_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'bbs_select_list_usecase_output.dart';

class BbsSelectListUseCaseInput {
  String targetUrl;
  String searchedKeyword;
  int targetPageIndex;
  int? pageBlockIndex;
  int? limitPerBlock;

  BbsSelectListUseCaseInput(
      {required this.targetUrl,
      this.searchedKeyword = '',
      this.targetPageIndex = 1,
      this.pageBlockIndex,
      this.limitPerBlock});
}

abstract class BbsSelectListUseCase
    with SimpleBloc<BbsSelectListUseCaseOutput> {
  void fetchBbsSelectList({required BbsSelectListUseCaseInput input});
}

class BbsSelectListUseCaseImpl extends BbsSelectListUseCase {
  final BbsNovaSelectListRepositoryImpl repository;
  BbsSelectListUseCaseImpl() : repository = BbsNovaSelectListRepositoryImpl();

  @override
  void fetchBbsSelectList({required BbsSelectListUseCaseInput input}) async {
    int fetchedBlockItemIndex = 0;
    for (int seq = 0;
        seq < 1; /* ((input.pageBlockIndex ?? 10) <= 1 ? 2 : 1);*/
        seq++) {
      final result = await repository.fetchBbsNovaSelectList(
          input: FetchBbsNovaSelectListRepoInput(
              targetUrl: input.targetUrl,
              searchedKeyword: input.searchedKeyword,
              pageIndex: input.targetPageIndex,
              pageBlockIndex: input.pageBlockIndex ?? 1,
              limitPerBlock: input.limitPerBlock ?? 10,
              fetchedBlockItemIndex: input.limitPerBlock ?? 10,
              docType: NovaDocType.bbsSelect));

      result.when(success: (value) {
        List<BbsNovaSelectListItem> list = value;
        fetchedBlockItemIndex = list.last.itemInfo.fetchedBlockItemIndex ?? 0;
        print("[2]:totolItemCount=${list.last.itemInfo.totolItemClount}");
        streamAdd(PresentModel(
            model: list
                .map((entity) => BbsSelectListUseCaseRowModel(entity))
                .toList()));
      }, failure: (error) {
        streamAdd(PresentModel(error: error));
      });
    }
  }
}
