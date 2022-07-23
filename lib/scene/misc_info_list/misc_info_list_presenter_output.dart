import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase_output.dart';

abstract class MiscInfoListPresenterOutput {}

class ShowMiscInfoListPageModel extends MiscInfoListPresenterOutput {
  final List<MiscInfoListViewModel>? viewModelList;
  final AppError? error;
  ShowMiscInfoListPageModel({this.viewModelList, this.error});
}

class MiscInfoListViewModel {
  NovaItemInfo itemInfo;

  MiscInfoListViewModel(MiscInfoListUseCaseRowModel model)
      : itemInfo = model.itemInfo;
}
