import 'splash_router.dart';

abstract class SplashPresenter {
  void startLogin(Object context);
  void startTop(Object context);
}

class SplashPresenterImpl extends SplashPresenter {
  final SplashRouter router;

  SplashPresenterImpl({required this.router});
  @override
  void startLogin(Object context) {
    router.gotoLogin(context);
  }

  @override
  void startTop(Object context) {
    router.gotoTop(context);
  }
}
