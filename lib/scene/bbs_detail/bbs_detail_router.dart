import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class BbsDetailRouter {
  void gotoCommentList(Object context,
      {required String appBarTitle, Object? itemInfo});
  void gotoImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList,
      dynamic parentViewImage,
      Object? completeHandler});
  void gotoInnerDetail(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
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

  @override
  void gotoImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList,
      dynamic parentViewImage,
      Object? completeHandler}) {
    Navigator.pushNamed(
        context as BuildContext, ScreenRouteName.imageLoader.name,
        arguments: {
          ImageLoaderParamKeys.appBarTitle: appBarTitle,
          ImageLoaderParamKeys.imageIndex: imageSrcIndex,
          ImageLoaderParamKeys.imageSrcList: imageSrcList,
          ImageLoaderParamKeys.parentViewImage: parentViewImage
        }).then((value) {
      if (completeHandler is Function(int)?) {
        if (value is int) {
          completeHandler?.call(value);
        }
      }
    });
  }

  @override
  void gotoInnerDetail(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.bbsDetail.name,
        arguments: {
          BbsDetailParamKeys.appBarTitle: appBarTitle,
          BbsDetailParamKeys.itemInfo: itemInfo
        }).then((value) {
      if (completeHandler != null && completeHandler is Function) {
        completeHandler.call();
      }
    });
  }
}
