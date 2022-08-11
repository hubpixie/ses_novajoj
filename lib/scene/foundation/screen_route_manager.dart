import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/splash/splash_page_builder.dart';
import 'package:ses_novajoj/scene/tabs/tabs_page_builder.dart';
import 'package:ses_novajoj/scene/top_detail/top_detail_page_builder.dart';
import 'package:ses_novajoj/scene/local_list/local_list_page_builder.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_page_builder.dart';
import 'package:ses_novajoj/scene/thread_detail/thread_detail_page_builder.dart';
import 'package:ses_novajoj/scene/bbs_detail/bbs_detail_page_builder.dart';
import 'package:ses_novajoj/scene/bbs_select_list/bbs_select_list_page_builder.dart';
import 'package:ses_novajoj/scene/misc_info_select/misc_info_select_page_builder.dart';
import 'package:ses_novajoj/scene/root/web_page_builder.dart';

class ScreenRouteManager {
  static Route<dynamic> generateRoute(RouteSettings? settings) {
    ScreenRouteName sr =
        ScreenRouteNameSummary.fromString(settings?.name ?? '');
    switch (sr) {
      case ScreenRouteName.splash:
        return MaterialPageRoute(
            builder: (_) => SplashPageBuilder().page, settings: settings);
      case ScreenRouteName.tabs:
        return MaterialPageRoute(
            builder: (_) => TabsPageBuilder().page, settings: settings);
      case ScreenRouteName.topDetail:
        return MaterialPageRoute(
            builder: (_) => TopDetailPageBuilder().page, settings: settings);
      case ScreenRouteName.localList:
        return MaterialPageRoute(
            builder: (_) => LocalListPageBuilder().page, settings: settings);
      case ScreenRouteName.threadList:
        return MaterialPageRoute(
            builder: (_) => ThreadListPageBuilder().page, settings: settings);
      case ScreenRouteName.threadDetail:
        return MaterialPageRoute(
            builder: (_) => ThreadDetailPageBuilder().page, settings: settings);
      case ScreenRouteName.bbsDetail:
        return MaterialPageRoute(
            builder: (_) => BbsDetailPageBuilder().page, settings: settings);
      case ScreenRouteName.bbsSelectList:
        return MaterialPageRoute(
            builder: (_) => BbsSelectListPageBuilder().page,
            settings: settings);
      case ScreenRouteName.miscInfoSelect:
        return MaterialPageRoute(
            builder: (_) => MiscInfoSelectPageBuilder().page,
            settings: settings);
      case ScreenRouteName.webPage:
        return MaterialPageRoute(
            builder: (_) => WebPageBuilder().page, settings: settings);
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings?.name}'),
                  ),
                ));
    }
  }
}
