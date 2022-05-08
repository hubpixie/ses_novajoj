import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/scene/foundation/screen_route_manager.dart';
import 'package:ses_novajoj/scene/splash/splash_page_builder.dart';
import 'package:ses_novajoj/l10n/l10n.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First News',
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: ScreenRouteManager.generateRoute,
      navigatorObservers:
          kIsWeb ? [] : <NavigatorObserver>[FirebaseUtil().observer],
      home: SplashPageBuilder().page,
    );
  }

  static void run() {
    FlutterError.onError = (FlutterErrorDetails details) {
      //this line prints the default flutter gesture caught exception in console
      log.severe("Error Library:${details.library}...");
      log.severe("Error :  ${details.exception}");
      log.severe("StackTrace :  ${details.stack}");
      log.severe("----------------------");
    };
    runApp(const MyApp());
  }
}
