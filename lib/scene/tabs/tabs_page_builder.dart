import 'tabs_page.dart';
import 'tabs_presenter.dart';
import 'tabs_router.dart';

class TabsPageBuilder {
  final TabsPage page;

  TabsPageBuilder._(this.page);

  factory TabsPageBuilder() {
    final router = TabsRouterImpl();
    final presenter = TabsPresenterImpl(router: router);
    final page = TabsPage(presenter: presenter);

    return TabsPageBuilder._(page);
  }
}
