import 'package:flutter/material.dart';

typedef CellSelectingDelegate = void Function(int);
typedef ThumbnameShowingDelegate = Future<String> Function(int);

class SimpleNovaListCell extends StatelessWidget {
  final dynamic viewModel;
  final int index;
  final CellSelectingDelegate? onCellSelecting;
  final ThumbnameShowingDelegate? onThumbnailShowing;

  const SimpleNovaListCell(
      {Key? key,
      required this.viewModel,
      required this.index,
      this.onCellSelecting,
      this.onThumbnailShowing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onCellSelecting?.call(index);
        },
        splashColor: Colors.black12,
        splashFactory: InkRipple.splashFactory,
        child: Container(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0),
            child: Column(children: [
              Row(children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                      width: 70.0,
                      height: 52.0,
                      child: FutureBuilder(
                        future: (String url) async {
                          String thumbUrl =
                              await onThumbnailShowing?.call(index) ?? '';
                          return thumbUrl;
                        }(viewModel.itemInfo.urlString),
                        builder: (context, snapshot) {
                          String blankUrl =
                              "assets/images/icon_top_cell_blank.png";
                          if (!snapshot.hasData) {
                            return Image.asset(blankUrl);
                          }
                          String thumbUrl = blankUrl;
                          if (snapshot.data is String) {
                            thumbUrl = snapshot.data as String? ?? "";
                          }
                          if (thumbUrl.isNotEmpty && thumbUrl != blankUrl) {
                            return Image.network(thumbUrl,
                                errorBuilder: (context, object, stackTrace) =>
                                    Image.asset(blankUrl));
                          }
                          return Image.asset(blankUrl);
                        },
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                    flex: 5,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(viewModel.itemInfo.title,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff333333))),
                          const SizedBox(width: 10),
                        ]))
              ]),
              const SizedBox(height: 5),
              const Divider(
                height: 1.0,
                thickness: 1.0,
              ),
              const SizedBox(height: 5),
            ])));
  }
}
