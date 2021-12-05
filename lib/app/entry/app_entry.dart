import 'package:flutter/material.dart';
import 'package:ses_novajoj/utilities/firebase_util.dart';
import 'package:ses_novajoj/scene/root/screen_route_manager.dart';
import 'package:ses_novajoj/scene/splash/splash_page_builder.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: ScreenRouteManager.generateRoute,
      navigatorObservers: <NavigatorObserver>[FirebaseUtil().observer],
      home: SplashPageBuilder().page,
    );
  }
}
