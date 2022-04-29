import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_menu_usecase_output.dart';

abstract class BbsMenuPresenterOutput {}

class ShowBbsMenuPageModel extends BbsMenuPresenterOutput {
  final List<BbsMenuListRowViewModel>? viewModelList;
  final AppError? error;
  ShowBbsMenuPageModel({this.viewModelList, this.error});
}

class BbsMenuListRowViewModel {
  int id;
  String sectionTitle;
  String title;
  String urlString;
  bool accessFlag;

  BbsMenuListRowViewModel(BbsNovaMenuUseCaseRowModel model)
      : id = model.id,
        sectionTitle = model.sectionTitle,
        title = model.title,
        urlString = model.urlString,
        accessFlag = model.accessFlag;
}
