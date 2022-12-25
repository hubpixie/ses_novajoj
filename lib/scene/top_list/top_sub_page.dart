import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/nova_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class TopSubPage extends StatefulWidget {
  final TopListPresenter presenter;
  final int tabIndex;
  final String prefixTitle;
  final String appBarTitle;

  const TopSubPage(
      {Key? key,
      required this.presenter,
      required this.tabIndex,
      this.prefixTitle = "",
      this.appBarTitle = ""})
      : super(key: key);

  @override
  State<TopSubPage> createState() => _TopSubPageState();
}

class _TopSubPageState extends State<TopSubPage>
    with AutomaticKeepAliveClientMixin<TopSubPage> {
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
              if (data.error == null) {
                return ListView.builder(
                    itemCount: data.viewModelList?.length,
                    itemBuilder: (context, index) => NovaListCell(
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
                        index: index));
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
        targetUrlIndex: widget.tabIndex,
        prefixTitle: widget.prefixTitle,
        isReloaded: isReloaded);

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }
}
