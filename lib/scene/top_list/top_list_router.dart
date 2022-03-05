import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page_util/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page_util/screen_route_enums.dart';

abstract class TopListRouter {
  void gotoLogin(Object context);
  void gotoTopDetail(Object context,
      {required String appBarTitle, Object? itemInfo});
}

class TopListRouterImpl extends TopListRouter {
  TopListRouterImpl();

  @override
  void gotoLogin(Object context) {
    //log.info('gotoLogin');
  }

  @override
  void gotoTopDetail(Object context,
      {required String appBarTitle, Object? itemInfo}) {
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.topDetail.name,
        arguments: {
          TopDetailParamKeys.appBarTitle: appBarTitle,
          TopDetailParamKeys.itemInfo: itemInfo
        });
  }
}
