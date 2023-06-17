import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/data/app_state.dart';
import 'package:ses_novajoj/scene/foundation/screen_route_manager.dart';
import 'package:ses_novajoj/scene/splash/splash_page_builder.dart';
import 'package:ses_novajoj/l10n/l10n.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const Locale _kLocale = Locale('zh', 'CN');

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = '${_kLocale.languageCode}-${_kLocale.countryCode}';
    return FutureBuilder(future: () async {
      final firApp = kIsWeb ? null : await Firebase.initializeApp();
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          AppState.isDebugEnabled ? true : !kDebugMode);
      FlutterError.onError = (FlutterErrorDetails details) {
        //this line prints the default flutter gesture caught exception in console
        log.severe("Error Library:${details.library}...");
        log.severe("Error :  ${details.exception}");
        log.severe("StackTrace :  ${details.stack}");
        log.severe("----------------------");

        // record into firebase crashlytics
        FirebaseCrashlytics.instance.recordFlutterError(details);
      };
      return firApp;
    }(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
            child: CircularProgressIndicator(
                color: Colors.amber, backgroundColor: Colors.grey[850]));
      }
      return MaterialApp(
        title: 'First News',
        locale: _kLocale,
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
    });
  }

  static void run() {
    // run app
    runApp(const MyApp());
  }
}
