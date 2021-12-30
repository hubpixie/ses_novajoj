import 'top_list_page.dart';
import 'top_list_presenter.dart';
import 'top_list_router.dart';

class TopListPageBuilder {
  final TopListPage page;

  TopListPageBuilder._(this.page);

  factory TopListPageBuilder() {
    final router = TopListRouterImpl();
    final presenter = TopListPresenterImpl(router: router);
    final page = TopListPage(presenter: presenter);

    return TopListPageBuilder._(page);
  }
}
