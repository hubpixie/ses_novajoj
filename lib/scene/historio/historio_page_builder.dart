import 'historio_page.dart';
import 'historio_presenter.dart';
import 'historio_router.dart';

class HistorioPageBuilder {
  final HistorioPage page;

  HistorioPageBuilder._(this.page);

  factory HistorioPageBuilder() {
    final router = HistorioRouterImpl();
    final presenter = HistorioPresenterImpl(router: router);
    final page = HistorioPage(presenter: presenter);

    return HistorioPageBuilder._(page);
  }
}
