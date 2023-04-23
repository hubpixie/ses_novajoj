import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';

abstract class WebRouter {
  void gotoImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList,
      Object? completeHandler});
}

class WebRouterImpl extends WebRouter {
  WebRouterImpl();

  @override
  void gotoImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList,
      Object? completeHandler}) {
    Navigator.pushNamed(
        context as BuildContext, ScreenRouteName.imageLoader.name,
        arguments: {
          ImageLoaderParamKeys.appBarTitle: appBarTitle,
          ImageLoaderParamKeys.imageIndex: imageSrcIndex,
          ImageLoaderParamKeys.imageSrcList: imageSrcList,
        }).then((value) {
      if (completeHandler is Function(int)?) {
        if (value is int) {
          completeHandler?.call(value);
        }
      }
    });
  }
}
