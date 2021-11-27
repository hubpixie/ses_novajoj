import 'package:flutter/material.dart';

enum Flavor {
  web,
  develop,
  stagging,
  product,
}

class AppEnv {
  static Flavor? _flavor;

  static void configure(Flavor flavor) {
    _flavor = flavor;
  }

  static String getString() {
    switch (_flavor) {
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
