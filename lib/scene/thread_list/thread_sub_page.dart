import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_presenter.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/nova_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class ThreadSubInfo {
  int index;
  List<String> infos;
  ThreadSubInfo({required this.index, required this.infos});
}

class ThreadSubPage extends StatefulWidget {
  final ThreadListPresenter presenter;
  final int tabIndex;
  final String appBarTitle;
  final StreamController<ThreadSubInfo>? pickedInfoList;

  const ThreadSubPage(
      {Key? key,
      required this.presenter,
      required this.tabIndex,
      this.appBarTitle = "",
      this.pickedInfoList})
      : super(key: key);

  @override
  State<ThreadSubPage> createState() => _ThreadSubPageState();
}

class _ThreadSubPageState extends State<ThreadSubPage>
    with AutomaticKeepAliveClientMixin<ThreadSubPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPageIndex = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ThreadListPresenter>(
      bloc: widget.presenter,
      child: StreamBuilder<ThreadListPresenterOutput>(
          stream: widget.presenter.stream,
          builder: (context, snapshot) {
            String firstText = "🟠${widget.appBarTitle}";
            if (!snapshot.hasData) {
              // return appBarTitle into infoList
              widget.pickedInfoList?.add(
                  ThreadSubInfo(index: widget.tabIndex, infos: [firstText]));

              // return empty container
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowThreadListPageModel) {
              int itemCnt = data.viewModelList?.length ?? 0;
              if (data.error == null && itemCnt > 0) {
                final lastViewModel = data.viewModelList![itemCnt - 1];
                // return appBarTitle into infoList
                List<String> infos = data.viewModelList
                        ?.take(50)
                        .map((elem) => "  |🔵${elem.itemInfo.title}")
                        .toList() ??
                    [widget.appBarTitle];
                infos.insert(0, firstText);

                // Future.delayed(const Duration(milliseconds: 3800), () {
                print(
                    "subPage pickedInfoList.index=${widget.tabIndex}, infos=${infos.first}");
                widget.pickedInfoList
                    ?.add(ThreadSubInfo(index: widget.tabIndex, infos: infos));
                // });

                // return a listView
                return ListView.builder(
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
                                itemInfo: data.viewModelList![selIndex]
                                    .itemInfo, completeHandler: () {
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
                                    input: ThreadListPresenterInput(
                                        itemIndex: thumbIndex,
                                        itemUrl: data.viewModelList![thumbIndex]
                                            .itemInfo.urlString));
                            data.viewModelList![thumbIndex].itemInfo
                                .thunnailUrlString = retUrl;
                            return retUrl;
                          },
                          index: index);
                    });
              } else {
                // return appBarTitle into infoList
                widget.pickedInfoList?.add(
                    ThreadSubInfo(index: widget.tabIndex, infos: [firstText]));

                // return an error container
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
              // return appBarTitle into infoList
              widget.pickedInfoList?.add(
                  ThreadSubInfo(index: widget.tabIndex, infos: [firstText]));

              // return an error container
              assert(false, "unknown event $data");
              return Container(color: Colors.red);
            }
          }),
    );
  }

  void _loadData({bool isReloaded = false}) {
    // fetch data
    widget.presenter.eventViewReady(
        input: ThreadListPresenterInput(
            itemIndex: widget.tabIndex,
            pageIndex: _currentPageIndex,
            isReloaded: isReloaded));

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }
}
