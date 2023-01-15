import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_presenter.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/nova_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class ThreadSubPage extends StatefulWidget {
  final ThreadListPresenter presenter;
  final int tabIndex;
  final String appBarTitle;

  const ThreadSubPage(
      {Key? key,
      required this.presenter,
      required this.tabIndex,
      this.appBarTitle = ""})
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
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ThreadListPresenter>(
      bloc: widget.presenter,
      child: StreamBuilder<ThreadListPresenterOutput>(
          stream: widget.presenter.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowThreadListPageModel) {
              int itemCnt = data.viewModelList?.length ?? 0;
              if (data.error == null && itemCnt > 0) {
                final lastViewModel = data.viewModelList![itemCnt - 1];
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
