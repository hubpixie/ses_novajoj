import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ses_novajoj/l10n/l10n.dart';
import 'package:ses_novajoj/scene/tabs/tabs_presenter.dart';
import 'package:ses_novajoj/scene/top_list/top_list_page_builder.dart';
import 'package:ses_novajoj/scene/bbs_main/bbs_main_page_builder.dart';
import 'package:ses_novajoj/scene/local_list/local_list_page_builder.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_page_builder.dart';
import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_page_builder.dart';

class TabsPage extends StatefulWidget {
  final TabsPresenter presenter;
  const TabsPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> with WidgetsBindingObserver {
  static const MethodChannel _channel =
      MethodChannel('com.pixie.sesNovajoj/app_helper');

  int _selectedIndex = 0;
  late final List<String> _tabTitles = [
    L10n.of(context)?.tabBarNameHome ?? '',
    L10n.of(context)?.tabBarNameBBS ?? '',
    L10n.of(context)?.tabBarNameLocal ?? '',
    L10n.of(context)?.tabBarNameInfoServiceForMe ?? '',
    L10n.of(context)?.tabBarNameThreads ?? ''
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    return WillPopScope(
        onWillPop: () async {
          if (Platform.isAndroid) {
            if (Navigator.of(context).canPop()) {
              _channel.invokeMethod('sendToBackground');
              return Future.value(false);
            } else {
              return Future.value(false);
            }
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              TopListPageBuilder().page,
              BbsMainPageBuilder().page,
              LocalListPageBuilder().page,
              MiscInfoListPageBuilder().page,
              ThreadListPageBuilder().page,
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
                icon: const Icon(Icons.person_outline_rounded),
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
        ));
  }
}
