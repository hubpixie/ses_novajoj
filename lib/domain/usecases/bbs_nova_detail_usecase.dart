import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_detail_repository.dart';
import 'package:ses_novajoj/data/repositories/bbs_nova_detail_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'bbs_nova_detail_usecase_output.dart';

class BbsNovaDetailUseCaseInput {
  NovaItemInfo itemInfo;

  BbsNovaDetailUseCaseInput({required this.itemInfo});
}

abstract class BbsNovaDetailUseCase
    with SimpleBloc<BbsNovaDetailUseCaseOutput> {
  void fetchBbsNovaDetail({required BbsNovaDetailUseCaseInput input});
}

class BbsNovaDetailUseCaseImpl extends BbsNovaDetailUseCase {
  final BbsNovaDetailRepositoryImpl repository;
  BbsNovaDetailUseCaseImpl() : repository = BbsNovaDetailRepositoryImpl();

  @override
  void fetchBbsNovaDetail({required BbsNovaDetailUseCaseInput input}) async {
    final result = await repository.fetchBbsNovaDetail(
        input: FetchBbsNovaDetailRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.detail));

    result.when(success: (value) {
      streamAdd(PresentModel(
          model:
              BbsNovaDetailUseCaseModel(value.itemInfo, value.toHtmlString())));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
