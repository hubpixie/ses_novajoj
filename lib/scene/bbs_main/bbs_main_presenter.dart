import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';

import 'bbs_main_router.dart';

class BbsMainPresenterInput {}

abstract class BbsMainPresenter {
  void eventViewReady({required BbsMainPresenterInput input});
}

class BbsMainPresenterImpl extends BbsMainPresenter {
  final BbsMainRouter router;

  BbsMainPresenterImpl({required this.router});

  @override
  void eventViewReady({required BbsMainPresenterInput input}) {}
}
