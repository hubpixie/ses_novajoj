import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/bbs_select_list_usecase_output.dart';

abstract class BbsSelectListPresenterOutput {}

class ShowBbsSelectListPageModel extends BbsSelectListPresenterOutput {
  final List<BbsSelectListRowViewModel>? viewModelList;
  final AppError? error;
  ShowBbsSelectListPageModel({this.viewModelList, this.error});
}

class BbsSelectListRowViewModel {
  NovaItemInfo itemInfo;
  bool expanded;

  BbsSelectListRowViewModel(BbsSelectListUseCaseRowModel model)
      : itemInfo = model.itemInfo,
        expanded = false;
}
