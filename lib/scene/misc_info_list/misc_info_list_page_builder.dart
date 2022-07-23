import 'misc_info_list_page.dart';
import 'misc_info_list_presenter.dart';
import 'misc_info_list_router.dart';

class MiscInfoListPageBuilder {
  final MiscInfoListPage page;

  MiscInfoListPageBuilder._(this.page);

  factory MiscInfoListPageBuilder() {
    final router = MiscInfoListRouterImpl();
    final presenter = MiscInfoListPresenterImpl(router: router);
    final page = MiscInfoListPage(presenter: presenter);

    return MiscInfoListPageBuilder._(page);
  }
}
