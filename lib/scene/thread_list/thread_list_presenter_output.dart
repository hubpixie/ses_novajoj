import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_list_usecase_output.dart';

abstract class ThreadListPresenterOutput {}

class ShowThreadListPageModel extends ThreadListPresenterOutput {
  final List<ThreadNovaListRowViewModel>? viewModelList;
  final AppError? error;
  ShowThreadListPageModel({this.viewModelList, this.error});
}

class ThreadNovaListRowViewModel {
  NovaItemInfo itemInfo;
  String createAtText;
  String readsText;
  String isNewText;

  ThreadNovaListRowViewModel(ThreadNovaListUseCaseRowModel model)
      : itemInfo = model.itemInfo,
        createAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)'),
        readsText = StringUtil().thousandFormat(model.itemInfo.reads),
        isNewText = model.itemInfo.isNew ? 'NEW' : '';
}
