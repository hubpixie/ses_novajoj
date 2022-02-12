import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter_output.dart';

typedef CellSelectingDelegate = void Function();

class TopListCell extends StatelessWidget {
  final NovaListRowViewModel item;
  final int index;
  final CellSelectingDelegate? onCellSelecting;

  const TopListCell(
      {Key? key, required this.item, required this.index, this.onCellSelecting})
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
                          Text(item.title,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff333333))),
                          const SizedBox(width: 10),
                          Row(children: [
                            const Icon(Icons.chat_bubble_outline,
                                size: 12, color: Colors.pinkAccent),
                            const SizedBox(width: 3),
                            Text("${item.reads}",
                                style: const TextStyle(
                                    fontSize: 12.0, color: Colors.pinkAccent)),
                            const SizedBox(width: 10),
                            Text(item.createAtText,
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                    textBaseline: TextBaseline.ideographic)),
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
}
