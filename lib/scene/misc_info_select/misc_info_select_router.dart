import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class MiscInfoSelectRouter {
  void gotoWebPage(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
}

class MiscInfoSelectRouterImpl extends MiscInfoSelectRouter {
  MiscInfoSelectRouterImpl();

  @override
  void gotoWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.webPage.name,
        arguments: {
          WebPageParamKeys.appBarTitle: appBarTitle,
          WebPageParamKeys.itemInfo: itemInfo
        }).then((value) {
      Navigator.of(context).pop();
      if (completeHandler != null && completeHandler is Function) {
        completeHandler.call();
      }
    });
  }
}
