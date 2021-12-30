import 'package:flutter/material.dart';
import 'package:ses_novajoj/l10n/l10n.dart';
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
  late String _selectedAppBarTitle =
      L10n.of(context)?.appBarFullNameLatest ?? '';

  @override
  void initState() {
    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        width: 265,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareTextIconButton(
              string: L10n.of(context)?.appBarIconNameLatest ?? '',
              index: 0,
              selected: _selectedIconIndex == 0,
              onCellSelecting: () {
                _selectTextIcon(0);
              },
            ),
            SquareTextIconButton(
              string: L10n.of(context)?.appBarIconNameOptic ?? '',
              index: 1,
              selected: _selectedIconIndex == 1,
              onCellSelecting: () {
                _selectTextIcon(1);
              },
            ),
            SquareTextIconButton(
              string: L10n.of(context)?.appBarIconNameRecommending ?? '',
              index: 2,
              selected: _selectedIconIndex == 2,
              onCellSelecting: () {
                _selectTextIcon(2);
              },
            ),
            SquareTextIconButton(
              string: L10n.of(context)?.appBarIconNameHot ?? '',
              index: 3,
              selected: _selectedIconIndex == 3,
              onCellSelecting: () {
                _selectTextIcon(3);
              },
            ),
            SquareTextIconButton(
              string: L10n.of(context)?.appBarIconNameCommenting ?? '',
              index: 4,
              selected: _selectedIconIndex == 4,
              onCellSelecting: () {
                _selectTextIcon(4);
              },
            ),
            SizedBox(
                width: 140,
                height: 35,
                child: IconButton(
                    padding: const EdgeInsets.only(left: 5),
                    onPressed: null,
                    icon: Text(_selectedAppBarTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ));
  }

  List<Widget> _buildAppBarActionArea(BuildContext context) {
    return <Widget>[
      SizedBox(
          width: 45,
          height: 45,
          child: IconButton(
              padding: const EdgeInsets.all(0.0),
              color: Colors.white,
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded))),
      SizedBox(
        width: MediaQuery.of(context).size.width <= 375 ? 0 : 25,
        height: 50,
      )
    ];
  }

  void _selectTextIcon(int index) {
    List<String> titles = [
      L10n.of(context)?.appBarFullNameLatest ?? '',
      L10n.of(context)?.appBarFullNameOptic ?? '',
      L10n.of(context)?.appBarFullNameRecommending ?? '',
      L10n.of(context)?.appBarFullNameHot ?? '',
      L10n.of(context)?.appBarFullNameCommenting ?? '',
    ];
    setState(() {
      _selectedIconIndex = index;
      _selectedAppBarTitle = titles[index];
    });
  }
}
