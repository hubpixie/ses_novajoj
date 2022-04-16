import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_guide_usecase_output.dart';

abstract class BbsGuidePresenterOutput {}

class ShowBbsGuidePageModel extends BbsGuidePresenterOutput {
  final List<BbsGuideListViewRowModel>? viewModelList;
  final AppError? error;
  ShowBbsGuidePageModel({this.viewModelList, this.error});
}

class BbsGuideListViewRowModel {
  NovaItemInfo itemInfo;
  String createAtText;
  String readsText;
  String isNewText;

  BbsGuideListViewRowModel(BbsNovaGuideUseCaseRowModel model)
      : itemInfo = model.itemInfo,
        createAtText = DateUtil()
            .getDateString(date: model.itemInfo.createAt, format: 'M/d (E)'),
        readsText = StringUtil().thousandFormat(model.itemInfo.reads),
        isNewText = model.itemInfo.isNew ? 'NEW' : '';
}
