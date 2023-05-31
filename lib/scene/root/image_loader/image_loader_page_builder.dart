import 'image_loader_page.dart';
import 'image_loader_presenter.dart';
import 'image_loader_router.dart';

class ImageLoaderPageBuilder {
  final ImageLoaderPage page;

  ImageLoaderPageBuilder._(this.page);

  factory ImageLoaderPageBuilder() {
    final router = ImageLoaderRouterImpl();
    final presenter = ImageLoaderPresenterImpl(router: router);
    final page = ImageLoaderPage(presenter: presenter);

    return ImageLoaderPageBuilder._(page);
  }
}
