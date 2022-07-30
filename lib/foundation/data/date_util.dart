import 'package:intl/intl.dart';

class DateUtil {
  static final DateUtil _instance = DateUtil._internal();
  factory DateUtil() {
    return _instance;
  }
  DateUtil._internal();

  String getDateMdeString({DateTime? date}) {
    String locale = Intl.defaultLocale ?? Intl.systemLocale;

    DateTime datetime = date ?? DateTime.now();
    final weekDayStrInfo = _getWeekDaytStrInfo(datetime: datetime);

    final formatter = DateFormat('M/d (E)', locale);
    String retStr = formatter.format(datetime);
    return retStr.replaceAll(weekDayStrInfo.first, weekDayStrInfo.last);
  }

  String getDateString({DateTime? date, format = 'M/d (E) H:mm:ss'}) {
    String locale = Intl.defaultLocale ?? Intl.systemLocale;

    DateTime datetime = date ?? DateTime.now();
    final weekDayStrInfo = _getWeekDaytStrInfo(datetime: datetime);

    final formatter = DateFormat(format, locale);
    String retStr = formatter.format(datetime);

    return retStr.replaceAll(weekDayStrInfo.first, weekDayStrInfo.last);
  }

  String getDateMDEStringWithTimestamp({int? timestamp, int timezone = 0}) {
    if (timestamp == null) return '';
    String locale = Intl.defaultLocale ?? Intl.systemLocale;

    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
        (timestamp + timezone) * 1000,
        isUtc: true);
    final weekDayStrInfo = _getWeekDaytStrInfo(datetime: datetime);

    final formatter = DateFormat('M/d (E)', locale);
    String retStr = formatter.format(datetime);
    return retStr.replaceAll(weekDayStrInfo.first, weekDayStrInfo.last);
  }

  String getDateMMDDStringWithTimestamp({int? timestamp, int timezone = 0}) {
    if (timestamp == null) return '';
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
        (timestamp + timezone) * 1000,
        isUtc: true);

    final formatter = DateFormat('MM/dd');
    return formatter.format(datetime); // DateからString
  }

  String getHMMString({int? timestamp, int timezone = 0}) {
    if (timestamp == null) return '';
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
        (timestamp + timezone) * 1000,
        isUtc: true);
    return DateFormat('H:mm').format(datetime);
  }

  List<String> _getWeekDaytStrInfo({required DateTime datetime}) {
    String locale = Intl.defaultLocale ?? Intl.systemLocale;
    final weekday = datetime.weekday % 7;
    final dateSymbols = DateFormat.E(locale).dateSymbols;
    final weekDayFullStr = dateSymbols.STANDALONESHORTWEEKDAYS[weekday];
    final weekDayShortStr = dateSymbols.STANDALONENARROWWEEKDAYS[weekday];

    return [weekDayFullStr, weekDayShortStr];
  }
}

extension DateUtilFromString on DateUtil {
  DateTime? fromString(String dateString,
      {String format = "MM/dd/yy", String? locale}) {
    final formatter = DateFormat(format, locale ?? Intl.defaultLocale);
    try {
      return formatter.parse(dateString); // Convert dateString into date
    } catch (ex) {
      return null;
    }
  }
}
