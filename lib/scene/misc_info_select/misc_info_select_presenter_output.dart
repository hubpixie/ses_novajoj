import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_select_usecase_output.dart';

abstract class MiscInfoSelectPresenterOutput {}

class ShowMiscInfoSelectPageModel extends MiscInfoSelectPresenterOutput {
  final List<MiscInfoSelectViewModel>? viewModelList;
  final AppError? error;
  ShowMiscInfoSelectPageModel({this.viewModelList, this.error});
}

class MiscInfoSelectViewModel {
  UrlSelectInfo urlSelectInfo;

  MiscInfoSelectViewModel(MiscInfoSelectUseCaseRowModel model)
      : urlSelectInfo = model.urlSelectInfo;
}
