import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase_output.dart';

abstract class MiscInfoListPresenterOutput {}

class ShowMiscInfoListPageModel extends MiscInfoListPresenterOutput {
  final List<MiscInfoListViewModel>? viewModelList;
  final AppError? error;
  ShowMiscInfoListPageModel({this.viewModelList, this.error});

  List<MiscInfoListViewModel>? _viewModelList;
  List<MiscInfoListViewModel>? get reshapedViewModelList => () {
        if (viewModelList == null) {
          return null;
        }
        if (_viewModelList != null) {
          return _viewModelList;
        }
        MiscInfoListViewModel? prevModel;
        _viewModelList = [...viewModelList!];
        for (final MiscInfoListViewModel model in _viewModelList!) {
          if (prevModel?.createdAtText == model.createdAtText) {
            model.createdAtText = '';
          } else {
            prevModel = model;
          }
        }
      }();
}

class MiscInfoListViewModel {
  NovaItemInfo itemInfo;
  HistorioInfo? hisInfo;
  String createdAtText;
  String itemInfoCreatedAtText;

  MiscInfoListViewModel(MiscInfoListUseCaseRowModel model)
      : itemInfo = model.itemInfo,
        hisInfo = model.hisInfo,
        createdAtText = model.hisInfo?.createdAtText ?? '',
        itemInfoCreatedAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)');
}
