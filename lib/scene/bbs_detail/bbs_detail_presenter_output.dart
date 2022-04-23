import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_detail_usecase_output.dart';

abstract class BbsDetailPresenterOutput {}

class ShowBbsDetailPageModel extends BbsDetailPresenterOutput {
  final BbsDetailViewModel? viewModel;
  final AppError? error;
  ShowBbsDetailPageModel({this.viewModel, this.error});
}

class BbsDetailViewModel {
  NovaItemInfo itemInfo;
  String htmlText;
  String createAtText;
  String readsText;
  String isNewText;

  BbsDetailViewModel(BbsNovaDetailUseCaseModel model)
      : itemInfo = model.itemInfo,
        htmlText = model.htmlText,
        createAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)'),
        readsText = StringUtil().thousandFormat(model.itemInfo.reads),
        isNewText = model.itemInfo.isNew ? 'NEW' : '';
}
