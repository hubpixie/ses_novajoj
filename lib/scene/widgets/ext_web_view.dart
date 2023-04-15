import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ses_novajoj/foundation/log_util.dart';

typedef ImageLoadingDelegate = void Function(int, List<dynamic>);

class PageScrollController {}

class ExtWebView extends StatefulWidget {
  final dynamic detailItem;
  final bool isWebDetail;
  final bool imageZoomingEnabled;
  final ImageLoadingDelegate? onImageLoad;
  final PageScrollController? scrollController;

  const ExtWebView(
      {Key? key,
      required this.detailItem,
      this.isWebDetail = false,
      this.imageZoomingEnabled = true,
      this.onImageLoad,
      this.scrollController})
      : super(key: key);

  static openBrowser(BuildContext context, {String? url}) {
    ChromeSafariBrowser browser = _ChromeSafariBrowser(context);
    browser.open(
        url: Uri.parse(url ?? ''),
        options: ChromeSafariBrowserClassOptions(
            android: AndroidChromeCustomTabsOptions(
                showTitle: false,
                enableUrlBarHiding: true,
                shareState: CustomTabsShareState.SHARE_STATE_OFF,
                isSingleInstance: false,
                isTrustedWebActivity: false,
                keepAliveEnabled: true),
            ios: IOSSafariOptions(
                dismissButtonStyle: IOSSafariDismissButtonStyle.CLOSE,
                presentationStyle:
                    IOSUIModalPresentationStyle.OVER_FULL_SCREEN)));
  }

  @override
  State<ExtWebView> createState() => _ExtWebViewState();
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
  late StreamController<double> _progressController;

  @override
  void initState() {
    _progressController = StreamController<double>.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    _progressController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String htmlText = widget.detailItem?.htmlText ?? '';
    Widget bodyWidget = Container(
        alignment: Alignment.topLeft,
        height: MediaQuery.of(context).size.height - 100,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            InAppWebView(
              key: _webViewKey,
              //initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
              initialData: htmlText.isNotEmpty
                  ? InAppWebViewInitialData(
                      data: htmlText,
                    )
                  : null,
              initialOptions: _webViewGroupOptions,
              onWebViewCreated: (controller) {
                if (htmlText.isEmpty) {
                  controller.loadUrl(
                      urlRequest: URLRequest(
                          url: Uri.parse(
                              widget.detailItem?.itemInfo?.urlString ?? '')));
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
              shouldOverrideUrlLoading: (controller, navigationAction) async {
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
              onLoadStop: (controller, url) async {
                if (widget.imageZoomingEnabled) {
                  if (!Platform.isAndroid ||
                      await AndroidWebViewFeature.isFeatureSupported(
                          AndroidWebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)) {
                    // wait until the page is loaded, and then create the Web Message Channel
                    var webMessageChannel =
                        await controller.createWebMessageChannel();
                    var port1 = webMessageChannel!.port1;
                    var port2 = webMessageChannel.port2;

                    // set the web message callback for the port1
                    await port1.setWebMessageCallback((message) async {
                      Map<String, dynamic> jsonData =
                          json.decode(message?.trim() ?? '');
                      String node = jsonData['node'] as String? ?? '';
                      String ingSrc = jsonData['src'] as String? ?? '';
                      int index = jsonData['index'] as int? ?? 0;
                      final imageUrls =
                          jsonData['imageUrls'] as List? ?? [ingSrc];

                      if (node == "IMG" && imageUrls.isNotEmpty) {
                        log.info('double tap in dart!');
                        widget.onImageLoad?.call(index, imageUrls);
                      }
                    });

                    // transfer port2 to the webpage to initialize the communication
                    await controller.postWebMessage(
                        message:
                            WebMessage(data: "capturePort", ports: [port2]),
                        targetOrigin: Uri.parse("*"));
                  }
                }
              },
              onLoadError: (controller, url, code, message) {
                //pullToRefreshController.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  //pullToRefreshController.endRefreshing();
                }
                _progressController.stream.drain();
                _progressController.add(progress / 100);
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {
                // setState(() {
                // });
              },
              onConsoleMessage: (controller, consoleMessage) {
                //log.info(consoleMessage);
              },
            ),
            StreamBuilder(
                stream: _progressController.stream,
                builder: (context, snapshot) {
                  double progess = snapshot.data is double
                      ? (snapshot.data as double? ?? 0)
                      : 0;
                  return progess < 1.0
                      ? LinearProgressIndicator(
                          value: progess, backgroundColor: Colors.lightBlue)
                      : Container();
                })
          ],
        ));
    return widget.isWebDetail
        ? Wrap(children: [bodyWidget])
        : Expanded(child: bodyWidget);
  }
}

class _ChromeSafariBrowser extends ChromeSafariBrowser {
  final BuildContext context;

  _ChromeSafariBrowser(this.context);
  @override
  void onOpened() {
    log.info("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    log.info("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    log.info("ChromeSafari browser closed");
    //Navigator.of(context).pop();
  }
}
