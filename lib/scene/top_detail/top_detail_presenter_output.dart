import 'package:ses_novajoj/utilities/data/date_util.dart';
import 'package:ses_novajoj/utilities/data/user_types.dart';
import 'package:ses_novajoj/utilities/data/string_util.dart';
import 'package:ses_novajoj/domain/usecases/nova_detail_usecase_output.dart';

abstract class TopDetailPresenterOutput {}

class ShowNovaDetailModel extends TopDetailPresenterOutput {
  final NovaDetailViewModel viewModel;
  ShowNovaDetailModel(this.viewModel);
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
