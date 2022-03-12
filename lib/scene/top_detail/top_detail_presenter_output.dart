import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/domain/usecases/nova_detail_usecase_output.dart';

abstract class TopDetailPresenterOutput {}

class ShowNovaDetailPageModel extends TopDetailPresenterOutput {
  final NovaDetailViewModel? viewModel;
  final AppError? error;
  ShowNovaDetailPageModel({this.viewModel, this.error});
}

class NovaDetailViewModel {
  NovaItemInfo itemInfo;
  String htmlText;
  String createAtText;
  String readsText;
  String isNewText;

  NovaDetailViewModel(NovaDetailUseCaseModel model)
      : itemInfo = model.itemInfo,
        htmlText = model.htmlText,
        createAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)'),
        readsText = StringUtil().thousandFormat(model.itemInfo.reads),
        isNewText = model.itemInfo.isNew ? 'NEW' : '';
}
