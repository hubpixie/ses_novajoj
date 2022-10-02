import 'package:ses_novajoj/domain/entities/weekly_report_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchWeeklyReportRepoInput {
  CityInfo cityInfo;

  FetchWeeklyReportRepoInput({required this.cityInfo});
}

abstract class WeeklyReportRepository {
  Future<Result<WeeklyReportItem>> fetchWeeklyReport(
      {required FetchWeeklyReportRepoInput input});
}
