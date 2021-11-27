import 'package:simple_logger/simple_logger.dart';

class Log {
  factory Log() {
    _logger.setLevel(Level.INFO, includeCallerInfo: true);
    _logger.levelPrefixes = {};
    return _singleton;
  }
  Log._();

  static final _singleton = Log._();
  static final _logger = SimpleLogger();
  final SimpleLogger logger = _logger;
}
