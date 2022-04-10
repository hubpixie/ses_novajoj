import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class TopListRouter {
  void gotoLogin(Object context);
  void gotoTopDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
}

class TopListRouterImpl extends TopListRouter {
  TopListRouterImpl();

  @override
  void gotoLogin(Object context) {
    //log.info('gotoLogin');
  }

  @override
  void gotoTopDetail(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    DateTime startDate = DateTime.now();
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.topDetail.name,
        arguments: {
          TopDetailParamKeys.source: ScreenRouteName.tabs.name,
          TopDetailParamKeys.appBarTitle: appBarTitle,
          TopDetailParamKeys.itemInfo: itemInfo
        }).then((value) {
      if (completeHandler != null && completeHandler is Function) {
        DateTime endDate = DateTime.now();
        if (startDate.add(const Duration(minutes: 3)).millisecondsSinceEpoch <
            endDate.millisecondsSinceEpoch) {
          completeHandler.call();
        }
      }
    });
  }
}
