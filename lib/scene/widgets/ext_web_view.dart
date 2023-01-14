import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ses_novajoj/foundation/log_util.dart';

class ExtWebView extends StatefulWidget {
  final dynamic detailItem;
  final bool isWebDetail;
  final bool imageZoomingEnabled;

  const ExtWebView(
      {Key? key,
      required this.detailItem,
      this.isWebDetail = false,
      this.imageZoomingEnabled = true})
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
  //double _progress = 0;
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
                      if (node == "IMG") {
                        log.info('double tap in dart!');
                        _displayImageDialog(context, src: ingSrc);
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

  Future<void> _saveNetworkImage({String? src}) async {
    final urlStr = src ?? '';
    if (urlStr.isEmpty) {
      return;
    }
    // download tempFile
    final response = await http.get(Uri.parse(urlStr));
    final tempDic = Directory.systemTemp.path;
    final tempUrl = File(urlStr);
    final filename = basename(tempUrl.path).contains('.')
        ? basename(tempUrl.path)
        : '001.jpg';
    final filePathName = '$tempDic/images/$filename';
    await Directory('$tempDic/images').create(recursive: true);
    File tempFile = File(filePathName); //
    await tempFile.writeAsBytes(response.bodyBytes);

    // Add to Gallery/Cameraroll
    await ImageGallerySaver.saveFile(tempFile.path);
    log.info('Image is saved!');
    tempFile.delete();
  }

  void _displayImageDialog(BuildContext context, {String? src}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(5),
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Icon(Icons.close_outlined)),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            _saveNetworkImage(src: src)
                                .then((value) => Navigator.of(context).pop());
                          },
                          child: const Icon(Icons.save_alt_sharp)),
                    ],
                  ),
                  Expanded(
                      child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(src ?? ''),
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
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
