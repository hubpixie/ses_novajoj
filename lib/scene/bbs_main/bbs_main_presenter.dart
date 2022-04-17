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
