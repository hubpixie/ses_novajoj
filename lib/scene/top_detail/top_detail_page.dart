import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/utilities/log_util.dart';
import 'package:ses_novajoj/domain/utilities/bloc/bloc_provider.dart';
import 'package:ses_novajoj/utilities/firebase_util.dart';
import 'package:ses_novajoj/utilities/data/user_types.dart';
import 'package:ses_novajoj/scene/utilities/page_util/page_parameter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:ses_novajoj/scene/top_detail/top_detail_presenter.dart';
import 'package:ses_novajoj/scene/top_detail/top_detail_presenter_output.dart';

class TopDetailPage extends StatefulWidget {
  final TopDetailPresenter presenter;
  const TopDetailPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _TopDetailPageState createState() => _TopDetailPageState();
}

class _TopDetailPageState extends State<TopDetailPage> {
  late Map? _parameters;
  late String _appBarTitle;
  late NovaItemInfo? _itemInfo;
  bool _buildIsFirst = true;

  @override
  void initState() {
    super.initState();
    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topDetail);
    _buildIsFirst = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_buildIsFirst) {
      _buildIsFirst = false;
      _getParameters();
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
              if (data is ShowNovaDetailModel) {
                return Column(
                  children: [
                    _buildContentArea(context, detailItem: data.viewModel)
                  ],
                );
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

  void _getParameters() {
    _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
    _appBarTitle =
        _parameters?[TopDetailParamKeys.appBarTitle] as String? ?? '';
    _itemInfo = _parameters?[TopDetailParamKeys.itemInfo] as NovaItemInfo?;

    if (_itemInfo != null) {
      widget.presenter.eventViewReady(_itemInfo!);
    } else {
      log.warning('top_detail_page: parameter is error!');
    }
  }
}
