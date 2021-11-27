import 'splash_router.dart';

abstract class SplashPresenter {
  void startLogin();
}

class SplashPresenterImpl extends SplashPresenter {
  final SplashRouter router;

  SplashPresenterImpl({required this.router});
  @override
  void startLogin() {
    router.gotoLogin();
  }
}
