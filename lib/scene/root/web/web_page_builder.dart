import 'package:ses_novajoj/scene/root/web/web_presenter.dart';
import 'package:ses_novajoj/scene/root/web/web_router.dart';

import 'web_page.dart';

class WebPageBuilder {
  final WebPage page;

  WebPageBuilder._(this.page);

  factory WebPageBuilder() {
    final router = WebRouterImpl();
    final presenter = WebPresenterImpl(router: router);
    final page = WebPage(presenter: presenter);

    return WebPageBuilder._(page);
  }
}
