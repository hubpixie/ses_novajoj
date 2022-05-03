import 'package:flutter/material.dart';

typedef CellSelectingDelegate = void Function(int);

class SimpleItemCwll extends StatelessWidget {
  final dynamic viewModel;
  final int index;
  final CellSelectingDelegate? onCellSelecting;

  const SimpleItemCwll(
      {Key? key,
      required this.viewModel,
      required this.index,
      this.onCellSelecting})
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
                                const SizedBox(width: 10),
                                Text(viewModel.createAtText,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                        textBaseline:
                                            TextBaseline.ideographic)),
                                const SizedBox(width: 10),
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
}
