import 'package:intl/intl.dart';

class StringUtil {
  static final StringUtil _instance = StringUtil._internal();
  factory StringUtil() {
    return _instance;
  }
  StringUtil._internal();

  String substring(String string,
      {required String start, required String end}) {
    int pos1 = 0;
    if (start.isNotEmpty) {
      pos1 = string.indexOf(start);
    }
    int pos2 = string.indexOf(end);
    if (end.isEmpty) {
      pos2 = string.length - 1;
    } else {
      if (pos2 < pos1) {
        pos2 = string.indexOf(end, pos1 + start.length);
      }
    }
    if (pos1 < 0) {
      return string;
    }
    pos1 = pos1 + start.length;
    if (pos2 < 0 || pos2 < pos1) {
      return string;
    }
    return string.substring(pos1, pos2);
  }

  String subfix(String string, {int width = 0}) {
    int start = string.length - width;
    if (start > 0) {
      return string.substring(start);
    }
    return string;
  }

  String thousandFormat(int value) {
    return NumberFormat('###,##0').format(value);
  }

  String getDefaultLangCode() {
    String locale = Intl.defaultLocale ?? Intl.systemLocale;
    final arr = locale.split('-');
    return arr.isNotEmpty ? arr.first : 'en';
  }
}
