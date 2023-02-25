import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class HistorioRouter {
  void gotoWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? htmlText,
      Object? removeAction,
      Object? changeFavoriteAction,
      Object? completeHandler});
}

class HistorioRouterImpl extends HistorioRouter {
  HistorioRouterImpl();

  @override
  void gotoWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? htmlText,
      Object? removeAction,
      Object? changeFavoriteAction,
      Object? completeHandler}) {
    // customize menu itemsz of detail page
    BuildContext context_ = context as BuildContext;

    final menuActions = [
      null,
      changeFavoriteAction == null
          ? null
          : () {
              Navigator.of(context_).pop();
              if (changeFavoriteAction is Function) {
                changeFavoriteAction.call();
              }
            },
      removeAction == null
          ? null
          : () {
              Navigator.of(context_).pop();
              if (removeAction is Function) {
                removeAction.call();
              }
            },
      () {
        // transfer to comment list page
        Navigator.pushNamed(context_, ScreenRouteName.commentList.name,
            arguments: {
              CommentListParamKeys.appBarTitle: appBarTitle,
              CommentListParamKeys.itemInfo: itemInfo
            });
      }
    ];

    // Transfer to web page / detail page.
    Navigator.pushNamed(context_, ScreenRouteName.webPage.name, arguments: {
      WebPageParamKeys.appBarTitle: appBarTitle,
      WebPageParamKeys.itemInfo: itemInfo,
      WebPageParamKeys.htmlText: htmlText,
      WebPageParamKeys.menuItems: [
        DetailMenuItem.openOriginal,
        DetailMenuItem.favorite,
        DetailMenuItem.removeSettings,
        DetailMenuItem.readComments
      ],
      WebPageParamKeys.menuActions: menuActions
    }).then((value) {
      if (completeHandler is Function) {
        completeHandler.call();
      }
    });
  }
}
