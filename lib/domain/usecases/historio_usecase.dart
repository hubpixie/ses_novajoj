import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/historio_repository.dart';
import 'package:ses_novajoj/data/repositories/historio_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'historio_usecase_output.dart';

class HistorioUseCaseInput {

}

abstract class HistorioUseCase with SimpleBloc<HistorioUseCaseOutput> {
  void fetchHistorio({required HistorioUseCaseInput input});
}

class HistorioUseCaseImpl extends HistorioUseCase {
  final HistorioRepositoryImpl repository;
  HistorioUseCaseImpl() : repository = HistorioRepositoryImpl();

  @override
  void fetchHistorio({required HistorioUseCaseInput input}) async {
    final result = await repository.fetchHistorio(
        input: FetchHistorioRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: HistorioUseCaseModel(9999, value.toString() /* // TODO: dummy code*/)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
