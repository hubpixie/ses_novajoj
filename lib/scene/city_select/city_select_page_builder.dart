import 'city_select_page.dart';
import 'city_select_presenter.dart';
import 'city_select_router.dart';

class CitySelectPageBuilder {
  final CitySelectPage page;

  CitySelectPageBuilder._(this.page);

  factory CitySelectPageBuilder() {
    final router = CitySelectRouterImpl();
    final presenter = CitySelectPresenterImpl(router: router);
    final page = CitySelectPage(presenter: presenter);

    return CitySelectPageBuilder._(page);
  }
}
