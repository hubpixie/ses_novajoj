import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/city_select_repository.dart';
import 'package:ses_novajoj/data/repositories/city_select_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'city_select_usecase_output.dart';

class CitySelectUseCaseInput {

}

abstract class CitySelectUseCase with SimpleBloc<CitySelectUseCaseOutput> {
  void fetchCitySelect({required CitySelectUseCaseInput input});
}

class CitySelectUseCaseImpl extends CitySelectUseCase {
  final CitySelectRepositoryImpl repository;
  CitySelectUseCaseImpl() : repository = CitySelectRepositoryImpl();

  @override
  void fetchCitySelect({required CitySelectUseCaseInput input}) async {
    final result = await repository.fetchCitySelect(
        input: FetchCitySelectRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: CitySelectUseCaseModel(9999, value.toString() /* // TODO: dummy code*/)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
