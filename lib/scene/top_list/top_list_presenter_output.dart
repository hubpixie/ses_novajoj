import 'package:ses_novajoj/domain/usecases/nova_list_usecase_output.dart';
import 'package:ses_novajoj/utilities/data/date_util.dart';
import 'package:ses_novajoj/utilities/data/user_types.dart';
import 'package:ses_novajoj/utilities/data/string_util.dart';

abstract class TopListPresenterOutput {}

class ShowNovaListModel extends TopListPresenterOutput {
  final List<NovaListRowViewModel> viewModelList;
  ShowNovaListModel(this.viewModelList);
}

class NovaListRowViewModel {
  NovaItemInfo itemInfo;
  String createAtText;
  String readsText;
  String isNewText;

  NovaListRowViewModel(NovaListUseCaseRowModel model)
      : itemInfo = model.itemInfo,
        createAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)'),
        readsText = StringUtil().thousandFormat(model.itemInfo.reads),
        isNewText = model.itemInfo.isNew ? 'NEW' : '';
}
