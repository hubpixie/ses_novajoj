import 'package:ses_novajoj/foundation/log_util.dart';

abstract class BbsMenuRouter {
  void gotoBbsSelectList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? completeHandler});
}

class BbsMenuRouterImpl extends BbsMenuRouter {
  BbsMenuRouterImpl();

  @override
  void gotoBbsSelectList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? completeHandler}) {
    log.info(
        'gotoBbsSelectList: appBarTitle=$appBarTitle, targetUrl=$targetUrl');
    //Navigator.pushNamed(context as BuildContext, ScreenRouteName.tabs.name);
  }
}
