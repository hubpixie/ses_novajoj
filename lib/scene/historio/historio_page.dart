import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/historio/historio_presenter.dart';
import 'package:ses_novajoj/scene/historio/historio_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/historio_cell.dart';

class HistorioPage extends StatefulWidget {
  final HistorioPresenter presenter;
  const HistorioPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _HistorioPageState createState() => _HistorioPageState();
}

class _HistorioPageState extends State<HistorioPage> {
  bool _pageLoadIsFirst = true;

  late String _appBarTitle;
  Map? _parameters;
  NovaItemInfo? _itemInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(_appBarTitle),
        backgroundColor: ColorDef.appBarBackColor,
        centerTitle: true,
      ),
      body: FutureBuilder<HistorioPresenterOutput>(
          future:
              widget.presenter.eventViewReady(input: HistorioPresenterInput()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowHistorioPageModel && data.viewModelList != null) {
              final viewModels = data.viewModelList;
              return ListView.builder(
                  itemCount: viewModels?.length,
                  itemBuilder: (context, index) => HistorioCell(
                      viewModel: viewModels![index],
                      onCellSelecting: (selIndex) {
                        /*widget.presenter.eventSelectDetail(context,
                            appBarTitle: _selectedAppBarTitle,
                            itemInfo: data.viewModelList![selIndex].itemInfo,
                            completeHandler: () {
                        });*/
                      },
                      onThumbnailShowing: (thumbIndex) async {
                        if (viewModels[thumbIndex]
                            .hisInfo
                            .itemInfo
                            .thunnailUrlString
                            .isNotEmpty) {
                          return viewModels[thumbIndex]
                              .hisInfo
                              .itemInfo
                              .thunnailUrlString;
                        }
                        final retUrl =
                            'http://www.google.com/'; /*await widget.presenter
                            .eventFetchThumbnail(
                                targetUrl: data.viewModelList![thumbIndex]
                                    .itemInfo.urlString);*/
                        viewModels[thumbIndex]
                            .hisInfo
                            .itemInfo
                            .thunnailUrlString = retUrl;
                        return retUrl;
                      },
                      index: index));
            } else {
              return const Text('No data!');
            }
          }),
    );
  }

  void _parseRouteParameter() {
    if (!_pageLoadIsFirst) {
      return;
    }
    //
    // get page paratmers via ModalRoute
    //
    _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
    _appBarTitle = _parameters?[HistorioParamKeys.appBarTitle] as String? ?? '';
    _itemInfo = _parameters?[HistorioParamKeys.itemInfo] as NovaItemInfo?;

    //
    // FA
    //
    // if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
    //     ScreenRouteName.tabs.name) {
    //   // send viewEvent
    //   FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsDetail);
    // }

    // fetch data
    //_loadData(itemInfo: _itemInfo);

    // set  _pageLoadIsFirst -> false;
    _pageLoadIsFirst = false;
  }
}
