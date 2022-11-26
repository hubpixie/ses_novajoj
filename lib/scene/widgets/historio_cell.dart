import 'package:flutter/material.dart';
//import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_presenter_output.dart';

typedef CellSelectingDelegate = void Function(int);
typedef ThumbnameShowingDelegate = Future<String> Function(int);

class HistorioCell extends StatelessWidget {
  final dynamic viewModel;
  final int index;
  final CellSelectingDelegate? onCellSelecting;
  final ThumbnameShowingDelegate? onThumbnailShowing;
  final Widget? divider;
  final double indent;
  final double endIndent;

  const HistorioCell(
      {Key? key,
      required this.viewModel,
      required this.index,
      this.onCellSelecting,
      this.onThumbnailShowing,
      this.divider,
      this.indent = 35,
      this.endIndent = 35})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final hisInfo = viewModel.hisInfo ?? viewModel.bookmark;
    return InkWell(
        onTap: () {
          onCellSelecting?.call(index);
        },
        splashColor: Colors.black12,
        splashFactory: InkRipple.splashFactory,
        child: Container(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0),
            child: Column(children: [
              viewModel.createdAtText.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.only(left: indent),
                      color: Colors.grey[100],
                      alignment: Alignment.topLeft,
                      height: 18,
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(viewModel.createdAtText,
                          style: const TextStyle(fontSize: 14)),
                    )
                  : const SizedBox(height: 0, width: 0),
              Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                    width: 32,
                    child: Text(hisInfo?.category ?? '',
                        style: const TextStyle(fontSize: 10))),
                const SizedBox(width: 5),
                Container(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                      width: 37.5,
                      height: 30,
                      child: FutureBuilder(
                        future: (String url) async {
                          String thumbUrl =
                              await onThumbnailShowing?.call(index) ?? '';
                          return thumbUrl;
                        }(hisInfo?.itemInfo.urlString ?? ''),
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
                const SizedBox(width: 5),
                SizedBox(
                    width: screenWidth <= 320
                        ? 100
                        : screenWidth - 95 - indent - endIndent,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hisInfo?.itemInfo.title ?? '',
                              softWrap: true,
                              style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff333333))),
                          const SizedBox(height: 3),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 1, height: 20),
                                Container(
                                    height: 16,
                                    alignment: Alignment.bottomLeft,
                                    child: Text(hisInfo?.itemInfo.source ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11.0,
                                            color: Colors.black54))),
                                const Spacer(),
                                Container(
                                    width: 100,
                                    height: 16,
                                    alignment: Alignment.bottomRight,
                                    child: Text(viewModel.itemInfoCreatedAtText,
                                        style: const TextStyle(
                                            fontSize: 11.0,
                                            color: Colors.grey,
                                            textBaseline:
                                                TextBaseline.ideographic))),
                              ])
                        ]))
              ]),
              divider != null ? divider! : const SizedBox(height: 0)
            ])));
  }
}
