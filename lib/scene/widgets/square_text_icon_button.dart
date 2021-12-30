import 'package:flutter/material.dart';

typedef CellSelectingDelegate = void Function();

class SquareTextIconButton extends StatelessWidget {
  final String string;
  final int index;
  final bool selected;
  final CellSelectingDelegate? onCellSelecting;

  const SquareTextIconButton(
      {Key? key,
      required this.string,
      required this.index,
      required this.selected,
      this.onCellSelecting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 25,
        height: 25,
        child: IconButton(
          iconSize: 12.0,
          padding: const EdgeInsets.all(0.0),
          onPressed: () {
            onCellSelecting?.call();
          },
          icon: Container(
            // color: selected ? Colors.white : const Color(0xFF1B80F3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: (selected ? Colors.white : const Color(0xFF1B80F3)),
                border: const Border(
                  top: BorderSide(color: Color(0xffc5c5c5), width: 1.0),
                  right: BorderSide(color: Color(0xffc5c5c5), width: 1.0),
                  bottom: BorderSide(color: Color(0xffc5c5c5), width: 1.0),
                  left: BorderSide(color: Color(0xffc5c5c5), width: 1.0),
                )),
            child: Text(
              string,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: selected ? const Color(0xFF1B80F3) : Colors.white,
                  //backgroundColor:
                  //    selected ? Colors.white : const Color(0xFF1B80F3),
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}
