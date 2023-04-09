import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/root/image_loader/image_loader_page.dart';

abstract class TopDetailRouter {
  void gotoCommentList(Object context,
      {required String appBarTitle, Object? itemInfo});
  void gotoImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList});
}

class TopDetailRouterImpl extends TopDetailRouter {
  TopDetailRouterImpl();

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

  @override
  void gotoImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList}) {
    Navigator.pushNamed(
        context as BuildContext, ScreenRouteName.imageLoader.name,
        arguments: {
          ImageLoaderParamKeys.appBarTitle: appBarTitle,
          ImageLoaderParamKeys.imageIndex: imageSrcIndex,
          ImageLoaderParamKeys.imageSrcList: imageSrcList,
        });
  }
}
