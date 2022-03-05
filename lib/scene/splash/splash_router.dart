import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/scene/foundation/page_util/screen_route_enums.dart';

abstract class SplashRouter {
  void gotoLogin(Object context);
  void gotoTop(Object context);
}

class SplashRouterImpl extends SplashRouter {
  SplashRouterImpl();

  @override
  void gotoLogin(Object context) {
    //log.info('gotoLogin');
  }

  @override
  void gotoTop(Object context) {
    log.info('gotoTop');
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.tabs.name);
  }
}
