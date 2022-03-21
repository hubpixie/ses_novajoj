import 'local_list_page.dart';
import 'local_list_presenter.dart';
import 'local_list_router.dart';

class LocalListPageBuilder {
  final LocalListPage page;

  LocalListPageBuilder._(this.page);

  factory LocalListPageBuilder() {
    final router = LocalListRouterImpl();
    final presenter = LocalListPresenterImpl(router: router);
    final page = LocalListPage(presenter: presenter);

    return LocalListPageBuilder._(page);
  }
}
