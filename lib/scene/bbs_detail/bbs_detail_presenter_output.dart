import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_detail_usecase_output.dart';

abstract class BbsDetailPresenterOutput {}

class ShowBbsDetailPageModel extends BbsDetailPresenterOutput {
  final BbsDetailViewModel? viewModel;
  final AppError? error;
  ShowBbsDetailPageModel({this.viewModel, this.error});
}

class BbsDetailViewModel {
  int id; 

  BbsDetailViewModel(BbsNovaDetailUseCaseModel model)
      : id = model.id/*,
       name = model.name,
      ...
      */;
}