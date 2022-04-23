import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/bbs_detail/bbs_detail_presenter.dart';
import 'package:ses_novajoj/scene/bbs_detail/bbs_detail_presenter_output.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class BbsDetailPage extends StatefulWidget {
  final BbsDetailPresenter presenter;
  const BbsDetailPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _BbsDetailPageState createState() => _BbsDetailPageState();
}

class _BbsDetailPageState extends State<BbsDetailPage> {
  bool _pageLoadIsFirst = true;
  late Map? _parameters;
  late String _appBarTitle;
  late NovaItemInfo? _itemInfo;

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
        backgroundColor: const Color(0xFF1B80F3),
        centerTitle: true,
      ),
      body: BlocProvider<BbsDetailPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<BbsDetailPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowBbsDetailPageModel) {
                if (data.error == null) {
                  return Column(children: [
                    _buildContentArea(context, detailItem: data.viewModel)
                  ]);
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

  Widget _buildContentArea(BuildContext context,
      {BbsDetailViewModel? detailItem}) {
    return Flexible(
      child: Wrap(
        children: <Widget>[
          Container(
              alignment: Alignment.topLeft,
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController controller) {
                  //_controller = controller;
                  controller.loadUrl(Uri.dataFromString(
                          detailItem?.htmlText ?? '',
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                      .toString());
                },
                gestureNavigationEnabled: true,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => LongPressGestureRecognizer(),
                  ),
                },
              )),
          const SizedBox(height: 5),
          const Divider(height: 1.0, thickness: 1.0),
        ],
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
          _parameters?[BbsDetailParamKeys.appBarTitle] as String? ?? '';
      _itemInfo = _parameters?[BbsDetailParamKeys.itemInfo] as NovaItemInfo?;

      //
      // FA
      //
      if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
          ScreenRouteName.tabs.name) {
        // send viewEvent
        FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsDetail);
      }

      // fetch data
      _loadData();
    }
  }

  void _loadData() {
    if (_itemInfo != null) {
      widget.presenter
          .eventViewReady(input: BbsDetailPresenterInput(itemInfo: _itemInfo!));
    } else {
      log.warning('thread_detail_page: parameter is error!');
    }
  }
}
