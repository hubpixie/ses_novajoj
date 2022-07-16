import 'package:flutter/material.dart';

typedef RowSelectingDelegate = void Function(int);
typedef OtherRowSelectingDelegate = void Function(int);

class InfoServiceCell extends StatelessWidget {
  final String sectionTitle;
  final List<String> rowTitleList;
  final String? otherTitle;
  final RowSelectingDelegate? onRowSelecting;
  final OtherRowSelectingDelegate? onOtherRowSelecting;

  const InfoServiceCell(
      {Key? key,
      required this.sectionTitle,
      required this.rowTitleList,
      this.otherTitle,
      this.onRowSelecting,
      this.onOtherRowSelecting})
      : super(key: key);

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
              final int cnt = rowTitleList.length;
              rowTitleList.asMap().forEach((idx, str) {
                widgets.add(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: screenWidth - 80,
                        height: 40,
                        child: TextButton(
                          onPressed: () => onRowSelecting?.call(idx),
                          child: Text(
                            str,
                            style: const TextStyle(color: Color(0xFF8D918D)),
                          ),
                        )),
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
                      SizedBox(
                          width: screenWidth - 80,
                          height: 40,
                          child: TextButton(
                            onPressed: () => onOtherRowSelecting?.call(100),
                            child: Text(
                              otherTitle ?? '',
                              style: const TextStyle(color: Color(0xFF8D918D)),
                            ),
                          )),
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
