import 'dart:async';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:ses_novajoj/foundation/data/string_util.dart';
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

  Map? _parameters;

  SnackBar? _snackBar;
  late List<PhotoViewController> _photoViewControllers;
  late List<PhotoViewScaleStateController> _scaleStateControllers;
  late Map<String, bool> _imageLoadingStates;
  late PageController _pageController;
  late StreamController<String> _imageNameController;
  late StreamController<bool> _imageLoadedController;

  @override
  void initState() {
    super.initState();
    _imageNameController = StreamController<String>.broadcast();
    _imageLoadedController = StreamController<bool>.broadcast();
    _imageLoadingStates = {};
  }

  @override
  void dispose() {
    _imageNameController.close();
    _imageLoadedController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return WillPopScope(
        onWillPop: () {
          if (_snackBar != null) {
            // dismiss snackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _snackBar = null;
          }
          return Future.value(true);
        },
        child: Scaffold(
          /* appBar: AppBar(
        title: const Text("title"),
      ),*/
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
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              alignment: Alignment.center,
                              primary: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (_snackBar != null) {
                              // dismiss snackBar
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              _snackBar = null;
                            }
                          },
                          child: const Icon(Icons.close_outlined),
                        ),
                        const Spacer(),
                        StreamBuilder(
                            stream: _imageNameController.stream,
                            builder: (context, snapshot) {
                              String imageName = snapshot.data is String
                                  ? (snapshot.data as String? ?? "")
                                  : _getImageFileName();
                              return Text(
                                imageName,
                                style: const TextStyle(color: Colors.white),
                              );
                            }),
                        const Spacer(),
                        StreamBuilder(
                            stream: _imageLoadedController.stream,
                            builder: (context, snapshot) {
                              bool imageLoaded = snapshot.data is bool
                                  ? (snapshot.data as bool? ?? false)
                                  : false;
                              return TextButton(
                                  style: !imageLoaded
                                      ? TextButton.styleFrom(
                                          primary: Colors.grey,
                                          onSurface: Colors.grey)
                                      : TextButton.styleFrom(
                                          primary: Colors.white,
                                        ),
                                  onPressed: !imageLoaded
                                      ? null
                                      : () => _saveSelectedImage(),
                                  child: const Icon(Icons.save_alt_sharp));
                            }),
                      ],
                    ),
                    Expanded(
                        child: GestureDetector(
                      child: PhotoViewGallery.builder(
                        scrollPhysics: const BouncingScrollPhysics(),
                        builder: (BuildContext context, int index) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: CachedNetworkImageProvider(
                                _imageSrcList[index]),
                            controller: _photoViewControllers[index],
                            scaleStateController: _scaleStateControllers[index],
                          );
                        },
                        itemCount: _imageSrcList.length,
                        onPageChanged: (pageIndex) {
                          _currPageIndex = pageIndex;
                          int pageIndex_ = pageIndex;
                          // imageLoaded
                          Future.delayed(const Duration(milliseconds: 300), () {
                            // imageName
                            String imageName =
                                _getImageFileName(pageIndex: pageIndex_);

                            if (!_imageLoadingStates.containsKey(imageName)) {
                              _imageLoadingStates[imageName] = true;
                              _imageLoadedController.add(true);
                            }
                          });
                        },
                        pageController: _pageController,
                        loadingBuilder: (BuildContext context,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null ||
                              loadingProgress.expectedTotalBytes == null ||
                              loadingProgress.expectedTotalBytes ==
                                  loadingProgress.cumulativeBytesLoaded) {
                            String imageName = _getImageFileName();
                            // imageLoaded
                            _imageLoadingStates[imageName] = true;
                            _imageLoadedController
                                .add(_imageLoadingStates[imageName]!);
                            return Container();
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                      onVerticalDragEnd: (DragEndDetails event) {
                        Offset offset = event.velocity.pixelsPerSecond;
                        double primaryVelocity = event.primaryVelocity ?? 0;
                        double scaleDiff =
                            ((_photoViewControllers[_currPageIndex]
                                            .initial
                                            .scale ??
                                        0) -
                                    (_photoViewControllers[_currPageIndex]
                                            .scale ??
                                        0))
                                .abs();
                        if (primaryVelocity > 0 &&
                            offset.dy > 250 &&
                            !_scaleStateControllers[_currPageIndex].isZooming &&
                            scaleDiff < 0.1) {
                          Navigator.pop(context);
                        }
                      },
                    )),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _saveSelectedImage() {
    widget.presenter
        .eventRegisterImageIntoGallery(
            input: ImageLoaderPresenterInput(
                imageSrc: _imageSrcList[_currPageIndex]))
        .then((result) {
      if (_snackBar != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _snackBar = null;
      }
      final snackBar = SnackBar(
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

  void _parseRouteParameter() {
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
      String imageName = _getImageFileName();
      Future.delayed(const Duration(milliseconds: 500), () {
        _imageLoadedController.add(false);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_imageLoadingStates.containsKey(imageName)) {
            _imageLoadingStates[imageName] = true;
            _imageLoadedController.add(true);
          }
        });
      });
    }
  }

  String _getImageFileName({int pageIndex = -1}) {
    int pageIndex_ = pageIndex < 0 ? _currPageIndex : pageIndex;

    String str = StringUtil().lastSegment(_imageSrcList[pageIndex_]);
    if (str.length > 14) {
      return str.substring(0, 10) + str.substring(str.length - 4, str.length);
    }
    return str;
  }
}
