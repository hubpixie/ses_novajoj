import 'package:flutter/material.dart';
import '../config/app_env.dart';
import 'app_entry.dart';

void main() {
  // config the app
  AppEnv.configure(Flavor.stagging);
  // Startup the app
  runApp(const MyApp());
}
