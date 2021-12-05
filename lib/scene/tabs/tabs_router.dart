import 'package:ses_novajoj/utilities/log_util.dart';

abstract class TabsRouter {
  void gotoLogin();
}

final log = Log().logger;

class TabsRouterImpl extends TabsRouter {
  TabsRouterImpl();

  @override
  void gotoLogin() {
    log.info('gotoLogin');
  }
}
