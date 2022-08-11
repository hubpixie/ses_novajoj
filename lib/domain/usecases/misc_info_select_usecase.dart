import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_select_repository.dart';
import 'package:ses_novajoj/data/repositories/misc_info_select_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'misc_info_select_usecase_output.dart';

class MiscInfoSelectUseCaseInput {

}

abstract class MiscInfoSelectUseCase with SimpleBloc<MiscInfoSelectUseCaseOutput> {
  void fetchMiscInfoSelect({required MiscInfoSelectUseCaseInput input});
}

class MiscInfoSelectUseCaseImpl extends MiscInfoSelectUseCase {
  final MiscInfoSelectRepositoryImpl repository;
  MiscInfoSelectUseCaseImpl() : repository = MiscInfoSelectRepositoryImpl();

  @override
  void fetchMiscInfoSelect({required MiscInfoSelectUseCaseInput input}) async {
    final result = await repository.fetchMiscInfoSelect(
        input: FetchMiscInfoSelectRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: MiscInfoSelectUseCaseModel(9999, value.toString() /* // TODO: dummy code*/)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
