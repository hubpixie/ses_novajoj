import 'package:flutter/material.dart';

typedef _RowSelectingDelegate = void Function(int);
typedef _RowStartSelectingDelegate = void Function(int, TapDownDetails);
typedef _OtherRowSelectingDelegate = void Function(int);
typedef _OtherRowLongPressDelegate = void Function(int);

class InfoServiceCell extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> rowTitles;
  final Widget? otherTitle;
  final double Function(int index)? calcRowHeight;
  final _RowSelectingDelegate? onRowSelecting;
  final _RowStartSelectingDelegate? onRowStartSelecting;
  final _OtherRowLongPressDelegate? onRowLongPress;
  final _OtherRowSelectingDelegate? onOtherRowSelecting;

  const InfoServiceCell(
      {Key? key,
      required this.sectionTitle,
      required this.rowTitles,
      this.otherTitle,
      this.calcRowHeight,
      this.onRowSelecting,
      this.onRowStartSelecting,
      this.onRowLongPress,
      this.onOtherRowSelecting})
      : super(key: key);

  static const double kRowHeight = 40;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: () {
              List<Widget> widgets = [];
              widgets.add(Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 200,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF2FFFF),
                        border: Border.all(
                          color: Colors.black12,
                        ),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(40.0))),
                    child: SizedBox(
                      width: 100,
                      child: Text(sectionTitle),
                    ),
                  )
                ],
              ));
              widgets.add(const Divider(
                height: 1,
                thickness: 2,
                color: Colors.black12,
              ));

              // Row title
              final int cnt = rowTitles.length;
              rowTitles.asMap().forEach((idx, element) {
                widgets.add(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => onRowSelecting?.call(idx),
                      onTapDown: (tapDownDetails) =>
                          onRowStartSelecting?.call(idx, tapDownDetails),
                      onLongPress: () => onRowLongPress?.call(idx),
                      child: Container(
                          width: screenWidth - 80,
                          height: calcRowHeight == null
                              ? InfoServiceCell.kRowHeight
                              : calcRowHeight!(idx),
                          alignment: Alignment.center,
                          child: element),
                    ),
                  ],
                ));
                if (idx < cnt - 1) {
                  widgets.add(const Divider(
                    height: 1.0,
                    thickness: 0.5,
                  ));
                }
              });

              // Other Row
              if (otherTitle != null) {
                widgets.add(const Divider(
                  height: 1.0,
                  thickness: 0.5,
                ));
                widgets.add(Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () => onOtherRowSelecting?.call(100),
                        child: Container(
                            width: screenWidth - 80,
                            height: 40,
                            alignment: Alignment.center,
                            child: otherTitle!),
                      ),
                    ]));
              }
              widgets.add(const Divider(
                height: 1.0,
                thickness: 2.0,
              ));
              return widgets;
            }()));
  }
}
