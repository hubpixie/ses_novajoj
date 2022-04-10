import 'package:flutter/foundation.dart';
import '../config/app_env.dart';
import 'app_entry.dart';

void main() {
  // config the app
  AppEnv.configure(kIsWeb ? Flavor.web : Flavor.develop);
  // Startup the app
  MyApp.run();
}
