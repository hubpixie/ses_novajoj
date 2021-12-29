import 'top_list_router.dart';

abstract class TopListPresenter {
  void startLogin(Object context);
  void startTop(Object context);
}

class TopListPresenterImpl extends TopListPresenter {
  final TopListRouter router;

  TopListPresenterImpl({required this.router});
  @override
  void startLogin(Object context) {
    router.gotoLogin(context);
  }

  @override
  void startTop(Object context) {
    router.gotoTop(context);
  }
}
