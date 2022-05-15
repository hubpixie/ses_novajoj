import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ExtWebView extends StatefulWidget {
  final dynamic detailItem;

  const ExtWebView({Key? key, required this.detailItem}) : super(key: key);
  @override
  _ExtWebViewState createState() => _ExtWebViewState();
}

class _ExtWebViewState extends State<ExtWebView> {
  final GlobalKey _webViewKey = GlobalKey();
  final InAppWebViewGroupOptions _webViewGroupOptions =
      InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
          ));
  //final _urlController = TextEditingController();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Wrap(
        children: <Widget>[
          Container(
              alignment: Alignment.topLeft,
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  InAppWebView(
                    key: _webViewKey,
                    initialUrlRequest:
                        URLRequest(url: Uri.parse("about:blank")),
                    initialOptions: _webViewGroupOptions,
                    onWebViewCreated: (controller) {
                      if ((widget.detailItem?.htmlText ?? '')
                          .contains('home_login.php')) {
                        controller.loadUrl(
                            urlRequest: URLRequest(
                                url: Uri.parse(
                                    widget.detailItem?.itemInfo.urlString ??
                                        '')));
                      } else {
                        controller.loadData(
                            data: widget.detailItem?.htmlText ?? '',
                            mimeType: 'text/html',
                            encoding: 'utf8');
                      }
                    },
                    onLoadStart: (controller, url) {
                      // setState(() {
                      //   this.url = url.toString();
                      //   urlController.text = this.url;
                      // });
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      if (![
                        "http",
                        "https",
                        "file",
                        "chrome",
                        "data",
                        "javascript",
                        "about"
                      ].contains(uri.scheme)) {
                        return NavigationActionPolicy.CANCEL;
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {},
                    onLoadError: (controller, url, code, message) {
                      //pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        //pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        _progress = _progress / 100;
                        // urlController.text = this.url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        // this.url = url.toString();
                        // urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      //log.info(consoleMessage);
                    },
                  ),
                  _progress < 1.0
                      ? LinearProgressIndicator(value: _progress)
                      : Container(),
                ],
              )),
          const SizedBox(height: 5),
          const Divider(height: 1.0, thickness: 1.0),
        ],
      ),
    );
  }
}
