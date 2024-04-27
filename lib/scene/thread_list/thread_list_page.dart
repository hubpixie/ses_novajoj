import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/root/search_page.dart';
import 'package:ses_novajoj/scene/thread_list/thread_sub_page.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_presenter.dart';

class ThreadListPage extends StatefulWidget {
  final List<ThreadListPresenter> presenters;
  const ThreadListPage({Key? key, required this.presenters}) : super(key: key);

  @override
  State<ThreadListPage> createState() => _ThreadListPageState();
}

class _ThreadListPageState extends State<ThreadListPage>
    with TickerProviderStateMixin {
  List<String> _tabNames = [];
  final Map<int, List<String>> _pickedTabsInfoList = {};

  double _scrollOffset = 0;
  bool _scrollTextStateChanged = false;
  TabController? _tabController;
  late ScrollController _scrollController;
  AnimationController? _animationController;

  // searchbar
  late String? _searchedUrl;
  final SearchPage _searchPage = SearchPage();
  String _currentSearchedKeyword = '';
  String _prevSearchedKeyword = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initTabNames(context);
    _tabController ??= TabController(length: _tabNames.length, vsync: this);

    return Scaffold(
        appBar: _searchPage.buildAppBar(context,
            appBarTitle: _buildAppBarTitleArea(context),
            automaticallyImplyLeading: false,
            bottomBar: PreferredSize(
                preferredSize: const Size.fromHeight(32.0),
                child: _buildAppBarTabArea(context)),
            searchAction: (keyword) {},
            cancelAction: (isSearched) {
              if (isSearched) {
                //   _reloadedController
                //       .add(TopSearchKeyItem(searchResultIsCleared: true));
              } else {
                setState(
                  () {},
                );
              }
              _currentSearchedKeyword = '';
            },
            openSearchAction: () => setState(
                  () {},
                ),
            refreshAction: () {
              // _reloadedController.add(
              //     TopSearchKeyItem(searchedKey: _currentSearchedKeyword));
            }),
        body: _buildTabPage(context));
  }

  // ignore: unused_element
  Widget _buildAppBarTitleArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(left: 0, right: 20),
      height: 30.0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 1, color: Colors.grey)],
            color: Colors.white,
            shape: BoxShape.rectangle),
        child: Container(),
      ),
    );
  }

  Widget _buildAppBarTabArea(BuildContext context) {
    List<Tab> tabs = [];
    for (final name in _tabNames) {
      tabs.add(Tab(
        child: Text(name),
      ));
    }
    _tabController ??= TabController(length: tabs.length, vsync: this);

    return TabBar(
        controller: _tabController,
        isScrollable: true,
        unselectedLabelColor: ColorDef.tabLabelColor.withOpacity(0.6),
        indicatorColor: ColorDef.tabLabelColor.withOpacity(0.4),
        labelColor: ColorDef.tabLabelColor,
        tabs: tabs);
  }

  Widget _buildTabPage(BuildContext context) {
    List<Widget> pages = [];
    _tabNames.asMap().forEach((int index, String value) {
      pages.add(ThreadSubPage(
          presenter: widget.presenters[index],
          tabIndex: index,
          appBarTitle: value));
    });

    return TabBarView(
      controller: _tabController,
      children: pages,
    );
  }

  // ignore: unused_element
  List<Widget> _buildAppBarActionArea(BuildContext context) {
    return <Widget>[
      SizedBox(
          width: 45,
          height: 45,
          child: IconButton(
              padding: const EdgeInsets.all(0.0),
              color: Colors.white,
              onPressed: () {
                // reload data
                //_loadData(isReloaded: true);
              },
              icon: const Icon(Icons.refresh_rounded))),
      SizedBox(
        width: MediaQuery.of(context).size.width <= 375 ? 0 : 25,
        height: 50,
      )
    ];
  }

  void _initTabNames(BuildContext context) {
    if (_tabNames.isEmpty) {
      _tabNames = <String>[
        UseL10n.of(context)?.threadRecommend ?? "",
        UseL10n.of(context)?.threadKidding ?? "",
        UseL10n.of(context)?.threadLifeStyle ?? "",
        UseL10n.of(context)?.threadChatIdly ?? "",
        UseL10n.of(context)?.threadMarriageLife ?? "",
        UseL10n.of(context)?.threadTalkHistory ?? "",
        UseL10n.of(context)?.threadEntertainment ?? "",
        UseL10n.of(context)?.threadTalkArmchair ?? "",
        UseL10n.of(context)?.threadEconomics ?? "",
        UseL10n.of(context)?.threadDissertation ?? "",
        UseL10n.of(context)?.threadGourmet ?? "",
        UseL10n.of(context)?.threadTravel ?? "",
      ];
    }
  }
}
