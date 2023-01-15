import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/bbs_select_list/bbs_select_list_presenter.dart';
import 'package:ses_novajoj/scene/bbs_select_list/bbs_select_list_presenter_output.dart';

class BbsSelectListPage extends StatefulWidget {
  final BbsSelectListPresenter presenter;
  const BbsSelectListPage({Key? key, required this.presenter})
      : super(key: key);

  @override
  State<BbsSelectListPage> createState() => _BbsSelectListPageState();
}

class _BbsSelectListPageState extends State<BbsSelectListPage> {
  bool _pageLoadIsFirst = true;
  late Map? _parameters;
  late String _appBarTitle;
  late String? _targetUrl;
  final ScrollController _scrollController = ScrollController();
  int _currentPageIndex = 1;

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
      body: BlocProvider<BbsSelectListPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<BbsSelectListPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowBbsSelectListPageModel) {
                if (data.error == null) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: _buildForYouList(context,
                            dataList: data.viewModelList!) +
                        _buildLatestList(context,
                            dataList: data.viewModelList!),
                  );
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

  List<Widget> _buildForYouList(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList}) {
    List<BbsSelectListRowViewModel> foryouList =
        dataList.where((element) => element.itemInfo.id < 100).toList();
    if (foryouList.isEmpty) {
      return [];
    }
    return [
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Column(children: [
            Container(
              height: 40,
              color: Colors.grey[300],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Text(UseL10n.of(context)?.bbsSelectListForYou ?? ''),
                  )
                ],
              ),
            ),
            _buildForYouRowTile(context, dataList: foryouList, row: index),
          ]);
        } else {
          return _buildForYouRowTile(context, dataList: foryouList, row: index);
        }
      }, childCount: foryouList.length))
    ];
  }

  List<Widget> _buildLatestList(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList}) {
    List<BbsSelectListRowViewModel> latestList =
        dataList.where((element) => element.itemInfo.id >= 100).toList();
    if (latestList.isEmpty) {
      return [];
    }
    final itemCnt = latestList.length;
    final lastViewModel = latestList[itemCnt - 1];

    return [
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Column(children: [
            Container(
              height: 40,
              color: Colors.grey[300],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Text(UseL10n.of(context)?.bbsSelectListLatest ?? ''),
                  )
                ],
              ),
            ),
            _buildLatestCard(context, dataList: latestList, row: index),
          ]);
        } else {
          if (lastViewModel.itemInfo.pageCount! > 1 && index == itemCnt) {
            return _buildPagingArea(context, itemInfo: lastViewModel.itemInfo);
          }
          return _buildLatestCard(context, dataList: latestList, row: index);
        }
      },
              childCount: lastViewModel.itemInfo.pageCount! > 1
                  ? itemCnt + 1
                  : itemCnt))
    ];
  }

  Widget _buildForYouRowTile(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList, required int row}) {
    return ListTile(
        tileColor: Colors.grey[100],
        shape: const ContinuousRectangleBorder(
            side: BorderSide(width: 0.0, color: Colors.grey),
            borderRadius: BorderRadius.zero),
        title: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(dataList[row].itemInfo.title)),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          widget.presenter.eventSelectDetail(context,
              appBarTitle: _appBarTitle,
              itemInfo: dataList[row].itemInfo, completeHandler: () {
            _loadData();
          });
        });
  }

  Widget _buildLatestCard(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList, required int row}) {
    return Card(
      color: Colors.grey[100],
      child: (dataList[row].itemInfo.children?.isEmpty ?? true)
          ? _buildLatestRowTile(context, itemInfo: dataList[row].itemInfo)
          : ExpansionTile(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          alignment: Alignment.centerRight,
                          primary: Colors.black54),
                      child: Text(
                        dataList[row].itemInfo.title,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      onPressed: () {
                        widget.presenter.eventSelectDetail(context,
                            appBarTitle: _appBarTitle,
                            itemInfo: dataList[row].itemInfo,
                            completeHandler: () {
                          _loadData();
                        });
                      },
                    ),
                    Row(children: [
                      const SizedBox(width: 10),
                      Text(
                        dataList[row].itemInfo.source,
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.black45),
                      ),
                      const Spacer(),
                      Text(
                        BbsSelectListRowViewModel.asCreateAtText(
                            dataList[row].itemInfo.createAt),
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.black45),
                      ),
                    ])
                  ]),
              iconColor: Colors.black54,
              textColor: Colors.black45,
              children: <Widget>[
                _buildLatestRowTile(context,
                    itemInfo: dataList[row].itemInfo.children!.first,
                    isSub: true),
              ],
            ),
    );
  }

  Widget _buildLatestRowTile(BuildContext context,
      {required NovaItemInfo itemInfo, bool isSub = false}) {
    return ListTile(
        title: Padding(
          padding: isSub
              ? const EdgeInsets.only(left: 14)
              : const EdgeInsets.only(left: 8),
          child: Text(
            itemInfo.title,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
        subtitle: Row(children: [
          Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                itemInfo.source,
                style: const TextStyle(fontSize: 14.0),
              )),
          const Spacer(),
          Text(
            BbsSelectListRowViewModel.asCreateAtText(itemInfo.createAt),
            style: const TextStyle(fontSize: 14.0),
          ),
        ]),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          widget.presenter.eventSelectDetail(context,
              appBarTitle: _appBarTitle,
              itemInfo: itemInfo, completeHandler: () {
            _loadData();
          });
        });
  }

  Widget _buildPagingArea(BuildContext context,
      {required NovaItemInfo itemInfo}) {
    Widget _makeIconButton(IconData? iconData,
        {required int targetPageIndex, required int pageCnt}) {
      return SizedBox(
          height: 35,
          width: 35,
          child: IconButton(
              iconSize: 35,
              padding: const EdgeInsets.only(left: 5),
              onPressed: (targetPageIndex < 1 || targetPageIndex > pageCnt)
                  ? null
                  : () {
                      _currentPageIndex = targetPageIndex;
                      _loadData(isReloaded: true);
                    },
              icon: Icon(iconData)));
    }

    final pageNum = itemInfo.pageNumber ?? 0;
    final pageCnt = itemInfo.pageCount ?? 0;

    return Card(
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 10),
            _makeIconButton(Icons.first_page,
                targetPageIndex: (pageNum > 1 && pageNum <= pageCnt) ? 1 : -1,
                pageCnt: pageCnt),
            const Spacer(),
            _makeIconButton(Icons.chevron_left,
                targetPageIndex: pageNum - 1, pageCnt: pageCnt),
            const Spacer(flex: 2),
            Text('$pageNum/$pageCnt'),
            const Spacer(flex: 1),
            _makeIconButton(Icons.chevron_right,
                targetPageIndex: pageNum + 1, pageCnt: pageCnt),
            const Spacer(),
            _makeIconButton(Icons.last_page,
                targetPageIndex:
                    (pageNum >= 1 && pageNum < pageCnt) ? pageCnt : -1,
                pageCnt: pageCnt),
            const Spacer(flex: 5),
            SizedBox(
                height: 25,
                width: 25,
                child: IconButton(
                    iconSize: 25,
                    padding: const EdgeInsets.only(left: 5),
                    onPressed: () {
                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    icon: const Icon(Icons.arrow_circle_up))),
            const Spacer(flex: 5)
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
          _parameters?[BbsSelectListParamKeys.appBarTitle] as String? ?? '';
      _targetUrl = _parameters?[BbsSelectListParamKeys.targetUrl] as String?;

      //
      // FA
      //
      // send viewEvent
      FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsSelectList);

      // fetch data
      _loadData();
    }
  }

  void _loadData({bool isReloaded = false}) {
    if (_targetUrl != null) {
      widget.presenter.eventViewReady(
          input: BbsSelectListPresenterInput(
              targetUrl: _targetUrl ?? '', targetPageIndex: _currentPageIndex));

      Future.delayed(Duration.zero, () {
        setState(() {});
      });
    } else {
      log.warning('bbs_select_list_page: parameter is error!');
    }
  }
}
