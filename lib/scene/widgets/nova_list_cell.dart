import 'package:flutter/material.dart';

typedef CellSelectingDelegate = void Function(int);
typedef ThumbnameShowingDelegate = Future<String> Function(int);

class NovaListCell extends StatelessWidget {
  final dynamic viewModel;
  final int index;
  final CellSelectingDelegate? onCellSelecting;
  final ThumbnameShowingDelegate? onThumbnailShowing;

  const NovaListCell(
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
                      width: 90.0,
                      height: 72.0,
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
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 1, height: 20),
                                Container(
                                    width: _calculateAutoscaleWidth(
                                        context, viewModel.itemInfo.source,
                                        fontSize: 12),
                                    height: 18,
                                    alignment: Alignment.bottomLeft,
                                    child: Text(viewModel.itemInfo.source,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black54))),
                                const SizedBox(width: 10),
                                Container(
                                    height: 16,
                                    alignment: Alignment.bottomLeft,
                                    child: const Icon(Icons.chat_bubble_outline,
                                        size: 12, color: Colors.pinkAccent)),
                                const SizedBox(width: 3),
                                Container(
                                    height: 18,
                                    alignment: Alignment.bottomLeft,
                                    child: Text(viewModel.readsText,
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.pinkAccent))),
                                const Spacer(),
                                Text(viewModel.createAtText,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                        textBaseline:
                                            TextBaseline.ideographic)),
                                const SizedBox(width: 10),
                                _buildNewArrivalArea(
                                    isNew: viewModel.itemInfo.isNew)
                              ])
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

  Widget _buildNewArrivalArea({required bool isNew}) {
    return isNew
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: Colors.black12),
            child: Text(viewModel.isNewText,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.0,
                    color: Colors.redAccent,
                    letterSpacing: -0.5)),
          )
        : Container();
  }

  double _calculateAutoscaleWidth(BuildContext context, String text,
      {required double fontSize, double deltaWith = 260}) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final style = TextStyle(fontSize: fontSize);
    textPainter.text = TextSpan(text: text.runes.string, style: style);
    textPainter.layout();
    double maxWidth = (double screenWidth) {
      double deltaWidth_ = screenWidth <= 320 ? 15 : 0;
      return screenWidth - deltaWith - deltaWidth_;
    }(MediaQuery.of(context).size.width);
    return textPainter.width >= maxWidth ? maxWidth : textPainter.width;
  }
}
