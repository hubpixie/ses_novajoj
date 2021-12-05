import 'tabs_router.dart';

abstract class TabsPresenter {
  void startLogin();
}

class TabsPresenterImpl extends TabsPresenter {
  final TabsRouter router;

  TabsPresenterImpl({required this.router});
  @override
  void startLogin() {
    router.gotoLogin();
  }
}
