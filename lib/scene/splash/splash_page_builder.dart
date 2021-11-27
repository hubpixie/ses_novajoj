import 'splash_page.dart';
import 'splash_presenter.dart';
import 'splash_router.dart';

class SplashPageBuilder {
  final SplashPage page;

  SplashPageBuilder._(this.page);

  factory SplashPageBuilder() {
    final router = SplashRouterImpl();
    final presenter = SplashPresenterImpl(router: router);
    final page = SplashPage(presenter: presenter);

    return SplashPageBuilder._(page);
  }
}
