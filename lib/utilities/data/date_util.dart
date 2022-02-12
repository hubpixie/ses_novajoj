import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateUtil {
  static final DateUtil _instance = DateUtil._internal();
  factory DateUtil() {
    return _instance;
  }
  DateUtil._internal();

  String getDateMdeString({DateTime? date}) {
    Intl.defaultLocale = 'zh_CN';

    DateTime datetime = date ?? DateTime.now();

    var formatter = DateFormat('M/d (E)', "zh_CN");
    return formatter.format(datetime); // DateからString
  }

  String getDateMdeHmsString({DateTime? date}) {
    initializeDateFormatting("zh_CN");

    DateTime datetime = date ?? DateTime.now();
    var wDayFormater = DateFormat("E", "zh_CN");
    String weekDayStr = wDayFormater.format(datetime);
    String weekDayLastStr =
        weekDayStr.length > 1 ? weekDayStr[weekDayStr.length - 1] : weekDayStr;
    var formatter = DateFormat("M/d (E) H:mm:ss", "zh_CN");
    String retStr = formatter.format(datetime);

    return retStr.replaceAll(weekDayStr, weekDayLastStr); // DateからString
  }

  String getDateMDEStringWithTimestamp({int? timestamp, int timezone = 0}) {
    if (timestamp == null) return '';
    initializeDateFormatting("zh_CN");

    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
        (timestamp + timezone) * 1000,
        isUtc: true);

    var formatter = DateFormat('M/d (E)', "zh_CN");
    return formatter.format(datetime); // DateからString
  }

  String getDateMMDDStringWithTimestamp({int? timestamp, int timezone = 0}) {
    if (timestamp == null) return '';
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
        (timestamp + timezone) * 1000,
        isUtc: true);

    var formatter = DateFormat('MM/dd');
    return formatter.format(datetime); // DateからString
  }

  String getHMMString({int? timestamp, int timezone = 0}) {
    if (timestamp == null) return '';
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
        (timestamp + timezone) * 1000,
        isUtc: true);
    return DateFormat('H:mm').format(datetime);
  }
}
