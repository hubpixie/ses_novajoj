import 'dart:async';
import 'dart:io';

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

  static Future<bool> isUrlAvailable({required String url}) async {
    bool ret = false;
    try {
      var response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } on Exception catch (_) {}
    return ret;
  }

  static Future<bool> isUnavailable({bool checksAgain = false}) async {
    if (_isConncted == null || checksAgain) {
      _isConncted = await isAvailable(checksAgain: checksAgain);
    }
    return !_isConncted!;
  }
}
