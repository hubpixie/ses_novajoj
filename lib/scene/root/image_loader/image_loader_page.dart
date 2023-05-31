import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/root/image_loader/image_loader_presenter_output.dart';
import 'package:wakelock/wakelock.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
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
  Map? _parameters;
  late int _imageIndex;
  // late String _parentViewImagePath;
  late List<dynamic> _imageSrcList;
  late List<NovaImageInfo> _novaImageInfoList;
  int _currPageIndex = 0;
  int _currSlidePageIndex = 0;
  bool _isPageLoading = false;
  bool _isSlideShow = false;
  // double _dragPercent = 0;
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
  late StreamController<NovaImageInfo> _imageInfoController;
  late StreamController<bool> _imageSelectedController;
  late List<bool> _imageSelectedStates;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();

    _imageTitleController = StreamController<String>.broadcast();
    _imageLoadedController = StreamController<bool>.broadcast();
    _imageSharedController = StreamController<bool>.broadcast();
    _imageInfoController = StreamController<NovaImageInfo>.broadcast();
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
              // decoration: BoxDecoration(
              //     image: DecorationImage(
              //         image: Image.file(File(_parentViewImagePath)).image)),
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
                    _isSlideShow
                        ? _buildSlideContentArea(context,
                            srcList: _imageSrcList)
                        : _buildImageContentArea(context,
                            startPage: _currPageIndex),
                    Row(
                      children: [
                        _buildImageShareButton(context),
                        const Spacer(),
                        _buildImageInfoButton(context),
                        const Spacer(),
                        _buildSlideShowButton(context),
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

  Widget _buildDismissableFrame(BuildContext context,
      {required Widget child, required void Function() onDismissed}) {
    return DismissiblePage(
      onDismissed: () => onDismissed(),
      // Start of the optional properties
      isFullScreen: false,
      disabled: false,
      minRadius: 10,
      maxRadius: 10,
      dragSensitivity: 1.0,
      maxTransformValue: 0.5,
      direction: DismissiblePageDismissDirection.down,
      backgroundColor: Colors.transparent,
      onDragStart: () {},
      onDragUpdate: (details) {
        // _dragPercent = (details.offset.dy - dy);
        // setState(() {});
      },
      dismissThresholds: const {
        DismissiblePageDismissDirection.horizontal: 0.2,
        DismissiblePageDismissDirection.vertical: 0.01
      },
      minScale: .5,
      startingOpacity: 0.5,
      reverseDuration: const Duration(milliseconds: 250),
      // End of the optional properties
      child: child,
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        width: 90,
        child: TextButton(
          style: _buildEnabledButtonStyle(enabled: !_isSlideShow),
          onPressed: _isSlideShow
              ? null
              : () {
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
                style: _buildEnabledButtonStyle(enabled: !_isSlideShow),
                onPressed: _isSlideShow
                    ? null
                    : () {
                        // upadte imageSlect states
                        _imageSelectedStates[_currPageIndex] = !selected;
                        _imageSelectedController.add(!selected);

                        // update imageShare button state
                        final shared = _imageSelectedStates.firstWhere(
                            (elem) => elem == true,
                            orElse: () => false);
                        _imageSharedController.add(shared);
                      },
                child: Text(selected ? "unselect" : "select"),
              ));
        });
  }

  Widget _buildImageContentArea(BuildContext context,
      {required int startPage}) {
    return Expanded(
      child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: _buildDismissableFrame(
            context,
            onDismissed: () {
              // dismiss snackBar if need
              _dismissSnackBar(context);

              // dismiss bottomSheet if need
              _bottomSheetController?.close();

              // dismiss imageLoader page
              // dismiss the current page and scroll to the target image of gived index.
              Navigator.of(context).pop(_currPageIndex);
            },
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    _imageSrcList[index],
                  ),
                  controller: _photoViewControllers[index],
                  scaleStateController: _scaleStateControllers[index],
                );
              },
              itemCount: _imageSrcList.length,
              onPageChanged: (pageIndex) => _didImagePageChanged(pageIndex),
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
          )),
    );
  }

  Widget _buildImageShareButton(BuildContext context) {
    return StreamBuilder(
        stream: _imageSharedController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          var shared =
              snapshot.data is bool ? (snapshot.data as bool? ?? false) : false;
          shared = _isSlideShow ? false : shared;
          final sharedCnt =
              _imageSelectedStates.where((elem) => elem).toList().length;

          return TextButton(
              style: _buildEnabledButtonStyle(enabled: shared),
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
      style: _buildEnabledButtonStyle(enabled: !_isSlideShow),
      onPressed: _isSlideShow
          ? null
          : () {
              _sendImageInfo(context, pageIndex: _currPageIndex);
              _displayImageInfoSheet(context);
            },
      child: const Icon(Icons.info_outlined),
    );
  }

  Widget _buildSlideShowButton(BuildContext context) {
    return StreamBuilder(
        stream: _imageLoadedController.stream,
        builder: (context, snapshot) {
          bool imageLoaded =
              snapshot.data is bool ? (snapshot.data as bool? ?? false) : false;
          return TextButton(
              style: _buildEnabledButtonStyle(enabled: imageLoaded),
              onPressed: !imageLoaded
                  ? null
                  : () {
                      _isSlideShow = !_isSlideShow;
                      // disable / enable screenLock if need
                      Wakelock.toggle(enable: _isSlideShow);
                      if (!_isSlideShow) {
                        // keep current page index
                        _currPageIndex = _currSlidePageIndex;
                        _pageController =
                            PageController(initialPage: _currPageIndex);
                      }
                      setState(() {});
                    },
              child: !_isSlideShow
                  ? const Icon(Icons.slideshow_outlined)
                  : const Icon(Icons.pause_circle_outline_outlined));
        });
  }

  Widget _buildImageSaveButton(BuildContext context) {
    return StreamBuilder(
        stream: _imageLoadedController.stream,
        builder: (context, snapshot) {
          bool imageLoaded =
              snapshot.data is bool ? (snapshot.data as bool? ?? false) : false;
          imageLoaded = _isSlideShow ? false : imageLoaded;
          return TextButton(
              style: _buildEnabledButtonStyle(enabled: imageLoaded),
              onPressed:
                  !imageLoaded ? null : () => _saveSelectedImage(context),
              child: const Icon(Icons.save_alt_sharp));
        });
  }

  void _didImagePageChanged(int pageIndex) {
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

    // prepare fetching data of the left/right index.
    _prefetchImageInfos(context, pageIndex: pageIndex);

    // show imageInfo sheet if need
    if (_bottomSheetController != null) {
      _sendImageInfo(context, pageIndex: pageIndex);
    }

    // imageLoaded [1]
    if (_novaImageInfoList[pageIndex].displayName == null) {
      if (!_imageLoadingStates.containsKey(imageTitle)) {
        _imageLoadedController.sink.add(false);
      } else {
        _imageLoadedController.sink.add(_imageLoadingStates[imageTitle]!);
      }
    } else {
      _imageLoadingStates[imageTitle] = true;
      _imageLoadedController.sink.add(true);
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
            _imageLoadedController.sink.add(true);
          }
        } else {}
      });
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
              NovaImageInfo imageInfo;
              if (snapshot.data is NovaImageInfo) {
                imageInfo = snapshot.data as NovaImageInfo;
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
                        title: 'File Name: ', text: imageInfo.displayName!),
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

  Widget _buildSlideContentArea(BuildContext context,
      {required List<dynamic> srcList}) {
    List<Widget> widgets = [];
    int pageIndex = _currPageIndex;

    if (srcList.isEmpty) {
      widgets.add(Container());
    } else {
      _imageSrcList.asMap().forEach((index, value) {
        Widget widget = FutureBuilder<String>(
          future: () async {
            await _prefetchImageInfos(context, pageIndex: index, step: 0);
            return _novaImageInfoList[index].filename;
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            if (snapshot.data is String) {
              String filename = snapshot.data as String;
              return Image.file(File(filename));
            } else {
              return Container();
            }
          },
        );
        widgets.add(widget);
      });
    }
    return Expanded(
        child: CarouselSlider(
            items: widgets,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 0.8,
              initialPage: pageIndex,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(milliseconds: 3500),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOutQuart,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              onPageChanged: (value, _) async {
                _currSlidePageIndex = value;
                // imageTitle
                String imageTitle = _getImageTitle(pageIndex: value);
                _imageTitleController.sink.add(imageTitle);
              },
              scrollDirection: Axis.horizontal,
            )));
  }

  ButtonStyle? _buildEnabledButtonStyle({required enabled}) {
    return enabled
        ? TextButton.styleFrom(
            alignment: Alignment.center, primary: Colors.white)
        : TextButton.styleFrom(primary: Colors.grey, onSurface: Colors.grey);
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
      // _parentViewImagePath =
      //     _parameters?[ImageLoaderParamKeys.parentViewImage] as String? ?? '';

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

      // _novaImageInfoList
      _novaImageInfoList = [];
      for (int idx = 0; idx < _imageSrcList.length; idx++) {
        _novaImageInfoList.add(NovaImageInfo());
      }
      // prepare fetching image infos
      _prefetchImageInfos(context, pageIndex: 0);

      // PhotoViewScaleStateController list
      _scaleStateControllers =
          List.filled(_imageSrcList.length, PhotoViewScaleStateController());

      // PageController
      _pageController = PageController(initialPage: _imageIndex);

      // init some variables
      _currPageIndex = _imageIndex;
      _currSlidePageIndex = _imageIndex;

      String imageTitle = _getImageTitle();
      _imageLoadingStates = {};

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_imageLoadingStates.containsKey(imageTitle)) {
          _imageLoadedController.sink.add(false);
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
            }
          });
        });
      });
    }
  }

  Future<void> _prefetchImageInfos(BuildContext context,
      {int pageIndex = 0, int step = 3}) async {
    for (int idx = pageIndex - step; idx <= pageIndex + step; idx++) {
      if (idx < 0 || idx >= _imageSrcList.length) {
        continue;
      }
      if (_novaImageInfoList[idx].displayName == null) {
        final data = await widget.presenter.eventFetchImageInfo(
            input: ImageLoaderPresenterInput(imageSrc: _imageSrcList[idx]));
        if (data is ShowImageLoaderPageModel) {
          NovaImageInfo imageInfo = data.viewModel!.imageInfo;
          _novaImageInfoList[idx].displayName = imageInfo.displayName;
          _novaImageInfoList[idx].filename = imageInfo.filename;
          _novaImageInfoList[idx].filesize = imageInfo.filesize;
          _novaImageInfoList[idx].imageWidth = imageInfo.imageWidth;
          _novaImageInfoList[idx].imageHeight = imageInfo.imageHeight;
        }
      }
    }
  }

  void _sendImageInfo(BuildContext context, {int pageIndex = 0}) async {
    Future.delayed(const Duration(milliseconds: 300), () {
      _imageInfoController.add(_novaImageInfoList[pageIndex]);
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
        _prefetchImageInfos(context, pageIndex: idx);
        xFiles.add(XFile(_novaImageInfoList[idx].filename));
      }
    }
    if (xFiles.isEmpty) {
      return;
    }
    await Share.shareXFiles(xFiles,
        text: 'Share images',
        subject: 'Can share selected ${xFiles.length} images',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  String _getImageTitle({int pageIndex = -1}) {
    int pageIndex_ = pageIndex < 0 ? _currPageIndex : pageIndex;
    return '${pageIndex_ + 1} / ${_imageSrcList.length}';
  }
}
