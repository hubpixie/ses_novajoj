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
  void fetchCitySelect({required CitySelectUseCaseInput input});
  Future<PresentModel> fetchMainCities({required CitySelectUseCaseInput input});
}

class CitySelectUseCaseImpl extends CitySelectUseCase {
  final CitySelectRepositoryImpl repository;
  CitySelectUseCaseImpl() : repository = CitySelectRepositoryImpl();

  @override
  void fetchCitySelect({required CitySelectUseCaseInput input}) async {
    if (input.dataCleared) {
      streamAdd(
          PresentModel(model: CitySelectUseCaseModel(<CityInfo>[], true)));
      return;
    }
    final result = await repository.fetchCityInfos(
        input: FetchCitySelectRepoInput(cityInfo: input.cityInfo));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: CitySelectUseCaseModel(value.cityInfos, false)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  Future<PresentModel> fetchMainCities(
      {required CitySelectUseCaseInput input}) async {
    final list = CityInfoDescript.kMainCities.keys
        .map((elem) => CityInfoDescript.fromCurrentLocale(name: elem))
        .toList();

    return PresentModel(model: CitySelectUseCaseModel(list, false));
  }
}
