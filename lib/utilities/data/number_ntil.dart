import 'dart:math';

class NumberUtil {
  factory NumberUtil() {
    return _instance;
  }
  NumberUtil._();

  static final _instance = NumberUtil._();

  double randomDoble({Random? source, required num min, required num max}) {
    Random rand = source ?? Random();
    return rand.nextDouble() * (max - min) + min;
  }

  int randomInt({Random? source, required int min, required int max}) {
    Random rand = source ?? Random();
    return rand.nextInt(max - min) + min;
  }
}
