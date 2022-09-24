import 'weekly_report_page.dart';
import 'weekly_report_presenter.dart';
import 'weekly_report_router.dart';

class WeeklyReportPageBuilder {
  final WeeklyReportPage page;

  WeeklyReportPageBuilder._(this.page);

  factory WeeklyReportPageBuilder() {
    final router = WeeklyReportRouterImpl();
    final presenter = WeeklyReportPresenterImpl(router: router);
    final page = WeeklyReportPage(presenter: presenter);

    return WeeklyReportPageBuilder._(page);
  }
}
