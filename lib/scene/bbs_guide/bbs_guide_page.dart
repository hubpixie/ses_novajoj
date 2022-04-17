import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/bbs_guide/bbs_guide_presenter.dart';
import 'package:ses_novajoj/scene/bbs_guide/bbs_guide_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/simple_nova_item_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class BbsGuidePageState {
  int subPageIndex;
  BbsGuidePageState({required this.subPageIndex});
}

class BbsGuidePage extends StatefulWidget {
  final BbsGuidePresenter presenter;
  final BbsGuidePageState pageState;
  const BbsGuidePage(
      {Key? key, required this.presenter, required this.pageState})
      : super(key: key);

  @override
  _BbsGuidePageState createState() => _BbsGuidePageState();
}

class _BbsGuidePageState extends State<BbsGuidePage>
    with AutomaticKeepAliveClientMixin<BbsGuidePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.presenter.eventViewReady(
        input:
            BbsGuidePresenterInput(itemIndex: widget.pageState.subPageIndex));
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
                            // widget.presenter.eventSelectDetail(context,
                            //     appBarTitle: _selectedAppBarTitle,
                            //     itemInfo: data.viewModelList![selIndex]
                            //         .itemInfo, completeHandler: () {
                            //   _loadData(isReloaded: true);
                            // });
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
}
