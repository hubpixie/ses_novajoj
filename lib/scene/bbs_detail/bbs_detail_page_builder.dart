import 'bbs_detail_page.dart';
import 'bbs_detail_presenter.dart';
import 'bbs_detail_router.dart';

class BbsDetailPageBuilder {
  final BbsDetailPage page;

  BbsDetailPageBuilder._(this.page);

  factory BbsDetailPageBuilder() {
    final router = BbsDetailRouterImpl();
    final presenter = BbsDetailPresenterImpl(router: router);
    final page = BbsDetailPage(presenter: presenter);

    return BbsDetailPageBuilder._(page);
  }
}
