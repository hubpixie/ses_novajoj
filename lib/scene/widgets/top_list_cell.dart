import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter_output.dart';

typedef CellSelectingDelegate = void Function();
typedef ThumbnameShowingDelegate = Future<String> Function(int);

class TopListCell extends StatelessWidget {
  final NovaListRowViewModel item;
  final int index;
  final CellSelectingDelegate? onCellSelecting;
  final ThumbnameShowingDelegate? onThumbnailShowing;

  const TopListCell(
      {Key? key,
      required this.item,
      required this.index,
      this.onCellSelecting,
      this.onThumbnailShowing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onCellSelecting?.call();
        },
        splashColor: Colors.black12,
        splashFactory: InkRipple.splashFactory,
        child: Container(
            padding: const EdgeInsets.all(2.0),
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
                        }(item.urlString),
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
                          return Image.network(thumbUrl);
                        },
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                    flex: 5,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
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
                                    width: _calculateAutoscaleWidth(item.source,
                                        fontSize: 12),
                                    height: 18,
                                    alignment: Alignment.bottomLeft,
                                    child: Text(item.source,
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
                                    child: Text("${item.reads}",
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.pinkAccent))),
                                const SizedBox(width: 10),
                                Text(item.createAtText,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                        textBaseline:
                                            TextBaseline.ideographic)),
                                const SizedBox(width: 10),
                                _buildNewArrivalArea(isNew: item.isNew)
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
            child: Text(item.isNewText,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.0,
                    color: Colors.redAccent,
                    letterSpacing: -0.5)),
          )
        : Container();
  }

  double _calculateAutoscaleWidth(String text,
      {required double fontSize, double maxWidth = 120}) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final style = TextStyle(fontSize: fontSize);
    textPainter.text = TextSpan(text: text, style: style);
    textPainter.layout();

    return textPainter.width >= maxWidth ? maxWidth : textPainter.width;
  }
}
