import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/nova_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class TopSearchKeyItem {
  bool isReload;
  bool searchResultIsCleared;
  String searchedKey;
  TopSearchKeyItem(
      {this.isReload = true,
      this.searchResultIsCleared = false,
      this.searchedKey = ''});
}

class TopSubPage extends StatefulWidget {
  final TopListPresenter presenter;
  final int tabIndex;
  final String prefixTitle;
  final String appBarTitle;
  final StreamController<TopSearchKeyItem> reloadedController;

  const TopSubPage(
      {Key? key,
      required this.presenter,
      required this.tabIndex,
      this.prefixTitle = "",
      this.appBarTitle = "",
      required this.reloadedController})
      : super(key: key);

  @override
  State<TopSubPage> createState() => _TopSubPageState();
}

class _TopSubPageState extends State<TopSubPage>
    with AutomaticKeepAliveClientMixin<TopSubPage> {
  final ScrollController _scrollController = ScrollController();
  final int _limitPerBlock = 25;
  late StreamController<bool> _blockLoadCompleteController;
  String _prevSearchedKeyword = '';
  late BuildContext _keyContext;
  late Map<int, List<int>> _usedPageBlock;
  int _totalItemCount = 1;
  int _maxBlockCount = 0;
  int _currentBlockIndex = 0;
  int _currentPageIndex = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    bool? prevLoadingFlag;
    bool reloadingFlag = false;
    _blockLoadCompleteController = StreamController<bool>.broadcast()
      ..stream.listen((event) {
        if (reloadingFlag) {
          prevLoadingFlag = null;
        }
        if (prevLoadingFlag != null &&
            event != prevLoadingFlag &&
            _scrollController.position.pixels + 65 <
                _scrollController.position.maxScrollExtent) {
          // double offset = _scrollController.offset + 65;
          // _scrollController.jumpTo(offset);
        }
        prevLoadingFlag = event;
      });

    _usedPageBlock = {};
    _usedPageBlock[_currentPageIndex] ??= [0];

    widget.reloadedController.stream.listen((event) {
      reloadingFlag = event.isReload;
      if (event.isReload) {
        _usedPageBlock[_currentPageIndex] = [0];
        _loadData(isReloaded: true, searchedKeyword: event.searchedKey);
      }
    });

    // calculate item height of Listview
    double calcItemHeight() {
      double itemHeight = 0;
      RenderObject? render = _keyContext.findRenderObject();
      if (render is RenderSliverList?) {
        itemHeight = render?.firstChild?.size.height ?? 0;
      } else if (render is RenderBox?) {
        itemHeight = (render as RenderBox?)?.size.height ?? 0;
      }
      return itemHeight;
    }

    // listen _scrollController
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + 100 >=
          _scrollController.position.maxScrollExtent) {
        double itemHeight = calcItemHeight();
        int itemIndex =
            (_scrollController.position.pixels / itemHeight).floor();
        _currentBlockIndex = (itemIndex / _limitPerBlock).floor() + 1;
        int blockCount = (_totalItemCount / _limitPerBlock).floor() + 1;
        if (!(_usedPageBlock[_currentPageIndex] ?? [])
                .contains(_currentBlockIndex) &&
            _currentBlockIndex < blockCount) {
          _loadData();
          _usedPageBlock[_currentPageIndex]?.add(_currentBlockIndex);
        }
      }
    });

    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _blockLoadCompleteController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _keyContext = context;
    super.build(context);
    return BlocProvider<TopListPresenter>(
      bloc: widget.presenter,
      child: StreamBuilder<TopListPresenterOutput>(
          stream: widget.presenter.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowListPageModel) {
              int itemCnt = data.viewModelList?.length ?? 0;
              if (data.error == null && itemCnt > 0) {
                final lastViewModel = data.viewModelList![itemCnt - 1];
                _totalItemCount =
                    data.viewModelList!.first.itemInfo.totolItemClount ?? 1;
                _maxBlockCount = (_totalItemCount / _limitPerBlock).floor() + 1;
                return ListView.builder(
                    controller: _scrollController,
                    itemCount: lastViewModel.itemInfo.pageCount! > 1 &&
                            _currentBlockIndex + 1 >= _maxBlockCount
                        ? itemCnt + 1
                        : itemCnt,
                    itemBuilder: (context, index) {
                      _keyContext = context;
                      if (lastViewModel.itemInfo.pageCount! > 1 &&
                          index == itemCnt) {
                        return NovaListCell(
                          viewModel: lastViewModel,
                          index: index,
                          onPageChanged: (pageIndex) {
                            _usedPageBlock[pageIndex] ??= [0];
                            _currentPageIndex = pageIndex;
                            _loadData(
                                isReloaded: true,
                                searchedKeyword: _prevSearchedKeyword);
                          },
                          pageEnd: true,
                          onScrollToTop: () {
                            _scrollController.animateTo(
                              _scrollController.position.minScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                        );
                      }
                      bool loadingFlag =
                          data.viewModelList![index].showsIndicatorOnNextBlock;
                      _blockLoadCompleteController.sink.add(!loadingFlag);
                      // show list item
                      return NovaListCell(
                        viewModel: data.viewModelList![index],
                        onCellSelecting: (selIndex) {
                          widget.presenter.eventSelectDetail(context,
                              appBarTitle: widget.appBarTitle,
                              itemInfo: data.viewModelList![selIndex].itemInfo,
                              completeHandler: () {
                            _usedPageBlock[_currentPageIndex] = [0];
                            _loadData(
                                isReloaded: true,
                                searchedKeyword: _prevSearchedKeyword);
                          });
                        },
                        onThumbnailShowing: (thumbIndex) async {
                          if (data.viewModelList![thumbIndex].itemInfo
                              .thunnailUrlString.isNotEmpty) {
                            return data.viewModelList![thumbIndex].itemInfo
                                .thunnailUrlString;
                          }
                          final retUrl = await widget.presenter
                              .eventFetchThumbnail(
                                  targetUrl: data.viewModelList![thumbIndex]
                                      .itemInfo.urlString);
                          data.viewModelList![thumbIndex].itemInfo
                              .thunnailUrlString = retUrl;
                          return retUrl;
                        },
                        index: index,
                      );
                    });
              } else {
                if (widget.presenter.isProcessing) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: Colors.amber,
                          backgroundColor: Colors.grey[850]));
                } else {
                  return ErrorView(
                    message: UseL10n.localizedTextWithError(context,
                        error: data.error),
                    onFirstButtonTap: data.error?.type == AppErrorType.network
                        ? () {
                            _loadData();
                          }
                        : null,
                  );
                }
              }
            } else {
              assert(false, "unknown event $data");
              return Container(color: Colors.red);
            }
          }),
    );
  }

  void _loadData(
      {bool isReloaded = false,
      String searchedKeyword = '',
      bool searchResultIsCleared = false}) {
    if (_prevSearchedKeyword != searchedKeyword) {
      _prevSearchedKeyword = searchedKeyword;
      _currentPageIndex = 1;
    }
    _currentBlockIndex = isReloaded ? 0 : _currentBlockIndex;
    // fetch data
    widget.presenter.eventViewReady(
        targetUrlIndex: widget.tabIndex,
        searchedKeyword: searchedKeyword,
        searchResultIsCleared: searchResultIsCleared,
        pageIndex: _currentPageIndex,
        blockIndex: _currentBlockIndex + 1,
        limitPerBlock: _limitPerBlock,
        prefixTitle: widget.prefixTitle,
        isReloaded: isReloaded,
        completeHandler: () {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              if (isReloaded) {
                _scrollController.jumpTo(0);
              }
            });
          });
        });
  }
}
