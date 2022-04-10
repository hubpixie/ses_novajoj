import '../config/app_env.dart';
import 'app_entry.dart';

void main() {
  // config the app
  AppEnv.configure(Flavor.product);
  // Startup the app
  MyApp.run();
}
