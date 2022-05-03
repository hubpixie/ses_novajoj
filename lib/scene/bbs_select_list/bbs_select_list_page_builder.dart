import 'bbs_select_list_page.dart';
import 'bbs_select_list_presenter.dart';
import 'bbs_select_list_router.dart';

class BbsSelectListPageBuilder {
  final BbsSelectListPage page;

  BbsSelectListPageBuilder._(this.page);

  factory BbsSelectListPageBuilder() {
    final router = BbsSelectListRouterImpl();
    final presenter = BbsSelectListPresenterImpl(router: router);
    final page = BbsSelectListPage(presenter: presenter);

    return BbsSelectListPageBuilder._(page);
  }
}
