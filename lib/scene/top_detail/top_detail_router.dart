import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class TopDetailRouter {
  void gotoCommentList(Object context);
}

class TopDetailRouterImpl extends TopDetailRouter {
  TopDetailRouterImpl();

  @override
  void gotoCommentList(Object context) {
    Navigator.pushNamed(
        context as BuildContext, ScreenRouteName.commentList.name);
  }
}
