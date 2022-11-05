import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase_output.dart';

abstract class HistorioPresenterOutput {}

class ShowHistorioPageModel extends HistorioPresenterOutput {
  final List<HistorioViewModel>? viewModelList;
  final AppError? error;
  ShowHistorioPageModel({this.viewModelList, this.error});

  List<HistorioViewModel>? _viewModelList;
  List<HistorioViewModel>? get reshapedViewModelList => () {
        if (viewModelList == null) {
          return null;
        }
        if (_viewModelList != null) {
          return _viewModelList;
        }
        HistorioViewModel? prevModel;
        _viewModelList = [...viewModelList!];
        for (final HistorioViewModel model in _viewModelList!) {
          if (prevModel?.createdAtText == model.createdAtText) {
            model.createdAtText = '';
          } else {
            prevModel = model;
          }
        }
        return _viewModelList;
      }();
}

class HistorioViewModel {
  HistorioInfo hisInfo;
  String createdAtText;
  String itemInfoCreatedAtText;

  HistorioViewModel(HistorioUseCaseModel model)
      : hisInfo = model.hisInfo,
        createdAtText = model.hisInfo.createdAtText,
        itemInfoCreatedAtText = DateUtil().getDateString(
            date: model.hisInfo.itemInfo.createAt, format: 'M/d (E)');
}
