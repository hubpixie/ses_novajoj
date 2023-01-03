import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/root/detail_page.dart';
import 'package:ses_novajoj/scene/weekly_report/weekly_report_presenter.dart';
import 'package:ses_novajoj/scene/weekly_report/weekly_report_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/forecast_summary_cell.dart';
import 'package:ses_novajoj/scene/widgets/hourly_forecast_cell.dart';
import 'package:ses_novajoj/scene/widgets/weekly_forecast_cell.dart';

class ReportDetailItem {
  NovaItemInfo itemInfo;
  String htmlText;
  List<DetailMenuItem>? menuItems;
  List<void Function()?>? menuActions;
  dynamic afterAction;

  ReportDetailItem(
      {required this.itemInfo,
      required this.htmlText,
      this.menuItems,
      this.menuActions,
      this.afterAction});
}

class WeeklyReportPage extends StatefulWidget {
  final WeeklyReportPresenter presenter;
  const WeeklyReportPage({Key? key, required this.presenter}) : super(key: key);
  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  bool _pageLoadIsFirst = true;
  late TemperatureUnit _temprtUnit;

  late String _appBarTitle;
  late DetailPage _detailPage;
  Map? _parameters;
  NovaItemInfo? _itemInfo;
  ReportDetailItem? _detailItem;

  @override
  void initState() {
    super.initState();
    _detailPage = DetailPage();

    _temprtUnit = TemperatureUnit.celsius;
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: ColorDef.appBarBackColor2,
        foregroundColor: ColorDef.appBarTitleColor,
        centerTitle: true,
        actions: _detailPage.buildAppBarActionArea(context,
            itemInfo: _itemInfo,
            menuItems: _detailItem?.menuItems ?? [],
            menuActions: _detailItem?.menuActions,
            afterAction: _detailItem?.afterAction),
      ),
      body: BlocProvider<WeeklyReportPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<WeeklyReportPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowWeeklyReportPageModel) {
                if (data.error == null) {
                  return _buildBody(context, data.viewModel);
                } else {
                  return Text("${data.error}");
                }
              } else {
                assert(false, "unknown event $data");
                return Container(color: Colors.red);
              }
            }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeeklyReportViewModel? viewModel) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Container(
            color: ColorDef.mainBackColor.withAlpha(60),
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: ForecastSummaryCell(
              itemValue: viewModel?.data,
              temprtUnit: _temprtUnit,
              onCellEditing: (_, temprtUnit) {
                if (temprtUnit != _temprtUnit) {
                  setState(() {
                    _temprtUnit = temprtUnit;
                  });
                }
              },
            ),
          ),
          Container(
            color: ColorDef.mainBackColor.withAlpha(90),
            margin: const EdgeInsets.only(top: 150),
            height: 140,
            width: MediaQuery.of(context).size.width,
            child: HourlyForecastCell(
              hourlyForecastValue: viewModel?.hourlyForecastData,
              temprtUnit: _temprtUnit,
            ),
          ),
          Container(
            color: ColorDef.mainBackColor.withAlpha(120),
            margin: const EdgeInsets.only(top: 290),
            height: MediaQuery.of(context).size.height - 290,
            width: MediaQuery.of(context).size.width,
            child: WeeklyForecastCell(
              weeklyForecastValue: viewModel?.weeklyForecastData,
              temprtUnit: _temprtUnit,
            ),
          ),
        ],
      ),
    );
  }

  void _parseRouteParameter() {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      //
      // get page paratmers via ModalRoute
      //
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      _appBarTitle =
          _parameters?[WeeklyReportParamKeys.appBarTitle] as String? ?? '';
      _itemInfo = _parameters?[WeeklyReportParamKeys.itemInfo] as NovaItemInfo?;

      //
      // WebPageDetailItem
      //
      if (_itemInfo != null) {
        _detailItem = ReportDetailItem(
            itemInfo: _itemInfo!,
            htmlText: '',
            menuItems: _parameters?[WeeklyReportParamKeys.menuItems],
            menuActions: _parameters?[WeeklyReportParamKeys.menuActions],
            afterAction: ({dynamic itemInfo}) {
              if (itemInfo == null) {
                return;
              }
              _itemInfo = itemInfo;
              _loadData(itemInfo: itemInfo);
            });
      }

      //
      // FA
      //
      // if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
      //     ScreenRouteName.tabs.name) {
      //   // send viewEvent
      //   FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsDetail);
      // }

      // fetch data
      _loadData(itemInfo: _itemInfo);
    }
  }

  void _loadData({dynamic itemInfo}) {
    if (itemInfo != null) {
      widget.presenter.eventViewReady(
          input: WeeklyReportPresenterInput(
              cityInfo: itemInfo?.weatherInfo?.city ?? CityInfo()));
    } else {
      log.warning('weekly_report_page: parameter is error!');
    }
  }
}
