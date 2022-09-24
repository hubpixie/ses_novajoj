import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
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

  ReportDetailItem(
      {required this.itemInfo,
      required this.htmlText,
      this.menuItems,
      this.menuActions});
}

class WeeklyReportPage extends StatefulWidget {
  final WeeklyReportPresenter presenter;
  const WeeklyReportPage({Key? key, required this.presenter}) : super(key: key);
  @override
  _WeeklyReportPageState createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  // FIXME: testDataViewModel
  WeeklyReportViewModel? _testDataViewModel;

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
    // TODO: Initialize your variables.
    widget.presenter.eventViewReady(input: WeeklyReportPresenterInput());
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: ColorDef.appBarBackColor,
        centerTitle: true,
        actions: _detailPage.buildAppBarActionArea(context,
            itemInfo: _itemInfo,
            menuItems: _detailItem?.menuItems ?? [],
            menuActions: _detailItem?.menuActions),
      ),
      body: BlocProvider<WeeklyReportPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<WeeklyReportPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              /*
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowWeeklyReportPageModel) {
                if (data.error == null) {
                  return Column(
                    children: [Text("${data.viewModel}")],
                  );
                } else {
                  return Text("${data.error}");
                }
              } else {
                assert(false, "unknown event $data");
                return Container(color: Colors.red);
              }*/
              return _buildBody(context, _testDataViewModel);
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
              onCellEditing: (cityChanged, temprtUnit) {
                /*if (cityChanged) {
                  Navigator.pushNamed(
                      context, ScreenRouteName.selectCity.name ?? '',
                      arguments: {'city': _cityItem}).then((value) async {
                    CityInfo? cityValue2 = value as CityInfo?;
                    if (cityValue2 != null) {
                      await _savePrefsData(cityValue: cityValue2);
                      BaseView.of(context).reload();
                    }
                  });
                } else if (temprtUnit != null) {
                  _savePrefsData(temprtUnit: temprtUnit);
                }*/
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

  Widget _buildMessageArea(
      {required BuildContext context,
      String message = '',
      bool needsReload = false}) {
    return SafeArea(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 20),
        Container(
            alignment: Alignment.center,
            child: Text(
              message,
            )),
        SizedBox(height: needsReload ? 10 : 1),
        needsReload
            ? SizedBox(
                height: 20.0,
                child: TextButton(
                    child: const Text(
                      '再表示',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    onPressed: () {
                      setState(() {
                        // 再表示する
                        //BaseView.of(context).reload();
                      });
                    }))
            : const SizedBox(height: 1),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          height: 20.0,
          child: TextButton(
              child: const Text(
                '地域変更',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                /*Navigator.pushNamed(
                    context, ScreenRouteName.selectCity.name ?? '', arguments: {
                  'city': CityInfo(name: 'Tokyo', countryCode: 'JP')
                }).then((value) async {
                  CityInfo? cityValue = value as CityInfo?;
                  if (cityValue != null) {
                    //_savePrefsData(cityValue: cityValue);
                  }
                });*/
              }),
        ),
      ],
    ));
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
            menuActions: _parameters?[WeeklyReportParamKeys.menuActions]);
      }

      // FIME: Dummy Code
      _testDataViewModel = WeeklyReportViewModel(null);
      _testDataViewModel?.data = _itemInfo?.weatherInfo;

      //
      // FA
      //
      // if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
      //     ScreenRouteName.tabs.name) {
      //   // send viewEvent
      //   FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsDetail);
      // }

      // fetch data
      _loadData();
    }
  }

  void _loadData() {
    if (_itemInfo != null) {
      // widget.presenter
      //     .eventViewReady(input: WeeklyReportPresenterInput(itemInfo: _itemInfo!));
    } else {
      log.warning('thread_detail_page: parameter is error!');
    }
  }
}
