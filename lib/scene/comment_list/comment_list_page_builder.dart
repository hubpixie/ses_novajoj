import 'comment_list_page.dart';
import 'comment_list_presenter.dart';
import 'comment_list_router.dart';

class CommentListPageBuilder {
  final CommentListPage page;

  CommentListPageBuilder._(this.page);

  factory CommentListPageBuilder() {
    final router = CommentListRouterImpl();
    final presenter = CommentListPresenterImpl(router: router);
    final page = CommentListPage(presenter: presenter);

    return CommentListPageBuilder._(page);
  }
}
