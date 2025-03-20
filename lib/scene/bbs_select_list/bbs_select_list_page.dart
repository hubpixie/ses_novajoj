import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/bbs_select_list/bbs_select_list_presenter.dart';
import 'package:ses_novajoj/scene/bbs_select_list/bbs_select_list_presenter_output.dart';
import 'package:ses_novajoj/scene/root/search_page.dart';

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

  int _limitPerBlock = 25;
  //late BuildContext _keyContext;
  late GlobalKey _latestListKey;
  late Map<int, List<int>> _usedPageBlock;
  int _currentItemIndex = 0;
  int _totalItemCount = 1;
  int _dispTotalItemCount = 1;
  int _foryouItemCount = 0;
  // int _maxBlockCount = 0;
  int _currentBlockIndex = 0;
  int _currentPageIndex = 1;
  int _waitingCount = 0;
  bool _hasNextBlock = true;

  late String? _searchedUrl;
  final SearchPage _searchPage = SearchPage();
  String _currentSearchedKeyword = '';
  String _prevSearchedKeyword = '';

  @override
  void initState() {
    super.initState();
    print("[- initState]:totolItemCount=$_totalItemCount");
    _initProc();
    _latestListKey = GlobalKey();
    // calculate item height of Listview
    double calcItemHeight() {
      double itemHeight = 90;
      RenderObject? render = _latestListKey.currentContext?.findRenderObject();

      if (render is RenderSliverList?) {
        itemHeight = render?.firstChild?.size.height ?? 0;
        print("[- render:1]:totolItemCount=$render, itemHeight=$itemHeight");
      } else if (render is RenderBox?) {
        print(
            "[- render:2]:totolItemCount=$render,render.child=$render, itemHeight=$itemHeight");
        itemHeight = (render as RenderBox?)?.size.height ?? 0;
      }
      return itemHeight;
    }

    int calcItemIndex(double itemHeight) {
      int itemIndex = (_scrollController.position.pixels / itemHeight).floor() +
          _foryouItemCount;
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (itemIndex >= _totalItemCount && _currentItemIndex > 0) {
          itemIndex = _currentItemIndex + 1;
        }
      }
      return itemIndex;
    }

    // listen _scrollController
    _scrollController.addListener(() {
      if (!_hasNextBlock) {
        return;
      }
      if (_scrollController.position.pixels + 160 >=
          _scrollController.position.maxScrollExtent) {
        double itemHeight = calcItemHeight();
        int itemIndex = calcItemIndex(itemHeight);
        _currentBlockIndex = (itemIndex / _limitPerBlock).floor();
        print(
            "[5-0] currentBlockIndex]:totolItemCount= _currentBlockIndex:$_currentBlockIndex, itemIndex:$itemIndex, itemHeight:$itemHeight");
        int blockCount = ((_totalItemCount) / _limitPerBlock).floor() + 1;
        print(
            "[5-1]:totolItemCount=$_totalItemCount,blockCount = $blockCount, _usedPageBlock[_currentBlockIndex]=${_usedPageBlock[_currentBlockIndex]}");
        if (!(_usedPageBlock[_currentPageIndex] ?? []).contains(
                _currentBlockIndex) /*&&
            _currentBlockIndex < blockCount*/
            ) {
          print(
              "[5-2]:totolItemCount=$_totalItemCount,blockCount = $blockCount");
          _usedPageBlock[_currentPageIndex]?.add(_currentBlockIndex);
          _loadData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return Scaffold(
      appBar: _searchPage.buildAppBar(context,
          appBarTitle: Text(_appBarTitle),
          automaticallyImplyLeading: true,
          searchAction: (keyword) {
            _currentSearchedKeyword = keyword;
            if (keyword.isNotEmpty) {
              _loadData(searchedKeyword: keyword);
            }
          },
          cancelAction: (isSearched) {
            if (isSearched) {
              _loadData(searchResultIsCleared: true);
            } else {
              setState(
                () {},
              );
            }
            _currentSearchedKeyword = '';
          },
          openSearchAction: () => setState(
                () {},
              ),
          refreshAction: () {
            _initProc();
            _loadData(
                isReloaded: true, searchedKeyword: _currentSearchedKeyword);
          }),
      body: BlocProvider<BbsSelectListPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<BbsSelectListPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              // _keyContext = context;
              if (snapshot.connectionState == ConnectionState.waiting ||
                  widget.presenter.isProcessing) {
                if (_waitingCount == 0 && _currentSearchedKeyword.isNotEmpty) {
                  _waitingCount++;
                  return Container();
                }
                _waitingCount++;
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowBbsSelectListPageModel) {
                // display listView
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

  void _initProc() {
    print("[- _initProc]:totolItemCount=$_totalItemCount");
    _currentItemIndex = 0;
    _totalItemCount = 1;
    _dispTotalItemCount = 0;
    _foryouItemCount = 0;
    // _maxBlockCount = 0;
    _currentBlockIndex = 0;
    _currentPageIndex = 1;
    _waitingCount = 0;
    _hasNextBlock = true;

    _searchedUrl = "";
    _usedPageBlock = {};
    _usedPageBlock[_currentPageIndex] ??= [0];
  }

  List<Widget> _buildForYouList(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList}) {
    if (_currentSearchedKeyword.isNotEmpty) {
      return [];
    }
    List<BbsSelectListRowViewModel> foryouList =
        dataList.where((element) => element.itemInfo.id < 100).toList();
    _foryouItemCount = foryouList.length;
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
    List<BbsSelectListRowViewModel> latestList = _currentSearchedKeyword.isEmpty
        ? dataList.where((element) => element.itemInfo.id >= 100).toList()
        : dataList;
    if (latestList.isEmpty) {
      return [];
    }
    final itemCnt = latestList.length;
    final lastViewModel = latestList[itemCnt - 1];

    // set member properties
    int _totalItemCount = dataList.last.itemInfo.totolItemClount ?? 1;
    _limitPerBlock =
        _limitPerBlock > _totalItemCount ? _totalItemCount : _limitPerBlock;
    // _maxBlockCount = (_totalItemCount / _limitPerBlock).floor() + 1;
    print("[4]:totolItemCount=$_totalItemCount");
    return [
      SliverList(
          key: _latestListKey,
          delegate: SliverChildBuilderDelegate((context, index) {
            print("[5]:totolItemCount=$_totalItemCount");
            _currentItemIndex = index;
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
                        child: Text(_currentSearchedKeyword.isEmpty
                            ? UseL10n.of(context)?.bbsSelectListLatest ?? ''
                            : UseL10n.of(context)?.searchedResultTitle ?? ''),
                      )
                    ],
                  ),
                ),
                _buildLatestCard(context, dataList: latestList, row: index),
              ]);
            } else {
              int fetchedIndex = lastViewModel.itemInfo.fetchedBlockItemIndex!;
              print(
                  "[=.1.0]:totolItemCount=$itemCnt, ${lastViewModel.itemInfo.pageCount}, $_totalItemCount, _limitPerBlock =$_limitPerBlock, fetchedIndex = $fetchedIndex, fetchedCount=${_currentBlockIndex * _limitPerBlock + fetchedIndex}. index=$index");
              if (!_hasNextBlock) {
                return Container();
              } else if (((_totalItemCount <= _limitPerBlock &&
                          index >= itemCnt) ||
                      ((lastViewModel.itemInfo.pageCount! > 1) &&
                          (index + 1 >= _totalItemCount))) &&
                  _hasNextBlock) {
                print(
                    "[=.1.1]:totolItemCount=$itemCnt, ${lastViewModel.itemInfo.pageCount}, $_totalItemCount, _limitPerBlock =$_limitPerBlock");
                if (_hasNextBlock) {
                  _hasNextBlock = false;
                  return _buildPagingArea(context,
                      itemInfo: lastViewModel.itemInfo);
                }
              } else if (lastViewModel.itemInfo.pageCount! > 1 &&
                  index >= itemCnt) {
                _dispTotalItemCount += itemCnt;
                print(
                    "[=.2]:totolItemCount=$itemCnt, ${lastViewModel.itemInfo.pageCount}, $_totalItemCount, _limitPerBlock =$_limitPerBlock, index=$index");
                return Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.grey,
                            backgroundColor: Colors.grey[350])));
              } else {
                print("[=.3]:totolItemCount=$_totalItemCount, index = $index");
                return _buildLatestCard(context,
                    dataList: latestList, row: index);
              }
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
            _loadData(searchedKeyword: _currentSearchedKeyword);
          });
        });
  }

  Widget _buildLatestCard(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList, required int row}) {
    return Card(
      color: Colors.grey[100],
      child: (dataList[row].itemInfo.children?.isEmpty ?? true)
          ? _buildLatestRowTile(context,
              itemInfo: dataList[row].itemInfo, row: row)
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
                          _loadData(searchedKeyword: _currentSearchedKeyword);
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
                    isSub: true,
                    row: row),
              ],
            ),
    );
  }

  Widget _buildLatestRowTile(BuildContext context,
      {required NovaItemInfo itemInfo, bool isSub = false, int? row}) {
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
            _loadData(searchedKeyword: _currentSearchedKeyword);
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
                      _currentItemIndex = -1;
                      _totalItemCount = 1;
                      _dispTotalItemCount = 0;
                      _currentPageIndex = targetPageIndex;
                      _hasNextBlock = true;
                      _usedPageBlock = {};
                      _usedPageBlock[_currentPageIndex] ??= [0];

                      _loadData(
                          isReloaded: true,
                          searchedKeyword: _currentSearchedKeyword);
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
      _searchedUrl =
          _parameters?[BbsSelectListParamKeys.searchedUrl] as String?;

      //
      // FA
      //
      // send viewEvent
      FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsSelectList);

      // fetch data
      _loadData();
    }
  }

  void _loadData(
      {bool isReloaded = false,
      String searchedKeyword = '',
      bool searchResultIsCleared = false}) {
    if (_prevSearchedKeyword != searchedKeyword) {
      _prevSearchedKeyword = searchedKeyword;
      _currentPageIndex = 1;
    }
    _waitingCount = 0;
    _currentBlockIndex = isReloaded ? 0 : _currentBlockIndex;

    if (_targetUrl != null) {
      widget.presenter.eventViewReady(
          input: BbsSelectListPresenterInput(
              targetUrl: searchedKeyword.isEmpty ? _targetUrl! : _searchedUrl!,
              targetPageIndex: _currentPageIndex,
              blockIndex: _currentBlockIndex + 1,
              limitPerBlock: _limitPerBlock,
              searchedKeyword: searchedKeyword,
              searchResultIsCleared: searchResultIsCleared,
              isReloaded: isReloaded,
              completeHandler: () {
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    if (isReloaded) {
                      _scrollController.jumpTo(0);
                    }
                  });
                });
              }));
    } else {
      log.warning('bbs_select_list_page: parameter is error!');
    }
  }
}
