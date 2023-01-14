import 'package:ses_novajoj/domain/entities/bbs_select_list_item.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/bbs_select_list_repository.dart';
import 'package:ses_novajoj/data/repositories/bbs_select_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'bbs_select_list_usecase_output.dart';

class BbsSelectListUseCaseInput {
  String targetUrl;
  int targetPageIndex;
  BbsSelectListUseCaseInput(
      {required this.targetUrl, this.targetPageIndex = 1});
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
    final result = await repository.fetchBbsNovaSelectList(
        input: FetchBbsNovaSelectListRepoInput(
            targetUrl: input.targetUrl,
            pageIndex: input.targetPageIndex,
            docType: NovaDocType.bbsSelect));

    result.when(success: (value) {
      List<BbsNovaSelectListItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => BbsSelectListUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
