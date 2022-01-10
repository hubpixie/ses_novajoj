import 'top_list_router.dart';

abstract class TopListPresenter {
  void startLogin(Object context);
  void startTopDetail(Object context);
}

class TopListPresenterImpl extends TopListPresenter {
  final TopListRouter router;

  TopListPresenterImpl({required this.router});
  @override
  void startLogin(Object context) {
    router.gotoLogin(context);
  }

  @override
  void startTopDetail(Object context) {
    router.gotoTopDetail(context);
  }
}
