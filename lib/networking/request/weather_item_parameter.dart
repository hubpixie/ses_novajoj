// ignore_for_file: unnecessary_this

import 'package:ses_novajoj/foundation/data/user_types.dart';

class WeatherItemParamter {
  double latitude;
  double longitude;
  CityInfo? cityParam;

  WeatherItemParamter({this.latitude = 0, this.longitude = 0, this.cityParam});
}
