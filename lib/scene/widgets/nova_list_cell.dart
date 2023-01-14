import 'package:flutter/material.dart';

typedef CellSelectingDelegate = void Function(int);
typedef CellPageChangedDelegate = void Function(int);
typedef CellScrollDelegate = void Function();
typedef ThumbnameShowingDelegate = Future<String> Function(int);

class NovaListCell extends StatelessWidget {
  final dynamic viewModel;
  final int index;
  final bool pageEnd;
  final CellSelectingDelegate? onCellSelecting;
  final CellSelectingDelegate? onPageChanged;
  final CellScrollDelegate? onScrollToTop;
  final ThumbnameShowingDelegate? onThumbnailShowing;

  const NovaListCell(
      {Key? key,
      required this.viewModel,
      required this.index,
      this.pageEnd = false,
      this.onCellSelecting,
      this.onPageChanged,
      this.onScrollToTop,
      this.onThumbnailShowing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: !pageEnd
            ? () {
                onCellSelecting?.call(index);
              }
            : null,
        splashColor: Colors.black12,
        splashFactory: InkRipple.splashFactory,
        child: Container(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0),
            child: Column(children: [
              !pageEnd
                  ? Row(children: [
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
                                if (thumbUrl.isNotEmpty &&
                                    thumbUrl != blankUrl) {
                                  return Image.network(thumbUrl,
                                      errorBuilder:
                                          (context, object, stackTrace) =>
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 1, height: 20),
                                      Container(
                                          width: _calculateAutoscaleWidth(
                                              context,
                                              viewModel.itemInfo.source,
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
                                          child: const Icon(
                                              Icons.chat_bubble_outline,
                                              size: 12,
                                              color: Colors.pinkAccent)),
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
                    ])
                  : _buildPagingArea(context),
              const SizedBox(height: 5),
              const Divider(
                height: 1.0,
                thickness: 1.0,
              ),
              const SizedBox(height: 5),
            ])));
  }

  Widget _buildPagingArea(BuildContext context) {
    Widget _makeIconButton(IconData? iconData,
        {required int targetPageIndex, required int pageCnt}) {
      return SizedBox(
          height: 35,
          width: 35,
          child: IconButton(
              iconSize: 35,
              padding: const EdgeInsets.only(left: 5),
              onPressed: (targetPageIndex < 1 || targetPageIndex > pageCnt)
                  ? null
                  : () => onPageChanged?.call(targetPageIndex),
              icon: Icon(iconData)));
    }

    final pageNum = viewModel.itemInfo.pageNumber ?? 0;
    final pageCnt = viewModel.itemInfo.pageCount ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 10),
        _makeIconButton(Icons.first_page,
            targetPageIndex: (pageNum > 1 && pageNum <= pageCnt) ? 1 : -1,
            pageCnt: pageCnt),
        const Spacer(),
        _makeIconButton(Icons.chevron_left,
            targetPageIndex: pageNum - 1, pageCnt: pageCnt),
        const Spacer(flex: 2),
        Text('$pageNum/$pageCnt'),
        const Spacer(flex: 1),
        _makeIconButton(Icons.chevron_right,
            targetPageIndex: pageNum + 1, pageCnt: pageCnt),
        const Spacer(),
        _makeIconButton(Icons.last_page,
            targetPageIndex: (pageNum >= 1 && pageNum < pageCnt) ? pageCnt : -1,
            pageCnt: pageCnt),
        const Spacer(flex: 5),
        SizedBox(
            height: 25,
            width: 25,
            child: IconButton(
                iconSize: 25,
                padding: const EdgeInsets.only(left: 5),
                onPressed: () => onScrollToTop?.call(),
                icon: const Icon(Icons.arrow_circle_up))),
        const Spacer(flex: 5)
      ],
    );
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
