import 'top_list_page.dart';
import 'top_list_presenter.dart';
import 'top_list_router.dart';

class TopListPageBuilder {
  static const int subPages = 5;
  final TopListPage page;

  TopListPageBuilder._(this.page);

  factory TopListPageBuilder() {
    final router = TopListRouterImpl();
    List<TopListPresenter> presenters = [];
    for (var idx = 0; idx < subPages; idx++) {
      presenters.add(TopListPresenterImpl(router: router));
    }
    final page = TopListPage(presenters: presenters);

    return TopListPageBuilder._(page);
  }
}
