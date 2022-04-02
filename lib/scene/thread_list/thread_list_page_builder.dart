import 'thread_list_page.dart';
import 'thread_list_presenter.dart';
import 'thread_list_router.dart';

class ThreadListPageBuilder {
  static const int subPages = 12;
  final ThreadListPage page;

  ThreadListPageBuilder._(this.page);

  factory ThreadListPageBuilder() {
    final router = ThreadListRouterImpl();
    List<ThreadListPresenter> presenters = [];
    for (var idx = 0; idx < subPages; idx++) {
      presenters.add(ThreadListPresenterImpl(router: router));
    }
    final page = ThreadListPage(presenters: presenters);

    return ThreadListPageBuilder._(page);
  }
}
