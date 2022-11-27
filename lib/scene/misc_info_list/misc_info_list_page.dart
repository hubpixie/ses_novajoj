import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/data/weather_util.dart';
import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_presenter.dart';
import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_presenter_output.dart';
import 'package:ses_novajoj/scene/misc_info_list/weather_info_overlay.dart';
import 'package:ses_novajoj/scene/widgets/info_service_cell.dart';
import 'package:ses_novajoj/scene/widgets/historio_cell.dart';

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
                          viewModelList: data.reshapedViewModelList),
                      _buildHistoryArea(context,
                          viewModelList: data.reshapedViewModelList)
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
    List<String> rowTitleStrings = [
      UseL10n.of(context)?.infoServiceMyTimeWork ?? '',
      UseL10n.of(context)?.infoServiceMyTimeRest ?? '',
      UseL10n.of(context)?.infoServiceMyTimeHoliday ?? '',
      UseL10n.of(context)?.infoServiceMyTimeCalendar ?? ''
    ];
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceMyTime ?? '',
      rowTitles: rowTitleStrings.map((elem) => _buildTextWidget(elem)).toList(),
      onRowSelecting: (index) {
        widget.presenter.eventViewWebPage(context,
            input: MiscInfoListPresenterInput(
                appBarTitle: rowTitleStrings[index],
                viewModelList: viewModelList,
                serviceType: ServiceType.time,
                itemIndex: index,
                completeHandler: () {
                  widget.presenter
                      .eventViewReady(input: MiscInfoListPresenterInput());
                }));
      },
      onOtherRowSelecting: (index) {},
    );
  }

  Widget _buildOnlineLiveArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    final rowTitles = viewModelList
        ?.where((element) => element.itemInfo.serviceType == ServiceType.audio)
        .map((element) => _buildTextWidget(element.itemInfo.title))
        .toList();
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceOnline ?? '',
      rowTitles: rowTitles ?? [],
      otherTitle: _buildTextWidget(UseL10n.of(context)?.infoServiceItemOther),
      onRowSelecting: (index) {
        widget.presenter.eventViewWebPage(context,
            input: MiscInfoListPresenterInput(
                appBarTitle: UseL10n.of(context)?.infoServiceOnline ?? '',
                viewModelList: viewModelList,
                serviceType: ServiceType.audio,
                itemIndex: index,
                completeHandler: () {
                  widget.presenter
                      .eventViewReady(input: MiscInfoListPresenterInput());
                }));
      },
      onOtherRowSelecting: (index) {
        widget.presenter.eventViewWebPage(context,
            input: MiscInfoListPresenterInput(
                appBarTitle: UseL10n.of(context)?.infoServiceOnline ?? '',
                viewModelList: viewModelList,
                serviceType: ServiceType.audio,
                itemIndex: -1,
                completeHandler: () {
                  widget.presenter
                      .eventViewReady(input: MiscInfoListPresenterInput());
                }));
      },
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
      rowTitles: _buildRowWeatherWidgets(weatherInfos),
      otherTitle: _buildTextWidget(UseL10n.of(context)?.infoServiceItemOther),
      onRowSelecting: (index) {
        widget.presenter.eventViewReportPage(context,
            input: MiscInfoListPresenterInput(
                appBarTitle: UseL10n.of(context)?.infoServiceWeather ?? '',
                viewModelList: viewModelList,
                serviceType: ServiceType.weather,
                itemIndex: index,
                completeHandler: () {
                  widget.presenter
                      .eventViewReady(input: MiscInfoListPresenterInput());
                }));
      },
      onRowStartSelecting: (index, tapDownDetails) =>
          _tapDownDetails = tapDownDetails,
      onRowLongPress: (index) {
        _showModeless(context,
            viewModelList: viewModelList,
            index: index,
            itemValue: weatherInfos?[index]);
      },
      onOtherRowSelecting: (index) {
        widget.presenter.eventViewWebPage(context,
            input: MiscInfoListPresenterInput(
                appBarTitle: UseL10n.of(context)?.infoServiceWeather ?? '',
                viewModelList: viewModelList,
                serviceType: ServiceType.weather,
                itemIndex: -1,
                completeHandler: () {
                  widget.presenter
                      .eventViewReady(input: MiscInfoListPresenterInput());
                }));
      },
    );
  }

  Widget _buildFavoriteArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    double screenWidth = MediaQuery.of(context).size.width;
    final bookmarks = viewModelList
        ?.where((element) =>
            element.itemInfo.serviceType == ServiceType.none &&
            element.bookmark != null)
        .toList();
    if ((bookmarks ?? []).isEmpty) {
      return const SizedBox(height: 0);
    }
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceFavorites ?? '',
      rowTitles: _buildRowFavoritesWidgets(bookmarks?.take(5).toList()),
      otherTitle: (bookmarks?.length ?? 0) > 5
          ? _buildTextWidget(UseL10n.of(context)?.infoServiceItemMore)
          : null,
      calcRowHeight: (index) {
        double itemTitleHeight = _calculateItemTitleHeight(
            context, bookmarks?[index].itemInfo.title ?? '',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            textWidth: (screenWidth <= 320 ? 100 : screenWidth - 165));
        double retHeight =
            (bookmarks![index].createdAtText.isNotEmpty ? 45 : 25) +
                itemTitleHeight;
        return retHeight;
      },
      onOtherRowSelecting: (index) {
        widget.presenter.eventViewFavoritesPage(context,
            input: MiscInfoListPresenterInput(
                appBarTitle: UseL10n.of(context)?.infoServiceFavorites ?? '',
                viewModelList: bookmarks,
                serviceType: ServiceType.none,
                itemIndex: -1,
                completeHandler: () {
                  widget.presenter
                      .eventViewReady(input: MiscInfoListPresenterInput());
                }));
      },
    );
  }

  Widget _buildHistoryArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    double screenWidth = MediaQuery.of(context).size.width;
    final hisInfos = viewModelList
        ?.where((element) =>
            element.itemInfo.serviceType == ServiceType.none &&
            element.hisInfo != null)
        .toList();
    if ((hisInfos ?? []).isEmpty) {
      return const SizedBox(height: 0);
    }
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceHistory ?? '',
      rowTitles: _buildRowHistorioWidgets(hisInfos?.take(5).toList()),
      otherTitle: (hisInfos?.length ?? 0) > 5
          ? _buildTextWidget(UseL10n.of(context)?.infoServiceItemMore)
          : null,
      calcRowHeight: (index) {
        double itemTitleHeight = _calculateItemTitleHeight(
            context, hisInfos?[index].itemInfo.title ?? '',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            textWidth: (screenWidth <= 320 ? 100 : screenWidth - 165));
        double retHeight =
            (hisInfos![index].createdAtText.isNotEmpty ? 45 : 25) +
                itemTitleHeight;
        return retHeight;
      },
      onOtherRowSelecting: (index) {
        widget.presenter.eventViewHistorioPage(context,
            input: MiscInfoListPresenterInput(
                appBarTitle: UseL10n.of(context)?.infoServiceHistory ?? '',
                viewModelList: hisInfos,
                serviceType: ServiceType.none,
                itemIndex: -1,
                completeHandler: () {
                  widget.presenter
                      .eventViewReady(input: MiscInfoListPresenterInput());
                }));
      },
    );
  }

  Widget _buildTextWidget(String? str) {
    return Text(
      str ?? '',
      style: const TextStyle(color: Color(0xFF8D918D)),
    );
  }

  List<Widget> _buildRowWeatherWidgets(List<WeatherInfo?>? infos) {
    return infos
            ?.map((info) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      info?.city?.nameDesc ?? '',
                      style: const TextStyle(color: Color(0xFF8D918D)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${info?.temperature?.celsius.round()}°',
                      style: const TextStyle(color: Color(0xFF8D918D)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.only(bottom: 4),
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

  List<Widget> _buildRowFavoritesWidgets(List<MiscInfoListViewModel>? infos) {
    List<Widget> widgets = [];
    infos?.asMap().forEach((idx, value) {
      widgets.add(Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          HistorioCell(
              viewModel: value,
              index: idx,
              onCellSelecting: (index) {
                widget.presenter.eventViewFavoritesWebPage(context,
                    input: MiscInfoListPresenterInput(
                        appBarTitle:
                            UseL10n.of(context)?.infoServiceFavorites ?? '',
                        viewModelList: infos,
                        serviceType: ServiceType.none,
                        itemIndex: index,
                        completeHandler: () {
                          widget.presenter.eventViewReady(
                              input: MiscInfoListPresenterInput());
                        }));
              },
              onThumbnailShowing: (thumbIndex) async {
                return infos[idx].itemInfo.thunnailUrlString;
              })
        ],
      )));
    });
    return widgets;
  }

  List<Widget> _buildRowHistorioWidgets(List<MiscInfoListViewModel>? infos) {
    List<Widget> widgets = [];
    infos?.asMap().forEach((idx, value) {
      widgets.add(Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          HistorioCell(
              viewModel: value,
              index: idx,
              onCellSelecting: (index) {
                widget.presenter.eventViewHistorioWebPage(context,
                    input: MiscInfoListPresenterInput(
                        appBarTitle:
                            UseL10n.of(context)?.infoServiceHistory ?? '',
                        viewModelList: infos,
                        serviceType: ServiceType.none,
                        itemIndex: index,
                        completeHandler: () {
                          widget.presenter.eventViewReady(
                              input: MiscInfoListPresenterInput());
                        }));
              },
              onThumbnailShowing: (thumbIndex) async {
                return infos[idx].itemInfo.thunnailUrlString;
              })
        ],
      )));
    });
    return widgets;
  }

  double _calculateItemTitleHeight(BuildContext context, String text,
      {required double fontSize,
      required FontWeight fontWeight,
      required double textWidth,
      double minTextHeight = 21.0}) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final style = TextStyle(fontSize: fontSize, fontWeight: fontWeight);
    textPainter.text = TextSpan(text: text, style: style);
    textPainter.layout();
    final lines = (textPainter.size.width / textWidth).ceil();
    final height = lines * textPainter.size.height;
    return height <= minTextHeight ? minTextHeight : height;
  }

  ///
  /// Overlay
  ///
  OverlayEntry? _modeless;

  void _showModeless(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList,
      int? index,
      WeatherInfo? itemValue}) {
    final double screenHeight = MediaQuery.of(context).size.height;

    _modeless?.remove();
    _modeless = null;
    _modeless = OverlayEntry(
        opaque: false,
        builder: (context_) {
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
                onPresentWeeklyForecast: () {
                  _modeless?.remove();
                  _modeless = null;
                  widget.presenter.eventViewReportPage(context,
                      input: MiscInfoListPresenterInput(
                          appBarTitle:
                              UseL10n.of(context)?.infoServiceWeather ?? '',
                          viewModelList: viewModelList,
                          serviceType: ServiceType.weather,
                          itemIndex: index ?? 0,
                          completeHandler: () {
                            widget.presenter.eventViewReady(
                                input: MiscInfoListPresenterInput());
                          }));
                },
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
