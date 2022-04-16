import 'bbs_guide_page.dart';
import 'bbs_guide_presenter.dart';
import 'bbs_guide_router.dart';

class BbsGuidePageBuilder {
  final BbsGuidePage page;

  BbsGuidePageBuilder._(this.page);

  factory BbsGuidePageBuilder() {
    final router = BbsGuideRouterImpl();
    final presenter = BbsGuidePresenterImpl(router: router);
    final page = BbsGuidePage(presenter: presenter);

    return BbsGuidePageBuilder._(page);
  }
}
