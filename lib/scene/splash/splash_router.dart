import 'package:flutter/foundation.dart';
import 'package:ses_novajoj/utilities/log_util.dart';

abstract class SplashRouter {
  void gotoLogin();
}

final log = Log().logger;

class SplashRouterImpl extends SplashRouter {
  SplashRouterImpl();

  @override
  void gotoLogin() {
    log.info('gotoLogin');
  }
}
