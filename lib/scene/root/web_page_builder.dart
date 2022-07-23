import 'web_page.dart';

class WebPageBuilder {
  final WebPage page;

  WebPageBuilder._(this.page);

  factory WebPageBuilder() {
    const page = WebPage();

    return WebPageBuilder._(page);
  }
}
