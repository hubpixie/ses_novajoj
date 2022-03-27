import 'thread_list_page.dart';
import 'thread_list_presenter.dart';
import 'thread_list_router.dart';

class ThreadListPageBuilder {
  final ThreadListPage page;

  ThreadListPageBuilder._(this.page);

  factory ThreadListPageBuilder() {
    final router = ThreadListRouterImpl();
    final presenter = ThreadListPresenterImpl(router: router);
    final page = ThreadListPage(presenter: presenter);

    return ThreadListPageBuilder._(page);
  }
}
