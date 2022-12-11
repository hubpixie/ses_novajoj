import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/root/detail_page.dart';
import 'package:ses_novajoj/scene/top_detail/top_detail_presenter.dart';
import 'package:ses_novajoj/scene/top_detail/top_detail_presenter_output.dart';

import 'package:ses_novajoj/scene/widgets/error_view.dart';

class TopDetailPage extends StatefulWidget {
  final TopDetailPresenter presenter;
  const TopDetailPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<TopDetailPage> createState() => _TopDetailPageState();
}

class _TopDetailPageState extends State<TopDetailPage> {
  bool _pageLoadIsFirst = true;

  late String _appBarTitle;
  late DetailPage _detailPage;
  Map? _parameters;
  NovaItemInfo? _itemInfo;
  String? _htmlText;

  @override
  void initState() {
    super.initState();
    _detailPage = DetailPage();
    _htmlText = '';
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: const Color(0xFF1B80F3),
        centerTitle: true,
        actions: _detailPage
            .buildAppBarActionArea(context, itemInfo: _itemInfo, menuItems: [
          DetailMenuItem.openOriginal,
          DetailMenuItem.favorite
        ], menuActions: [
          null,
          () {
            if (_htmlText == null || _htmlText!.isEmpty) {
              return;
            }
            widget.presenter.eventSaveBookmark(
                input: TopDetailPresenterInput(
                    itemInfo: _itemInfo!, htmlText: _htmlText!));
          }
        ]),
      ),
      body: BlocProvider<TopDetailPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<TopDetailPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (widget.presenter.isProcessing) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowNovaDetailPageModel) {
                if (data.error == null) {
                  _htmlText = data.viewModel?.htmlText;
                  _itemInfo = data.viewModel?.itemInfo;
                  return Column(
                    children: [
                      _detailPage.buildContentArea(context,
                          detailItem: data.viewModel)
                    ],
                  );
                } else {
                  return ErrorView(
                    message: UseL10n.localizedTextWithError(context,
                        error: data.error),
                    onFirstButtonTap: data.error?.type == AppErrorType.network
                        ? () {
                            _loadData();
                            setState(() {});
                          }
                        : null,
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

  void _parseRouteParameter() {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      //
      // get page paratmers via ModalRoute
      //
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      _appBarTitle =
          _parameters?[TopDetailParamKeys.appBarTitle] as String? ?? '';
      _itemInfo = _parameters?[TopDetailParamKeys.itemInfo] as NovaItemInfo?;

      //
      // FA
      //
      if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
          ScreenRouteName.tabs.name) {
        // send viewEvent
        FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topDetail);
      } else if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
          ScreenRouteName.threadList.name) {
        // send viewEvent
        FirebaseUtil().sendViewEvent(route: AnalyticsRoute.threadDetail);
      }

      // fetch data
      _loadData();
    }
  }

  void _loadData() {
    if (_itemInfo != null) {
      widget.presenter
          .eventViewReady(input: TopDetailPresenterInput(itemInfo: _itemInfo!));
    } else {
      log.warning('top_detail_page: parameter is error!');
    }
  }
}
