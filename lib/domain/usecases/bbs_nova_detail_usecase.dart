import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_detail_repository.dart';
import 'package:ses_novajoj/data/repositories/bbs_nova_detail_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'bbs_nova_detail_usecase_output.dart';

class BbsNovaDetailUseCaseInput {

}

abstract class BbsNovaDetailUseCase with SimpleBloc<BbsNovaDetailUseCaseOutput> {
  void fetchBbsNovaDetail({required BbsNovaDetailUseCaseInput input});
}

class BbsNovaDetailUseCaseImpl extends BbsNovaDetailUseCase {
  final BbsNovaDetailRepositoryImpl repository;
  BbsNovaDetailUseCaseImpl() : repository = BbsNovaDetailRepositoryImpl();

  @override
  void fetchBbsNovaDetail({required BbsNovaDetailUseCaseInput input}) async {
    final result = await repository.fetchBbsNovaDetail(
        input: FetchBbsNovaDetailRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: BbsNovaDetailUseCaseModel(9999, value.toString() /* // TODO: dummy code*/)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
