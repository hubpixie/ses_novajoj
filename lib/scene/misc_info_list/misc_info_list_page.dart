import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/data/weather_util.dart';
import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_presenter.dart';
import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_presenter_output.dart';
import 'package:ses_novajoj/scene/misc_info_list/weather_info_overlay.dart';
import 'package:ses_novajoj/scene/widgets/info_service_cell.dart';

class MiscInfoListPage extends StatefulWidget {
  final MiscInfoListPresenter presenter;
  const MiscInfoListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _MiscInfoListPageState createState() => _MiscInfoListPageState();
}

class _MiscInfoListPageState extends State<MiscInfoListPage> {
  TapDownDetails? _tapDownDetails;

  @override
  void initState() {
    super.initState();
    widget.presenter.eventViewReady(input: MiscInfoListPresenterInput());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UseL10n.of(context)?.infoServiceTop ?? ''),
        backgroundColor: const Color(0xFF1B80F3),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: BlocProvider<MiscInfoListPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<MiscInfoListPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowMiscInfoListPageModel) {
                if (data.error == null) {
                  return SingleChildScrollView(
                      child: Column(
                    children: [
                      _buildMyTimeArea(context,
                          viewModelList: data.viewModelList),
                      _buildOnlineLiveArea(context,
                          viewModelList: data.viewModelList),
                      _buildWeatherArea(context,
                          viewModelList: data.viewModelList),
                      _buildFavoriteArea(context,
                          viewModelList: data.viewModelList),
                      _buildHistoryArea(context,
                          viewModelList: data.viewModelList)
                    ],
                  ));
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

  Widget _buildMyTimeArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceMyTime ?? '',
      rowTitles: <Widget>[
        _toTextWidget(UseL10n.of(context)?.infoServiceMyTimeWork),
        _toTextWidget(UseL10n.of(context)?.infoServiceMyTimeRest),
        _toTextWidget(UseL10n.of(context)?.infoServiceMyTimeHoliday),
        _toTextWidget(UseL10n.of(context)?.infoServiceMyTimeCalendar),
      ],
      onRowSelecting: (index) {
        final itemInfo = viewModelList
            ?.firstWhere((element) =>
                element.itemInfo.serviceType == ServiceType.time &&
                element.itemInfo.orderIndex == index)
            .itemInfo;
        widget.presenter.eventViewWebPage(context,
            appBarTitle: itemInfo?.title ?? '',
            itemInfo: itemInfo,
            completeHandler: () {});
      },
      onOtherRowSelecting: (index) {},
    );
  }

  Widget _buildOnlineLiveArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceOnline ?? '',
      rowTitles: <Widget>[
        _toTextWidget(UseL10n.of(context)?.infoServiceOnlineHotRadio),
        _toTextWidget(UseL10n.of(context)?.infoServiceOnlineAfn),
      ],
      otherTitle: _toTextWidget(UseL10n.of(context)?.infoServiceItemOther),
      onRowSelecting: (index) {
        final itemInfo = viewModelList
            ?.firstWhere((element) =>
                element.itemInfo.serviceType == ServiceType.audio &&
                element.itemInfo.orderIndex == index)
            .itemInfo;
        widget.presenter.eventViewWebPage(context,
            appBarTitle: itemInfo?.title ?? '',
            itemInfo: itemInfo,
            completeHandler: () {});
      },
      onOtherRowSelecting: (index) {},
    );
  }

  Widget _buildWeatherArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    final weatherInfos = viewModelList
        ?.where(
            (element) => element.itemInfo.serviceType == ServiceType.weather)
        .map((element) => element.itemInfo.weatherInfo)
        .toList();

    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceWeather ?? '',
      rowTitles: _toRowWeatherWidgets(weatherInfos),
      otherTitle: _toTextWidget(UseL10n.of(context)?.infoServiceItemOther),
      onRowSelecting: (index) {
        final itemInfo = viewModelList
            ?.firstWhere((element) =>
                element.itemInfo.serviceType == ServiceType.weather &&
                element.itemInfo.orderIndex == index)
            .itemInfo;
        widget.presenter.eventViewWebPage(context,
            appBarTitle: itemInfo?.title ?? '',
            itemInfo: itemInfo,
            completeHandler: () {});
      },
      onRowStartSelecting: (index, tapDownDetails) =>
          _tapDownDetails = tapDownDetails,
      onRowLongPress: (index) {
        _showModeless(context, itemValue: weatherInfos?[index]);
      },
      onOtherRowSelecting: (index) {},
    );
  }

  Widget _buildFavoriteArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceFavorites ?? '',
      rowTitles: const <Widget>[],
      otherTitle: _toTextWidget(UseL10n.of(context)?.infoServiceItemOther),
      onRowSelecting: (index) {
        final itemInfo = viewModelList
            ?.firstWhere((element) =>
                element.itemInfo.serviceType == ServiceType.favorite &&
                element.itemInfo.orderIndex == index)
            .itemInfo;
        widget.presenter.eventViewWebPage(context,
            appBarTitle: itemInfo?.title ?? '',
            itemInfo: itemInfo,
            completeHandler: () {});
      },
      onOtherRowSelecting: (index) {},
    );
  }

  Widget _buildHistoryArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceHistory ?? '',
      rowTitles: const <Widget>[],
      otherTitle: _toTextWidget(UseL10n.of(context)?.infoServiceItemOther),
      onRowSelecting: (index) {
        final itemInfo = viewModelList
            ?.firstWhere((element) =>
                element.itemInfo.serviceType == ServiceType.favorite &&
                element.itemInfo.orderIndex == index)
            .itemInfo;
        widget.presenter.eventViewWebPage(context,
            appBarTitle: itemInfo?.title ?? '',
            itemInfo: itemInfo,
            completeHandler: () {});
      },
      onOtherRowSelecting: (index) {},
    );
  }

  Widget _toTextWidget(String? str) {
    return Text(
      str ?? '',
      style: const TextStyle(color: Color(0xFF8D918D)),
    );
  }

  List<Widget> _toRowWeatherWidgets(List<WeatherInfo?>? infos) {
    return infos
            ?.map((info) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      info?.city?.name ?? '',
                      style: const TextStyle(color: Color(0xFF8D918D)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${info?.temperature?.celsius.round()}°',
                      style: const TextStyle(color: Color(0xFF8D918D)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Icon(
                          WeatherUtil().getIconData(info?.iconCode),
                          color: Colors.black45,
                          size: 15,
                        ))
                  ],
                ))
            .toList() ??
        [];
  }

  ///
  /// Overlay
  ///
  OverlayEntry? _modeless;

  void _showModeless(BuildContext context, {WeatherInfo? itemValue}) {
    final double screenHeight = MediaQuery.of(context).size.height;

    _modeless?.remove();
    _modeless = null;
    _modeless = OverlayEntry(
        opaque: false,
        builder: (context) {
          return Positioned(
            top: _tapDownDetails != null
                ? _tapDownDetails!.globalPosition.dy - 170
                : screenHeight - 350,
            left: 10.0,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0))),
              child: WeatherInfoOverlay(
                itemValue: itemValue,
              ),
            ),
          );
        });
    Overlay.of(context)?.insert(_modeless!);
    Future.delayed(const Duration(seconds: 8), () {
      _modeless?.remove();
      _modeless = null;
    });
  }
}
