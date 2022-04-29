import 'bbs_menu_page.dart';
import 'bbs_menu_presenter.dart';
import 'bbs_menu_router.dart';

class BbsMenuPageBuilder {
  final BbsMenuPage page;

  BbsMenuPageBuilder._(this.page);

  factory BbsMenuPageBuilder() {
    final BbsMenuPageState pageState =
        BbsMenuPageState(subPageIndex: 0, subPageTitle: '');
    final router = BbsMenuRouterImpl();
    final presenter = BbsMenuPresenterImpl(router: router);
    final page = BbsMenuPage(presenter: presenter, pageState: pageState);

    return BbsMenuPageBuilder._(page);
  }
}
