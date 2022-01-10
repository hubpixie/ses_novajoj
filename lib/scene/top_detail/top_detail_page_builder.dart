import 'top_detail_page.dart';
import 'top_detail_presenter.dart';
import 'top_detail_router.dart';

class TopDetailPageBuilder {
  final TopDetailPage page;

  TopDetailPageBuilder._(this.page);

  factory TopDetailPageBuilder() {
    final router = TopDetailRouterImpl();
    final presenter = TopDetailPresenterImpl(router: router);
    final page = TopDetailPage(presenter: presenter);

    return TopDetailPageBuilder._(page);
  }
}
