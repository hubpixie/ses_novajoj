import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/utilities/page_util/screen_route_enums.dart';
import 'package:ses_novajoj/utilities/log_util.dart';
import 'package:ses_novajoj/scene/utilities/page_util/page_parameter.dart';

abstract class TopListRouter {
  void gotoLogin(Object context);
  void gotoTopDetail(Object context);
}

final log = Log().logger;

class TopListRouterImpl extends TopListRouter {
  TopListRouterImpl();

  @override
  void gotoLogin(Object context) {
    log.info('gotoLogin');
  }

  @override
  void gotoTopDetail(Object context) {
    log.info('gotoTopDetail');
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.topDetail.name,
        arguments: {TopDetailParamKeys.url: 'http://www.google.com'});
  }
}
