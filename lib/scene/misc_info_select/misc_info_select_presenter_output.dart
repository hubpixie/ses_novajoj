import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_select_usecase_output.dart';

abstract class MiscInfoSelectPresenterOutput {}

class ShowMiscInfoSelectPageModel extends MiscInfoSelectPresenterOutput {
  final MiscInfoSelectViewModel? viewModel;
  final AppError? error;
  ShowMiscInfoSelectPageModel({this.viewModel, this.error});
}

class MiscInfoSelectViewModelTry {
  NovaItemInfo itemInfo;
  List<SimpleUrlInfo> urlInfoList;

  MiscInfoSelectViewModelTry(this.itemInfo, this.urlInfoList);

/*
  MiscInfoSelectViewModel(MiscInfoSelectUseCaseModel model)
      : id = model.id
       name = model.name,
      ...
      ;*/
}

class MiscInfoSelectViewModel {
  int id;
  MiscInfoSelectViewModel(MiscInfoSelectUseCaseModel model)
      : id = model.id /*
       name = model.name,
      ...*/
  ;
}
