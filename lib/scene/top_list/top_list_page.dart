import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/top_list/top_sub_page.dart';
import 'package:ses_novajoj/scene/root/search_page.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter.dart';

class TopListPage extends StatefulWidget {
  final List<TopListPresenter> presenters;
  const TopListPage({Key? key, required this.presenters}) : super(key: key);

  @override
  State<TopListPage> createState() => _TopListPageState();
}

class _TopListPageState extends State<TopListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTitleIndex = 0;
  late StreamController<TopSearchKeyItem> _reloadedController;

  late final List<String> _appBarTitleList = [
    UseL10n.of(context)?.appBarFullNameLatest ?? '',
    UseL10n.of(context)?.appBarFullNameOptic ?? '',
    UseL10n.of(context)?.appBarFullNameRecommending ?? '',
    UseL10n.of(context)?.appBarFullNameHot ?? '',
    UseL10n.of(context)?.appBarFullNameCommenting ?? '',
  ];
  late final _prefixNovaTitleHot = UseL10n.of(context)?.todayHotNews ?? '';
  late final _prefixNovaTitlePopulary =
      UseL10n.of(context)?.todayPopularNews ?? '';

  final List<String> _tabNames = ['・', '・', '・', '・', '・'];
  int _waitingCount = 0;

  // searchbar
  late String? _searchedUrl;
  final SearchPage _searchPage = SearchPage();
  String _currentSearchedKeyword = '';
  String _prevSearchedKeyword = '';

  @override
  void initState() {
    _tabController = TabController(length: _tabNames.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTitleIndex = _tabController.index;
      });
    });
    _reloadedController = StreamController<TopSearchKeyItem>.broadcast();

    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topList);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _reloadedController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        backgroundColor: ColorDef.appBarBackColor2,
        foregroundColor: ColorDef.appBarTitleColor,
        automaticallyImplyLeading: false,
        leading: const SizedBox(width: 0),
        title: Text(
          _appBarTitleList[_selectedTitleIndex],
          style: const TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        titleSpacing: 0,
        leadingWidth: 10,
        actions: _buildAppBarActionArea(context),
      ),*/
      appBar: _searchPage.buildAppBar(context,
          appBarTitle: _appBarTitleList[_selectedTitleIndex],
          automaticallyImplyLeading: false,
          searchAction: _selectedTitleIndex == 0
              ? (keyword) {
                  _currentSearchedKeyword = keyword;
                  if (keyword.isNotEmpty) {
                    _reloadedController
                        .add(TopSearchKeyItem(searchedKey: keyword));
                  }
                }
              : null,
          cancelAction: _selectedTitleIndex == 0
              ? (isSearched) {
                  if (isSearched) {
                    _reloadedController
                        .add(TopSearchKeyItem(searchResultIsCleared: true));
                  } else {
                    setState(
                      () {},
                    );
                  }
                  _currentSearchedKeyword = '';
                }
              : null,
          openSearchAction: () => setState(
                () {},
              ),
          refreshAction: _selectedTitleIndex == 0
              ? () {
                  _reloadedController.add(
                      TopSearchKeyItem(searchedKey: _currentSearchedKeyword));
                }
              : null),
      body: DefaultTabController(
        length: _tabNames.length,
        initialIndex: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 2,
              ),
              Container(
                alignment: AlignmentDirectional.center,
                height: 20,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  onTap: (value) {},
                  labelColor: Colors.yellowAccent,
                  unselectedLabelColor: Colors.black54,
                  tabs: _tabNames.map((name) => Tab(text: name)).toList(),
                  indicator: const BubbleTabIndicator(
                    indicatorHeight: 16.0,
                    indicatorColor: Colors.blueAccent,
                    tabBarIndicatorSize: TabBarIndicatorSize.tab,
                    indicatorRadius: 5,
                  ),
                ),
              ),
              Expanded(
                child: _buildTabPage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPage(BuildContext context) {
    List<Widget> pages = [];
    _appBarTitleList.asMap().forEach((int index, String value) {
      pages.add(TopSubPage(
        presenter: widget.presenters[index],
        tabIndex: index,
        prefixTitle: () {
          String retStr = "";
          if (index == 3) {
            retStr = _prefixNovaTitleHot;
          } else if (index == 4) {
            retStr = _prefixNovaTitlePopulary;
          }
          return retStr;
        }(),
        appBarTitle: value,
        reloadedController: _reloadedController,
      ));
    });

    return TabBarView(
      controller: _tabController,
      children: pages,
    );
  }

  List<Widget> _buildAppBarActionArea(BuildContext context) {
    return <Widget>[
      SizedBox(
          width: 45,
          height: 45,
          child: IconButton(
              padding: const EdgeInsets.all(0.0),
              onPressed: () {
                _reloadedController.add(TopSearchKeyItem(searchedKey: ''));
              },
              icon: const Icon(Icons.refresh_rounded))),
      SizedBox(
        width: MediaQuery.of(context).size.width <= 375 ? 0 : 25,
        height: 50,
      )
    ];
  }
}
