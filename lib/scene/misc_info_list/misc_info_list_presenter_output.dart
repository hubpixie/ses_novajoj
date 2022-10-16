import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase_output.dart';

abstract class MiscInfoListPresenterOutput {}

class ShowMiscInfoListPageModel extends MiscInfoListPresenterOutput {
  final List<MiscInfoListViewModel>? viewModelList;
  final AppError? error;
  ShowMiscInfoListPageModel({this.viewModelList, this.error});
}

class MiscInfoListViewModel {
  late NovaItemInfo itemInfo;
  HistorioInfo? hisInfo;
  late String createdAtText;

  MiscInfoListViewModel(MiscInfoListUseCaseRowModel model)
      : itemInfo = model.itemInfo,
        createdAtText = "2022/10/1";

  // FIXME:
  MiscInfoListViewModel.dummyData({HistorioInfo? hisInfo}) {
    itemInfo = NovaItemInfo(
        id: 0,
        title: "title",
        urlString: "urlString",
        createAt: DateTime.now());
    hisInfo = hisInfo;
    createdAtText = "";
  }
}
