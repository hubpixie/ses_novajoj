import 'package:flutter/material.dart';

enum Flavor {
  web,
  develop,
  stagging,
  product,
}

class AppEnv {
  static Flavor? flavor;

  static void configure(Flavor flavor) async {
    WidgetsFlutterBinding.ensureInitialized();
    // if (flavor != Flavor.web) {
    //   await Firebase.initializeApp();
    // }

    AppEnv.flavor = flavor;
  }

  static String getString() {
    switch (AppEnv.flavor) {
      case Flavor.web:
        return "WEB";
      case Flavor.develop:
        return "DEVELOP";
      case Flavor.stagging:
        return "STAGING";
      case Flavor.product:
        return "PRODUCT";
      default:
        return "UNKNOWN";
    }
  }
}
