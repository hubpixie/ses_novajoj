import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/utilities/screen_route_enums.dart';
import 'package:ses_novajoj/utilities/log_util.dart';

abstract class TopDetailRouter {
  //void gotoTop(Object context);
}

final log = Log().logger;

class TopDetailRouterImpl extends TopDetailRouter {
  TopDetailRouterImpl();

  // @override
  // void gotoTop(Object context) {
  //   log.info('gotoTop');
  //   Navigator.pushNamed(context as BuildContext, ScreenRouteName.tabs.name);
  // }
}
