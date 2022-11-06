import 'favorites_page.dart';
import 'favorites_presenter.dart';
import 'favorites_router.dart';

class FavoritesPageBuilder {
  final FavoritesPage page;

  FavoritesPageBuilder._(this.page);

  factory FavoritesPageBuilder() {
    final router = FavoritesRouterImpl();
    final presenter = FavoritesPresenterImpl(router: router);
    final page = FavoritesPage(presenter: presenter);

    return FavoritesPageBuilder._(page);
  }
}
