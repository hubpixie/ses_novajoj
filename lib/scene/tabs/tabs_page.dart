import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/tabs/tabs_presenter.dart';
import 'package:ses_novajoj/utilities/firebase_util.dart';

class TabsPage extends StatefulWidget {
  final TabsPresenter presenter;
  const TabsPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _TabsPageState createState() => _TabsPageState();
}

/*
class _TabsPageState extends State<TabsPage> {
  @override
  void initState() {
    // it moves to Login View automatically.
    Future.delayed(const Duration(seconds: 2), () {
      widget.presenter.startLogin();
    });
    super.initState();
    // send viewEvent
    //FirebaseUtil().sendViewEvent(route: AnalyticsRoute.tabs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABC5FD),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/ses_tabs.png',
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[850],
              ),
            ),
          )
        ],
      ),
    );
  }
}*/
class _TabsPageState extends State<TabsPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  static const List<String> _tabTitles = [
    "Home",
    "BBS",
    "Local",
    "Search",
    "Threads"
  ];

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // App call resume if background end.
    if (state == AppLifecycleState.resumed) {}
    super.didChangeAppLifecycleState(state);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B80F3),
        title: Text(_tabTitles[_selectedIndex]),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          Container(),
          Container(),
          Container(),
          Container(),
          Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: _tabTitles[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum_rounded),
            label: _tabTitles[1],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_library_rounded),
            label: _tabTitles[2],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_rounded),
            label: _tabTitles[3],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.comment_rounded),
            label: _tabTitles[4],
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFFF2F2F2),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
