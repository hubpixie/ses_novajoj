import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class FavoritesRouter {
  void gotoWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? htmlText,
      Object? removeAction,
      Object? completeHandler});
}

class FavoritesRouterImpl extends FavoritesRouter {
  FavoritesRouterImpl();

  @override
  void gotoWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? htmlText,
      Object? removeAction,
      Object? completeHandler}) {
    // customize menu itemsz of detail page
    BuildContext context_ = context as BuildContext;

    final menuActions = [
      null,
      removeAction == null
          ? null
          : () {
              Navigator.of(context_).pop();
              if (removeAction is Function) {
                removeAction.call();
              }
            }
    ];

    // Transfer to web page / detail page.
    Navigator.pushNamed(context_, ScreenRouteName.webPage.name, arguments: {
      WebPageParamKeys.appBarTitle: appBarTitle,
      WebPageParamKeys.itemInfo: itemInfo,
      WebPageParamKeys.htmlText: htmlText,
      WebPageParamKeys.menuItems: [
        DetailMenuItem.openOriginal,
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
