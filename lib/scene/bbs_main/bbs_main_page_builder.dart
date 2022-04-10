import 'bbs_main_page.dart';
import 'bbs_main_presenter.dart';
import 'bbs_main_router.dart';

class BbsMainPageBuilder {
  final BbsMainPage page;

  BbsMainPageBuilder._(this.page);

  factory BbsMainPageBuilder() {
    final router = BbsMainRouterImpl();
    final presenter = BbsMainPresenterImpl(router: router);
    final page = BbsMainPage(presenter: presenter);

    return BbsMainPageBuilder._(page);
  }
}
