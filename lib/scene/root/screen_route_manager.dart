import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/utilities/screen_route_enums.dart';
import 'package:ses_novajoj/scene/splash/splash_page_builder.dart';
import 'package:ses_novajoj/scene/tabs/tabs_page_builder.dart';

class ScreenRouteManager {
  static Route<dynamic> generateRoute(RouteSettings? settings) {
    ScreenRouteName sr =
        ScreenRouteNameSummary.fromString(settings?.name ?? '');
    switch (sr) {
      case ScreenRouteName.tabs:
        return MaterialPageRoute(
            builder: (_) => TabsPageBuilder().page, settings: settings);
      case ScreenRouteName.splash:
        return MaterialPageRoute(
            builder: (_) => SplashPageBuilder().page, settings: settings);
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
