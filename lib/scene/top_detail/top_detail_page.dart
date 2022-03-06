import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/top_detail/top_detail_presenter.dart';
import 'package:ses_novajoj/scene/top_detail/top_detail_presenter_output.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class TopDetailPage extends StatefulWidget {
  final TopDetailPresenter presenter;
  const TopDetailPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _TopDetailPageState createState() => _TopDetailPageState();
}

class _TopDetailPageState extends State<TopDetailPage> {
  bool _pageLoadIsFirst = true;

  late Map? _parameters;
  late String _appBarTitle;
  late NovaItemInfo? _itemInfo;

  @override
  void initState() {
    super.initState();
    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topDetail);
  }

  @override
  Widget build(BuildContext context) {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      // get page paratmers via ModalRoute
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      _appBarTitle =
          _parameters?[TopDetailParamKeys.appBarTitle] as String? ?? '';
      _itemInfo = _parameters?[TopDetailParamKeys.itemInfo] as NovaItemInfo?;

      // fetch data
      _loadData();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: const Color(0xFF1B80F3),
        centerTitle: true,
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
                  return Column(
                    children: [
                      _buildContentArea(context, detailItem: data.viewModel)
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

  Widget _buildContentArea(BuildContext context,
      {NovaDetailViewModel? detailItem}) {
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
              )),
          const SizedBox(height: 5),
          const Divider(height: 1.0, thickness: 1.0),
        ],
      ),
    );
  }

  void _loadData() {
    if (_itemInfo != null) {
      widget.presenter.eventViewReady(_itemInfo!);
    } else {
      log.warning('top_detail_page: parameter is error!');
    }
  }
}
