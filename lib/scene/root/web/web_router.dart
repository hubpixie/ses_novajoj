import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class WebRouter {
  void gotoImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList,
      dynamic parentViewImage,
      Object? completeHandler});
  void gotoInnerDetail(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      String? htmlText,
      Object? completeHandler});
}

class WebRouterImpl extends WebRouter {
  WebRouterImpl();

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
      String? htmlText,
      Object? completeHandler}) {
    Navigator.pushNamed(context as BuildContext, ScreenRouteName.webPage.name,
        arguments: {
          WebPageParamKeys.appBarTitle: appBarTitle,
          WebPageParamKeys.itemInfo: itemInfo,
          WebPageParamKeys.htmlText: htmlText
        }).then((value) {
      if (completeHandler != null && completeHandler is Function) {
        completeHandler.call();
      }
    });
  }
}
