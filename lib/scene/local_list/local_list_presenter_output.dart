import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/domain/usecases/local_nova_list_usecase_output.dart';

abstract class LocalListPresenterOutput {}

class ShowLocalListPageModel extends LocalListPresenterOutput {
  final List<LocalNovaListRowViewModel>? viewModelList;
  final AppError? error;
  ShowLocalListPageModel({this.viewModelList, this.error});
}

class LocalNovaListRowViewModel {
  NovaItemInfo itemInfo;
  String createAtText;
  String readsText;
  String isNewText;

  LocalNovaListRowViewModel(LocalNovaListUseCaseRowModel model)
      : itemInfo = model.itemInfo,
        createAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)'),
        readsText = StringUtil().thousandFormat(model.itemInfo.reads),
        isNewText = model.itemInfo.isNew ? 'NEW' : '';
}
