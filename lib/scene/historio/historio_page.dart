import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/historio/historio_presenter.dart';
import 'package:ses_novajoj/scene/historio/historio_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/historio_cell.dart';

class HistorioPage extends StatefulWidget {
  final HistorioPresenter presenter;
  const HistorioPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<HistorioPage> createState() => _HistorioPageState();
}

class _HistorioPageState extends State<HistorioPage> {
  bool _pageLoadIsFirst = true;

  late String _appBarTitle;
  Map? _parameters;
  Future<String>? Function(NovaItemInfo?, String?, String?)? _innerDetailAction;
  //NovaItemInfo? _itemInfo;

  @override
  void initState() {
    super.initState();
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
      ),
      body: FutureBuilder<HistorioPresenterOutput>(
          future: widget.presenter
              .eventViewReady(input: HistorioPresenterInput(appBarTitle: '')),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowHistorioPageModel &&
                data.reshapedViewModelList != null) {
              final viewModels = data.reshapedViewModelList;
              return ListView.builder(
                  itemCount: viewModels?.length,
                  itemBuilder: (context, index) => HistorioCell(
                      viewModel: viewModels![index],
                      onCellSelecting: (selIndex) {
                        viewModels[selIndex].hisInfo.itemInfo.innerLinkDetail =
                            (innerLink) async {
                          return await _innerDetailAction?.call(
                                  viewModels[selIndex].hisInfo.itemInfo,
                                  innerLink,
                                  viewModels[selIndex].hisInfo.category) ??
                              '';
                        };
                        widget.presenter.eventViewWebPage(context,
                            input: HistorioPresenterInput(
                                appBarTitle: _appBarTitle,
                                viewModel: viewModels[selIndex],
                                completeHandler: () {
                                  setState(() {});
                                }));
                      },
                      onThumbnailShowing: (thumbIndex) async {
                        return viewModels[thumbIndex]
                            .hisInfo
                            .itemInfo
                            .thunnailUrlString;
                      },
                      index: index,
                      divider: const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.black12,
                          indent: 2,
                          endIndent: 2),
                      indent: 0,
                      endIndent: 0));
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
    if (_parameters?[HistorioParamKeys.innerDetailAction] is Future<String>?
        Function(NovaItemInfo?, String?, String?)?) {
      _innerDetailAction = _parameters?[HistorioParamKeys.innerDetailAction];
    }
    // _itemInfo = _parameters?[HistorioParamKeys.itemInfos] as NovaItemInfo?;

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
