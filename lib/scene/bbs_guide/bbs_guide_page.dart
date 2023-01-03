import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/bbs_guide/bbs_guide_presenter.dart';
import 'package:ses_novajoj/scene/bbs_guide/bbs_guide_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/simple_nova_item_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

enum BbsGuideDestination { detail, selectList }

class BbsGuidePageState {
  int subPageIndex;
  String subPageTitle;
  BbsGuideDestination nextPageDestination;

  BbsGuidePageState(
      {required this.subPageIndex,
      required this.subPageTitle,
      this.nextPageDestination = BbsGuideDestination.detail});
}

class BbsGuidePage extends StatefulWidget {
  final BbsGuidePresenter presenter;
  final BbsGuidePageState pageState;
  const BbsGuidePage(
      {Key? key, required this.presenter, required this.pageState})
      : super(key: key);

  @override
  State<BbsGuidePage> createState() => _BbsGuidePageState();
}

class _BbsGuidePageState extends State<BbsGuidePage>
    with AutomaticKeepAliveClientMixin<BbsGuidePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData(isReloaded: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider<BbsGuidePresenter>(
      bloc: widget.presenter,
      child: SafeArea(
        child: StreamBuilder<BbsGuidePresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowBbsGuidePageModel) {
                if (data.error == null) {
                  return ListView.builder(
                      itemCount: data.viewModelList?.length,
                      itemBuilder: (context, index) => SimpleNovaListCell(
                          viewModel: data.viewModelList![index],
                          onCellSelecting: (selIndex) {
                            if (widget.pageState.nextPageDestination ==
                                BbsGuideDestination.detail) {
                              widget.presenter.eventSelectDetail(context,
                                  appBarTitle:
                                      "${widget.pageState.subPageTitle}[${data.viewModelList![selIndex].itemInfo.source}]",
                                  itemInfo: data.viewModelList![selIndex]
                                      .itemInfo, completeHandler: () {
                                _loadData(isReloaded: true);
                              });
                            } else if (widget.pageState.nextPageDestination ==
                                BbsGuideDestination.selectList) {
                              widget.presenter.eventSelectList(context,
                                  appBarTitle:
                                      "${widget.pageState.subPageTitle}[${data.viewModelList![selIndex].itemInfo.source}]",
                                  targetUrl: data.viewModelList![selIndex]
                                      .itemInfo.urlString, completeHandler: () {
                                _loadData(isReloaded: true);
                              });
                            }
                          },
                          onThumbnailShowing: (thumbIndex) async {
                            if (data.viewModelList![thumbIndex].itemInfo
                                .thunnailUrlString.isNotEmpty) {
                              return data.viewModelList![thumbIndex].itemInfo
                                  .thunnailUrlString;
                            }
                            final retUrl = await widget.presenter
                                .eventFetchThumbnail(
                                    input: BbsGuidePresenterInput(
                                        itemIndex: thumbIndex,
                                        itemUrl: data.viewModelList![thumbIndex]
                                            .itemInfo.urlString));
                            data.viewModelList![thumbIndex].itemInfo
                                .thunnailUrlString = retUrl;
                            return retUrl;
                          },
                          index: index));
                } else {
                  return ErrorView(
                    message: UseL10n.localizedTextWithError(context,
                        error: data.error),
                    onFirstButtonTap:
                        data.error?.type == AppErrorType.network ? () {} : null,
                  );
                }
              } else {
                assert(false, "unknown event $data");
                return Container(color: Colors.red);
              }
            }),
      ),
    );
  }

  void _loadData({required bool isReloaded}) {
    widget.presenter.eventViewReady(
        input:
            BbsGuidePresenterInput(itemIndex: widget.pageState.subPageIndex));
  }
}
