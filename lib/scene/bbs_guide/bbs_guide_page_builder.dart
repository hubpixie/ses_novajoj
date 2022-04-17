import 'bbs_guide_page.dart';
import 'bbs_guide_presenter.dart';
import 'bbs_guide_router.dart';

class BbsGuidePageBuilder {
  final BbsGuidePage page;

  BbsGuidePageBuilder._(this.page);

  factory BbsGuidePageBuilder() {
    //final StreamController<int> pageState = StreamController<int>();
    final BbsGuidePageState pageState = BbsGuidePageState(subPageIndex: 0);
    final router = BbsGuideRouterImpl();
    final presenter = BbsGuidePresenterImpl(router: router);
    final page = BbsGuidePage(presenter: presenter, pageState: pageState);

    return BbsGuidePageBuilder._(page);
  }
}
