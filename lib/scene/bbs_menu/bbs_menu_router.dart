import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class BbsMenuRouter {
  void gotoBbsSelectList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? searchedUrl,
      Object? completeHandler});
}

class BbsMenuRouterImpl extends BbsMenuRouter {
  BbsMenuRouterImpl();

  @override
  void gotoBbsSelectList(Object context,
      {required String appBarTitle,
      Object? targetUrl,
      Object? searchedUrl,
      Object? completeHandler}) {
    DateTime startDate = DateTime.now();
    Navigator.pushNamed(
        context as BuildContext, ScreenRouteName.bbsSelectList.name,
        arguments: {
          BbsSelectListParamKeys.appBarTitle: appBarTitle,
          BbsSelectListParamKeys.targetUrl: targetUrl,
          BbsSelectListParamKeys.searchedUrl: searchedUrl
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
