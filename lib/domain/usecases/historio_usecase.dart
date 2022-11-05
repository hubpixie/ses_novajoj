import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/historio_repository.dart';
import 'package:ses_novajoj/data/repositories/historio_repository.dart';

import 'historio_usecase_output.dart';

class HistorioUseCaseInput {}

abstract class HistorioUseCase with SimpleBloc<HistorioUseCaseOutput> {
  Future<HistorioUseCaseOutput> fetchHistorio(
      {required HistorioUseCaseInput input});
}

class HistorioUseCaseImpl extends HistorioUseCase {
  final HistorioRepositoryImpl repository;
  HistorioUseCaseImpl() : repository = HistorioRepositoryImpl();

  @override
  Future<HistorioUseCaseOutput> fetchHistorio(
      {required HistorioUseCaseInput input}) async {
    final result =
        await repository.fetchHistorio(input: FetchHistorioRepoInput());
    late List<HistorioUseCaseModel> list;
    result.when(
        success: (value) {
          list = value.map((elem) => HistorioUseCaseModel(elem)).toList();
        },
        failure: (error) {});

    return PresentModel(models: list);
  }
}
