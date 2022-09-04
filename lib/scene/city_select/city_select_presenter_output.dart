import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/city_select_usecase_output.dart';

abstract class CitySelectPresenterOutput {}

class ShowCitySelectPageModel extends CitySelectPresenterOutput {
  final CitySelectViewModel? viewModel;
  final AppError? error;
  ShowCitySelectPageModel({this.viewModel, this.error});
}

class CitySelectViewModel {
  int id; 

  CitySelectViewModel(CitySelectUseCaseModel model)
      : id = model.id/*,
       name = model.name,
      ...
      */;
}