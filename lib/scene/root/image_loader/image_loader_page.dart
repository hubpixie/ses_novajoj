import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/root/image_loader/image_loader_presenter.dart';

class ImageLoaderPage extends StatefulWidget {
  final ImageLoaderPresenter presenter;
  const ImageLoaderPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<ImageLoaderPage> createState() => _ImageLoaderPageState();
}

class _ImageLoaderPageState extends State<ImageLoaderPage> {
  bool _pageLoadIsFirst = true;
  // late String _appBarTitle;
  late int _imageIndex;
  late List<dynamic> _imageSrcList;
  int _currPageIndex = 0;
  bool _isPageLoading = false;
  Map? _parameters;
  late GlobalKey<ScaffoldState> _scaffoldKey;

  SnackBar? _snackBar;
  late List<PhotoViewController> _photoViewControllers;
  late List<PhotoViewScaleStateController> _scaleStateControllers;
  late Map<String, bool> _imageLoadingStates;
  late PageController _pageController;
  PersistentBottomSheetController<dynamic>? _bottomSheetController;

  late StreamController<String> _imageTitleController;
  late StreamController<bool> _imageLoadedController;
  late StreamController<bool> _imageSharedController;
  late StreamController<_InnnerImageInfo> _imageInfoController;
  late StreamController<bool> _imageSelectedController;
  late List<bool> _imageSelectedStates;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();

