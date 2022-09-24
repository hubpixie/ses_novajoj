import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/weekly_report_item_response.dart';
// import 'package:ses_novajoj/networking/request/weekly_report_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/weekly_report_item.dart';
import 'package:ses_novajoj/domain/repositories/weekly_report_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class WeeklyReportRepositoryImpl extends WeeklyReportRepository {
  final MyWebApi _api;

  // sigleton
  static final WeeklyReportRepositoryImpl _instance =
      WeeklyReportRepositoryImpl._internal();
  WeeklyReportRepositoryImpl._internal() : _api = MyWebApi();
  factory WeeklyReportRepositoryImpl() => _instance;

  @override
  Future<Result<WeeklyReportItem>> fetchWeeklyReport(

      {required FetchWeeklyReportRepoInput input}) async {
    Result<WeeklyReportItem> result =
        Result.success(data: WeeklyReportItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `WeeklyReport' repository
    return result;
  }
}
