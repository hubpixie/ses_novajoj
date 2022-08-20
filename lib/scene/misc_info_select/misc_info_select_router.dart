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
    BuildContext context_ = context as BuildContext;

    // customize menu items of detail page
    final menuActions = [
      null,
      () {
        Navigator.of(context_).pop();
        Navigator.pushNamed(context_, ScreenRouteName.miscInfoSelect.name,
            arguments: {
              MiscInfoSelectParamKeys.appBarTitle: appBarTitle,
              MiscInfoSelectParamKeys.itemInfo: itemInfo
            });
      }
    ];

    // Transfer to web page / detail page.
    Navigator.pushNamed(context_, ScreenRouteName.webPage.name, arguments: {
      WebPageParamKeys.appBarTitle: appBarTitle,
      WebPageParamKeys.itemInfo: itemInfo,
      WebPageParamKeys.menuItems: [
        DetailMenuItem.openOriginal,
        DetailMenuItem.changeSettings
      ],
      WebPageParamKeys.menuActions: menuActions
    }).then((value) {
      Navigator.of(context_).pop();
      if (completeHandler != null && completeHandler is Function) {
        completeHandler.call();
      }
    });
  }
}
