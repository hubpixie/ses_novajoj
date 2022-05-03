import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class BbsSelectListRouter {
  void gotoBbsDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
}

class BbsSelectListRouterImpl extends BbsSelectListRouter {
  BbsSelectListRouterImpl();

  @override
  void gotoBbsDetail(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    DateTime startDate = DateTime.now();
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.bbsDetail.name,
        arguments: {
          BbsDetailParamKeys.appBarTitle: appBarTitle,
          BbsDetailParamKeys.itemInfo: itemInfo
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
