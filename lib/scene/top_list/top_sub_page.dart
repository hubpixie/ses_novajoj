import 'dart:async';
import 'package:flutter/material.dart';
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
  int _currentPageIndex = 1;
  String _prevSearchedKeyword = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    widget.reloadedController.stream.listen((event) {
      if (event.isReload) {
        _loadData(searchedKeyword: event.searchedKey);
      }
    });
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                return ListView.builder(
                    controller: _scrollController,
                    itemCount: lastViewModel.itemInfo.pageCount! > 1
                        ? itemCnt + 1
                        : itemCnt,
                    itemBuilder: (context, index) {
                      if (lastViewModel.itemInfo.pageCount! > 1 &&
                          index == itemCnt) {
                        return NovaListCell(
                          viewModel: lastViewModel,
                          index: index,
                          onPageChanged: (pageIndex) {
                            _currentPageIndex = pageIndex;
                            _loadData();
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
                      return NovaListCell(
                        viewModel: data.viewModelList![index],
                        onCellSelecting: (selIndex) {
                          widget.presenter.eventSelectDetail(context,
                              appBarTitle: widget.appBarTitle,
                              itemInfo: data.viewModelList![selIndex].itemInfo,
                              completeHandler: () {
                            _loadData(isReloaded: true);
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
    // fetch data
    widget.presenter.eventViewReady(
        targetUrlIndex: widget.tabIndex,
        searchedKeyword: searchedKeyword,
        searchResultIsCleared: searchResultIsCleared,
        pageIndex: _currentPageIndex,
        prefixTitle: widget.prefixTitle,
        isReloaded: isReloaded);

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }
}
