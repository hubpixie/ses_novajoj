import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class MiscInfoListRouter {
  void gotoSelectPage(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
  void gotoWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? removeAction,
      Object? completeHandler});
}

class MiscInfoListRouterImpl extends MiscInfoListRouter {
  MiscInfoListRouterImpl();

  @override
  void gotoSelectPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    Navigator.pushNamed(
        context as BuildContext, ScreenRouteName.miscInfoSelect.name,
        arguments: {
          MiscInfoSelectParamKeys.appBarTitle: appBarTitle,
          MiscInfoSelectParamKeys.itemInfo: itemInfo
        }).then((value) {
      if (completeHandler != null && completeHandler is Function) {
        completeHandler.call();
      }
    });
  }

  @override
  void gotoWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? removeAction,
      Object? completeHandler}) {
    // customize menu items of detail page
    BuildContext context_ = context as BuildContext;
    final menuActions = [
      null,
      () {
        Navigator.of(context_).pop();
        Navigator.pushNamed(context_, ScreenRouteName.miscInfoSelect.name,
            arguments: {
              MiscInfoSelectParamKeys.appBarTitle: appBarTitle,
              MiscInfoSelectParamKeys.itemInfo: itemInfo
            }).then((value) {
          if (completeHandler is Function) {
            completeHandler.call();
          }
        });
      },
      removeAction == null
          ? null
          : () {
              Navigator.of(context_).pop();
              if (removeAction is Function) {
                removeAction.call();
              }
              if (completeHandler is Function) {
                completeHandler.call();
              }
            }
    ];

    // Transfer to web page / detail page.
    Navigator.pushNamed(context_, ScreenRouteName.webPage.name, arguments: {
      WebPageParamKeys.appBarTitle: appBarTitle,
      WebPageParamKeys.itemInfo: itemInfo,
      WebPageParamKeys.menuItems: [
        DetailMenuItem.openOriginal,
        DetailMenuItem.changeSettings,
        DetailMenuItem.removeSettings
      ],
      WebPageParamKeys.menuActions: menuActions
    }).then((value) {
      if (completeHandler is Function) {
        completeHandler.call();
      }
    });
  }
}
