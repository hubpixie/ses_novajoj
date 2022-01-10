import 'top_detail_router.dart';

abstract class TopDetailPresenter {
  void startTop(Object context);
}

class TopDetailPresenterImpl extends TopDetailPresenter {
  final TopDetailRouter router;

  TopDetailPresenterImpl({required this.router});

  @override
  void startTop(Object context) {
    //router.gotoTop(context);
  }
}