    _imageTitleController = StreamController<String>.broadcast();
    _imageLoadedController = StreamController<bool>.broadcast();
    _imageSharedController = StreamController<bool>.broadcast();
    _imageInfoController = StreamController<_InnnerImageInfo>.broadcast();
    _imageSelectedController = StreamController<bool>.broadcast();
    _imageLoadingStates = {};
  }

  @override
  void dispose() {
    _imageTitleController.close();
    _imageLoadedController.close();
    _imageSharedController.close();
    _imageInfoController.close();
    _imageSelectedController.close();
    _imageLoadingStates = {};

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter(context);
    return WillPopScope(
        onWillPop: () {
          // dismiss snackBar if need
          _dismissSnackBar(context);

          return Future.value(true);
        },
        child: Scaffold(
          key: _scaffoldKey,
          body: SafeArea(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDismissButton(context),
                        const Spacer(),
                        _buildImageTitleArea(context),
                        const Spacer(),
                        _buildImageSeletButton(context),
                      ],
                    ),
                    _buildImageContentArea(context),
                    Row(
                      children: [
                        _buildImageShareButton(context),
                        const Spacer(),
                        _buildImageInfoButton(context),
                        const Spacer(),
                        _buildImageSaveButton(context),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildDismissButton(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        width: 90,
        child: TextButton(
          style: TextButton.styleFrom(
              alignment: Alignment.center, primary: Colors.white),
          onPressed: () {
            // dismiss snackBar if need
            _dismissSnackBar(context);
            // dismiss bottomSheet if need
            _bottomSheetController?.close();
            // dismiss imageLoader page
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close_outlined),
        ));
  }

  Widget _buildImageTitleArea(BuildContext context) {
    return StreamBuilder(
        stream: _imageTitleController.stream,
        builder: (context, snapshot) {
          String imageTile = snapshot.data is String
              ? (snapshot.data as String? ?? "1 / 1")
              : _getImageTitle();
          return Container(
              alignment: Alignment.center,
              width: 90,
              child: Text(
                imageTile,
                style: const TextStyle(color: Colors.white),
              ));
        });
  }

  Widget _buildImageSeletButton(BuildContext context) {
    return StreamBuilder(
        stream: _imageSelectedController.stream,
        builder: (context, snapshot) {
          final selected =
              snapshot.data is bool ? (snapshot.data as bool? ?? false) : false;
          return Container(
              width: 90,
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                    alignment: Alignment.center, primary: Colors.white),
                onPressed: () {
                  // upadte imageSlect states
                  _imageSelectedStates[_currPageIndex] = !selected;
                  _imageSelectedController.add(!selected);

                  // update imageShare button state
                  final shared = _imageSelectedStates
                      .firstWhere((elem) => elem == true, orElse: () => false);
                  _imageSharedController.add(shared);
                },
                child: Text(selected ? "unselect" : "select"),
              ));
        });
  }

  Widget _buildImageContentArea(BuildContext context) {
    return Expanded(
        child: GestureDetector(
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(_imageSrcList[index]),
            controller: _photoViewControllers[index],
            scaleStateController: _scaleStateControllers[index],
          );
        },
        allowImplicitScrolling: true,
        itemCount: _imageSrcList.length,
        onPageChanged: (pageIndex) {
          _currPageIndex = pageIndex;
          // dismiss snackBar if need
          _dismissSnackBar(context);

          // imageTitle
          String imageTitle = _getImageTitle();
          int pageIndex_ = pageIndex;
          _imageTitleController.sink.add(imageTitle);

          log.info(
              'currPageIndex -- 2 =$_currPageIndex, name=${_getImageTitle()}, loaded=false?');

          // switch imageSelected state
          _imageSelectedController.add(_imageSelectedStates[_currPageIndex]);

          // show imageInfo sheet if need
          if (_bottomSheetController != null) {
            _sendImageInfo(context);
          }

          // imageLoaded [1]
          if (!_imageLoadingStates.containsKey(imageTitle)) {
            _imageLoadedController.sink.add(false);
            log.info(
                'currPageIndex -- 3 =$_currPageIndex, name=${_getImageFileName()}, loaded=false');
          } else {
            _imageLoadedController.sink.add(_imageLoadingStates[imageTitle]!);
            log.info(
                'currPageIndex -- 4 =$_currPageIndex, name=${_getImageFileName()}, loaded=true');
            return;
          }

          // imageLoaded [2]
          Future.delayed(const Duration(milliseconds: 500), () {
            int delayTime = _isPageLoading ? 1500 : 0;

            Future.delayed(Duration(milliseconds: delayTime), () {
              if (_imageLoadedController.isClosed) {
                return;
              }
              // imageTitle
              String imageTitle = _getImageTitle(pageIndex: pageIndex_);

              if (!_imageLoadingStates.containsKey(imageTitle)) {
                _imageLoadingStates[imageTitle] = true;
                if (_currPageIndex == pageIndex_) {
                  log.info(
                      'currPageIndex -- 5 =$_currPageIndex, name=${_getImageFileName()}, loaded=true');
                  _imageLoadedController.sink.add(true);
                }
              } else {
                log.info(
                    'currPageIndex -- 6 =$_currPageIndex, name=${_getImageFileName()}, loaded=$_imageLoadingStates[imageTitle]');
              }
            });
          });
        },
        pageController: _pageController,
        loadingBuilder:
            (BuildContext context, ImageChunkEvent? loadingProgress) {
          _isPageLoading = true;
          String imageTitle = _getImageTitle();

          double? progress;
          if (loadingProgress == null ||
              (loadingProgress.expectedTotalBytes != null &&
                  loadingProgress.expectedTotalBytes ==
                      loadingProgress.cumulativeBytesLoaded)) {
            // imageLoaded as false if loading is completed
            if (loadingProgress != null) {
              _imageLoadingStates[imageTitle] = true;
              _imageLoadedController.sink.add(true);
            }
            log.info(
                'currPageIndex -- 7 =$_currPageIndex, name=${_getImageFileName()}, loaded=${_imageLoadingStates[imageTitle]}, (loadingProgress == null: ${loadingProgress == null}');
          } else {
            // progress
            progress = loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!;

            if (!_imageLoadingStates.containsKey(imageTitle)) {
              _imageLoadingStates[imageTitle] = false;
              _imageLoadedController.sink.add(false);
            }
          }

          // imageLoaded as false if loading is not completed.
          return Center(
            child: CircularProgressIndicator(
              value: progress,
            ),
          );
        },
      ),
      onVerticalDragEnd: (DragEndDetails event) {
        Offset offset = event.velocity.pixelsPerSecond;
        double primaryVelocity = event.primaryVelocity ?? 0;
        double scaleDiff =
            ((_photoViewControllers[_currPageIndex].initial.scale ?? 0) -
                    (_photoViewControllers[_currPageIndex].scale ?? 0))
                .abs();
        if (primaryVelocity > 0 &&
            offset.dy > 250 &&
            !_scaleStateControllers[_currPageIndex].isZooming &&
            scaleDiff < 0.2) {
          // dismiss snackBar if need
          _dismissSnackBar(context);

          // dismiss bottomSheet if need
          _bottomSheetController?.close();

          // dismiss imageLoader page
          // dismiss the current page and scroll to the target image of gived index.
          Navigator.of(context).pop(_currPageIndex);
        }
      },
    ));
  }

  Widget _buildImageShareButton(BuildContext context) {
    return StreamBuilder(
        stream: _imageSharedController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          final shared =
              snapshot.data is bool ? (snapshot.data as bool? ?? false) : false;
          final sharedCnt =
              _imageSelectedStates.where((elem) => elem).toList().length;
          return TextButton(
              style: !shared
                  ? TextButton.styleFrom(
                      primary: Colors.grey, onSurface: Colors.grey)
                  : TextButton.styleFrom(
                      primary: Colors.white,
                    ),
              onPressed: shared
                  ? () {
                      // dismiss snackBar if need
                      _dismissSnackBar(context);
                      // open `share` popup.
                      _onShare(context);
                    }
                  : null,
              child: Row(children: [
                Platform.isIOS
                    ? const Icon(Icons.ios_share_outlined)
                    : const Icon(Icons.share_outlined),
                Text(sharedCnt > 0 ? '$sharedCnt' : '')
              ]));
        });
  }

  Widget _buildImageInfoButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
          alignment: Alignment.center, primary: Colors.white),
      onPressed: () {
        _sendImageInfo(context);
        _displayImageInfoSheet(context);
      },
      child: const Icon(Icons.info_outlined),
    );
  }

  Widget _buildImageSaveButton(BuildContext context) {
    return StreamBuilder(
        stream: _imageLoadedController.stream,
        builder: (context, snapshot) {
          bool imageLoaded =
              snapshot.data is bool ? (snapshot.data as bool? ?? false) : false;
          log.info(
              'currPageIndex -- 1 =$_currPageIndex, name=${_getImageFileName()}, loaded=$imageLoaded');
          return TextButton(
              style: !imageLoaded
                  ? TextButton.styleFrom(
                      primary: Colors.grey, onSurface: Colors.grey)
                  : TextButton.styleFrom(
                      primary: Colors.white,
                    ),
              onPressed:
                  !imageLoaded ? null : () => _saveSelectedImage(context),
              child: const Icon(Icons.save_alt_sharp));
        });
  }

  void _saveSelectedImage(BuildContext context) {
    widget.presenter
        .eventRegisterImageIntoGallery(
            input: ImageLoaderPresenterInput(
                imageSrc: _imageSrcList[_currPageIndex]))
        .then((result) {
      // dismiss snackBar if need
      _dismissSnackBar(context);

      // show snackBar
      final snackBar = SnackBar(
        margin: const EdgeInsets.only(bottom: 45),
        behavior: SnackBarBehavior.floating,
        content: Text(
          result ? 'The image has saved!' : 'The image has saved!',
        ),
        duration: const Duration(seconds: 5),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _snackBar = snackBar;
    });
  }

  void _dismissSnackBar(BuildContext context) {
    // dismiss snackBar
    if (_snackBar != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _snackBar = null;
    }
  }

  void _displayImageInfoSheet(
    BuildContext context,
  ) {
    String formatFileSize(double size) {
      double ret = size / (1024 * 1024);
      ret = ret < 0.01 ? 0.01 : ret;
      return ret.toStringAsFixed(2);
    }

    // show bottomSheet
    _bottomSheetController =
        _scaffoldKey.currentState?.showBottomSheet<dynamic>(
      (BuildContext context_) {
        return StreamBuilder(
            stream: _imageInfoController.stream,
            builder: (context, snapshot) {
              _InnnerImageInfo imageInfo;
              log.info('_sendImageInfo [2]: filename = ..');
              if (snapshot.data is _InnnerImageInfo) {
                imageInfo = snapshot.data as _InnnerImageInfo;
              } else {
                return Container();
              }
              return Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                    borderRadius:
                        const BorderRadius.all(Radius.circular(20.0))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageInfoAlertRow(context_,
                        title: 'File Name: ', text: imageInfo.filename),
                    _buildImageInfoAlertRow(context_,
                        title: 'File Size:',
                        text: '${formatFileSize(imageInfo.filesize)} MB'),
                    _buildImageInfoAlertRow(context_,
                        title: 'Image Size:',
                        text:
                            '${imageInfo.imageWidth.toStringAsFixed(0)} x ${imageInfo.imageHeight.toStringAsFixed(0)}'),
                  ],
                ),
              );
            });
      },
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
          maxHeight: 300, maxWidth: MediaQuery.of(context).size.width * 0.8),
    );
  }

  Widget _buildImageInfoAlertRow(BuildContext context,
      {required String title, required String text}) {
    return Row(
      children: [
        Container(
            alignment: Alignment.topLeft,
            width: 100,
            height: 40,
            padding: const EdgeInsets.only(left: 20),
            child: Text(title,
                style: const TextStyle(color: Colors.black54, fontSize: 14))),
        Flexible(
            child: Container(
                height: 40,
                padding: const EdgeInsets.only(left: 6, right: 20),
                child: Text(text,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    maxLines: 2))),
      ],
    );
  }

  void _parseRouteParameter(BuildContext context) {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      //
      // get page paratmers via ModalRoute
      //
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      // _appBarTitle =
      //     _parameters?[ImageLoaderParamKeys.appBarTitle] as String? ?? '';
      _imageIndex = _parameters?[ImageLoaderParamKeys.imageIndex] as int? ?? 0;
      _imageSrcList =
          _parameters?[ImageLoaderParamKeys.imageSrcList] as List? ?? [];

      //
      // FA
      //

      ///
      /// init some variables
      ///
      // photoViewController list
      _photoViewControllers =
          List.filled(_imageSrcList.length, PhotoViewController());
      for (final item in _photoViewControllers) {
        item.outputStateStream.listen((event) {
          if (item.initial.scale == null) {
            item.initial = event;
          }
        });
      }

      // PhotoViewScaleStateController list
      _scaleStateControllers =
          List.filled(_imageSrcList.length, PhotoViewScaleStateController());
      // PageController
      _pageController = PageController(initialPage: _imageIndex);

      // init some variables
      _currPageIndex = _imageIndex;
      String imageTitle = _getImageTitle();
      _imageLoadingStates = {};

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_imageLoadingStates.containsKey(imageTitle)) {
          _imageLoadedController.sink.add(false);
          log.info(
              'currPageIndex -- 9 =$_currPageIndex, name=${_getImageFileName()}, loaded=false');
        }
        // init imageSelected
        _imageSelectedStates = List.filled(_imageSrcList.length, false);
        _imageSelectedController.add(false);

        // init imageShare button state
        _imageSharedController.add(false);

        // send imageLoad state again if need
        Future.delayed(const Duration(milliseconds: 500), () {
          int delayTime = _isPageLoading ? 2500 : 0;

          Future.delayed(Duration(milliseconds: delayTime), () {
            if (!_imageLoadingStates.containsKey(imageTitle)) {
              _imageLoadingStates[imageTitle] = true;
              _imageLoadedController.sink.add(true);
              log.info(
                  'currPageIndex -- 10 =$_currPageIndex, name=${_getImageFileName()}, loaded=true');
            }
          });
        });
      });
    }
  }

  void _sendImageInfo(BuildContext context) async {
    File file = await DefaultCacheManager()
        .getSingleFile(_imageSrcList[_currPageIndex]);
    String filename = (String name1, String name2) {
      return StringUtil().substring(name1, start: '', end: '.') + name2;
    }(_getImageFileName(), extension(file.path));

    int size = await file.length();
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);
    Future.delayed(const Duration(milliseconds: 300), () {
      _InnnerImageInfo imageInfo = _InnnerImageInfo();
      imageInfo.filename = filename;
      imageInfo.filesize = size.toDouble();
      imageInfo.imageWidth = image.width.toDouble();
      imageInfo.imageHeight = image.height.toDouble();
      _imageInfoController.add(imageInfo);
    });
  }

  void _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    final box = context.findRenderObject() as RenderBox?;
    List<XFile> xFiles = [];
    for (int idx = 0; idx < _imageSelectedStates.length; idx++) {
      if (_imageSelectedStates[idx]) {
        final file =
            await DefaultCacheManager().getSingleFile(_imageSrcList[idx]);
        xFiles.add(XFile(file.path));
      }
    }
    if (xFiles.isEmpty) {
      return;
    }
    await Share.shareXFiles(xFiles,
        text: 'Share the image',
        subject: 'Share the image',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  String _getImageTitle({int pageIndex = -1}) {
    int pageIndex_ = pageIndex < 0 ? _currPageIndex : pageIndex;
    return '${pageIndex_ + 1} / ${_imageSrcList.length}';
  }

  String _getImageFileName({int pageIndex = -1}) {
    int pageIndex_ = pageIndex < 0 ? _currPageIndex : pageIndex;

    String str = StringUtil().lastSegment(_imageSrcList[pageIndex_]);
    if (str.length > 22) {
      return str.substring(0, 16) + str.substring(str.length - 6, str.length);
    }
    return str;
  }
}

class _InnnerImageInfo {
  late String filename;
  late double filesize;
  late double imageWidth;
  late double imageHeight;
}
