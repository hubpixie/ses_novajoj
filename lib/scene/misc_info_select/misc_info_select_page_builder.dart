import 'misc_info_select_page.dart';
import 'misc_info_select_presenter.dart';
import 'misc_info_select_router.dart';

class MiscInfoSelectPageBuilder {
  final MiscInfoSelectPage page;

  MiscInfoSelectPageBuilder._(this.page);

  factory MiscInfoSelectPageBuilder() {
    final router = MiscInfoSelectRouterImpl();
    final presenter = MiscInfoSelectPresenterImpl(router: router);
    final page = MiscInfoSelectPage(presenter: presenter);

    return MiscInfoSelectPageBuilder._(page);
  }
}
