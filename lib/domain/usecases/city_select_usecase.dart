import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/city_select_repository.dart';
import 'package:ses_novajoj/data/repositories/city_select_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';

import 'city_select_usecase_output.dart';

class CitySelectUseCaseInput {
  CityInfo cityInfo;
  bool dataCleared;
  CitySelectUseCaseInput({required this.cityInfo, this.dataCleared = false});
}

abstract class CitySelectUseCase with SimpleBloc<CitySelectUseCaseOutput> {
  Future<CitySelectUseCaseOutput> fetchCitySelect(
      {required CitySelectUseCaseInput input});
  Future<CitySelectUseCaseOutput> fetchMainCities(
      {required CitySelectUseCaseInput input});
}

class CitySelectUseCaseImpl extends CitySelectUseCase {
  final CitySelectRepositoryImpl repository;
  CitySelectUseCaseImpl() : repository = CitySelectRepositoryImpl();

  @override
  Future<CitySelectUseCaseOutput> fetchCitySelect(
      {required CitySelectUseCaseInput input}) async {
    if (input.dataCleared) {
      return PresentModel(model: CitySelectUseCaseModel(<CityInfo>[], true));
    }
    final result = await repository.fetchCityInfos(
        input: FetchCitySelectRepoInput(cityInfo: input.cityInfo));

    late CitySelectUseCaseOutput output;
    result.when(success: (value) {
      output =
          PresentModel(model: CitySelectUseCaseModel(value.cityInfos, false));
    }, failure: (error) {
      output = PresentModel(error: error);
    });
    return output;
  }

  @override
  Future<CitySelectUseCaseOutput> fetchMainCities(
      {required CitySelectUseCaseInput input}) async {
    final list = CityInfoDescript.kMainCities.keys
        .map((elem) => CityInfoDescript.fromCurrentLocale(name: elem))
        .toList();

    return PresentModel(model: CitySelectUseCaseModel(list, false));
  }
}
