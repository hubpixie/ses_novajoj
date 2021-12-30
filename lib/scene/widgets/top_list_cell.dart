import 'package:flutter/material.dart';

typedef CellSelectingDelegate = void Function();

class TopListCell extends StatelessWidget {
  //final TodoListRowViewModel row;
  final int index;
  final CellSelectingDelegate? onCellSelecting;

  const TopListCell({Key? key, required this.index, this.onCellSelecting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final presenter = BlocProvider.of<TodoListPresenter>(context)!;

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
                      child:
                          Image.asset("assets/images/icon_top_cell_blank.png"),
                    )),
                const SizedBox(width: 10),
                Expanded(
                    flex: 5,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              "东京首次报告无出国记录而感染奥密克戎病例！东京首次报告无出国记录而感染奥密克戎病例！",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff333333))),
                          const SizedBox(width: 10),
                          Row(children: [
                            const Icon(Icons.chat_bubble_outline,
                                size: 12, color: Colors.pinkAccent),
                            const SizedBox(width: 3),
                            const Text("47",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.pinkAccent)),
                            const SizedBox(width: 10),
                            const Text("12/27(二) 8:12",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                    textBaseline: TextBaseline.ideographic)),
                            const SizedBox(width: 10),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.black12),
                              child: const Text("NEW",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.0,
                                      color: Colors.redAccent,
                                      letterSpacing: -0.5)),
                            )
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
