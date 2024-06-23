import 'package:http/http.dart' as http;

class ConnectUtil {
  static bool? _isConncted;
  static Future<bool> isAvailable({bool checksAgain = false}) async {
    if (_isConncted == null || checksAgain) {
      try {
        await http.head(Uri.parse('https://example.com/'));
        _isConncted = true;
      } on Exception catch (_) {
        _isConncted = false;
      }
    }
    return _isConncted!;
  }

  static Future<bool> isUnavailable({bool checksAgain = false}) async {
    if (_isConncted == null || checksAgain) {
      _isConncted = await isAvailable(checksAgain: checksAgain);
    }
    return !_isConncted!;
  }
}
