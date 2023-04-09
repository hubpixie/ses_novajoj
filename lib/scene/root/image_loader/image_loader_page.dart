import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/root/image_loader/image_loader_presenter.dart';
import 'package:ses_novajoj/scene/root/image_loader/image_loader_presenter_output.dart';

class ImageLoaderPage extends StatefulWidget {
  final ImageLoaderPresenter presenter;
  const ImageLoaderPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _ImageLoaderPageState createState() => _ImageLoaderPageState();
}

class _ImageLoaderPageState extends State<ImageLoaderPage> {
  late String _appBarTitle;
  Map? _parameters;

  late List<PhotoViewController> _photoViewControllers;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //_parseRouteParameter();

    return Scaffold(
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.close_outlined)),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          // _saveNetworkImage(src: srcList[currPageIndex]).then(
                          //     (value) => Navigator.of(dialogContext).pop());
                        },
                        child: const Icon(Icons.save_alt_sharp)),
                  ],
                ),
                /*Expanded(
                    child: GestureDetector(
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider:
                            CachedNetworkImageProvider(srcList[index]),
                        controller: photoViewControllers[index],
                        scaleStateController: scaleStateControllers[index],
                      );
                    },
                    itemCount: srcList.length,
                    onPageChanged: (pageIndex) {
                      currPageIndex = pageIndex;
                    },
                    pageController: pageController,
                  ),
                  onVerticalDragEnd: (DragEndDetails event) {
                    Offset offset = event.velocity.pixelsPerSecond;
                    double primaryVelocity = event.primaryVelocity ?? 0;
                    double scaleDiff = ((photoViewControllers[currPageIndex]
                                    .initial
                                    .scale ??
                                0) -
                            (photoViewControllers[currPageIndex].scale ?? 0))
                        .abs();
                    if (primaryVelocity > 0 &&
                        offset.dy > 250 &&
                        !scaleStateControllers[currPageIndex].isZooming &&
                        scaleDiff < 0.1) {
                      Navigator.pop(dialogContext);
                    }
                  },
                )),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
