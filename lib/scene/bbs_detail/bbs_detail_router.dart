import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class BbsDetailRouter {
  void gotoCommentList(Object context,
      {required String appBarTitle, Object? itemInfo});
}

class BbsDetailRouterImpl extends BbsDetailRouter {
  BbsDetailRouterImpl();

  @override
  void gotoCommentList(Object context,
      {required String appBarTitle, Object? itemInfo}) {
    Navigator.pushNamed(
        context as BuildContext, ScreenRouteName.commentList.name,
        arguments: {
          CommentListParamKeys.appBarTitle: appBarTitle,
          CommentListParamKeys.itemInfo: itemInfo
        });
  }
}
