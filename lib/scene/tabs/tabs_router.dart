import 'package:ses_novajoj/foundation/log_util.dart';

abstract class TabsRouter {
  void gotoLogin();
}

class TabsRouterImpl extends TabsRouter {
  TabsRouterImpl();

  @override
  void gotoLogin() {
    log.info('gotoLogin');
  }
}
