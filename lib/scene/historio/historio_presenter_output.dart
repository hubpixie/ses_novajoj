import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';
//import 'package:ses_novajoj/domain/usecases/historio_usecase_output.dart';

abstract class HistorioPresenterOutput {}

class ShowHistorioPageModel extends HistorioPresenterOutput {
  final HistorioViewModel? viewModel;
  final AppError? error;
  ShowHistorioPageModel({this.viewModel, this.error});
}

class HistorioViewModel {
  HistorioInfo hisInfo;
  String createdAtText;

  HistorioViewModel(dynamic model)
      : hisInfo = model.hisInfo,
        createdAtText = (model.hisInfo as HistorioInfo?)?.createdAtText ?? '';
}
