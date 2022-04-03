import 'thread_detail_page.dart';
import 'thread_detail_presenter.dart';
import 'thread_detail_router.dart';

class ThreadDetailPageBuilder {
  final ThreadDetailPage page;

  ThreadDetailPageBuilder._(this.page);

  factory ThreadDetailPageBuilder() {
    final router = ThreadDetailRouterImpl();
    final presenter = ThreadDetailPresenterImpl(router: router);
    final page = ThreadDetailPage(presenter: presenter);

    return ThreadDetailPageBuilder._(page);
  }
}
