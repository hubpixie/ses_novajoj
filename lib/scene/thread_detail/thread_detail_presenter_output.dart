import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/domain/usecases/thread_nova_detail_usecase_output.dart';

abstract class ThreadDetailPresenterOutput {}

class ShowThreadDetailPageModel extends ThreadDetailPresenterOutput {
  final ThreadDetailViewModel? viewModel;
  final AppError? error;
  ShowThreadDetailPageModel({this.viewModel, this.error});
}

class ThreadDetailViewModel {
  NovaItemInfo itemInfo;
  String htmlText;
  String createAtText;
  String readsText;
  String isNewText;

  ThreadDetailViewModel(ThreadNovaDetailUseCaseModel model)
      : itemInfo = model.itemInfo,
        htmlText = model.htmlText,
        createAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)'),
        readsText = StringUtil().thousandFormat(model.itemInfo.reads),
        isNewText = model.itemInfo.isNew ? 'NEW' : '';
}
