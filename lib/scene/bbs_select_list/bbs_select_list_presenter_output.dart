import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/domain/usecases/bbs_select_list_usecase_output.dart';

abstract class BbsSelectListPresenterOutput {}

class ShowBbsSelectListPageModel extends BbsSelectListPresenterOutput {
  final List<BbsSelectListRowViewModel>? viewModelList;
  final AppError? error;
  ShowBbsSelectListPageModel({this.viewModelList, this.error});
}

class BbsSelectListRowViewModel {
  NovaItemInfo itemInfo;

  BbsSelectListRowViewModel(BbsSelectListUseCaseRowModel model)
      : itemInfo = model.itemInfo;

  static String asCreateAtText(DateTime createAt) {
    return DateUtil().getDateString(date: createAt, format: 'yyyy/MM/dd');
  }
}
