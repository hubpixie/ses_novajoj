import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter.dart';
import 'package:ses_novajoj/utilities/firebase_util.dart';
import 'package:ses_novajoj/scene/widgets/top_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/square_text_icon_button.dart';

class TopListPage extends StatefulWidget {
  final TopListPresenter presenter;
  const TopListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _TopListPageState createState() => _TopListPageState();
}

class _TopListPageState extends State<TopListPage> {
  int _selectedIconIndex = 0;

  @override
  void initState() {
    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('aaa');
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B80F3),
          automaticallyImplyLeading: false,
          leading: const SizedBox(width: 0),
          title: _buildAppBarTitleArea(context),
          actions: _buildAppBarActionArea(context),
          centerTitle: false,
          titleSpacing: 0,
          leadingWidth: 10,
        ),
        body: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xffc5c5c5), width: 0.3))),
          child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => TopListCell(
                  onCellSelecting: () {
                    print('onCellSelecting = $index');
                  },
                  index: index)),
        ));
  }

  Widget _buildAppBarTitleArea(BuildContext context) {
    return SizedBox(
        width: 235,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareTextIconButton(
              string: '新',
              index: 0,
              selected: _selectedIconIndex == 0,
              onCellSelecting: () {
                _selectTextIcon(0);
              },
            ),
            SquareTextIconButton(
              string: '观',
              index: 1,
              selected: _selectedIconIndex == 1,
              onCellSelecting: () {
                _selectTextIcon(1);
              },
            ),
            SquareTextIconButton(
              string: '荐',
              index: 2,
              selected: _selectedIconIndex == 2,
              onCellSelecting: () {
                _selectTextIcon(2);
              },
            ),
            SquareTextIconButton(
              string: '热',
              index: 3,
              selected: _selectedIconIndex == 3,
              onCellSelecting: () {
                _selectTextIcon(3);
              },
            ),
            SquareTextIconButton(
              string: '论',
              index: 4,
              selected: _selectedIconIndex == 4,
              onCellSelecting: () {
                _selectTextIcon(4);
              },
            ),
            const SizedBox(
                width: 110,
                height: 35,
                child: IconButton(
                    padding: EdgeInsets.only(left: 20),
                    onPressed: null,
                    icon: Text('即时新闻',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ));
  }

  List<Widget> _buildAppBarActionArea(BuildContext context) {
    return <Widget>[
      SizedBox(
          width: 50,
          height: 50,
          child: IconButton(
              padding: const EdgeInsets.all(0.0),
              color: Colors.white,
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded))),
      const SizedBox(
        width: 20,
        height: 50,
      )
    ];
  }

  void _selectTextIcon(int index) {
    setState(() {
      _selectedIconIndex = index;
    });
  }
}
