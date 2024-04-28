import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/root/search_page.dart';
import 'package:ses_novajoj/scene/thread_list/thread_sub_page.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_presenter.dart';

class ThreadListPage extends StatefulWidget {
  final List<ThreadListPresenter> presenters;
  final PageLoadingState pageLoadingState;
  const ThreadListPage(
      {Key? key, required this.presenters, required this.pageLoadingState})
      : super(key: key);

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
  StreamController<ThreadSubInfo>? _pickedInfoList;

  // searchbar
  late String? _searchedUrl;
  final SearchPage _searchPage = SearchPage();
  String _currentSearchedKeyword = '';
  String _prevSearchedKeyword = '';

  @override
  void initState() {
    super.initState();

    // init some variables
    _pickedInfoList = StreamController<ThreadSubInfo>.broadcast();

    _scrollController = ScrollController();
    Future.delayed(const Duration(milliseconds: 1500), () {
      int tabIndex = _tabController?.index ?? 0;
      if (tabIndex == 0) {
        _pickedTabsInfoList[tabIndex] = ["🟠${_tabNames[tabIndex]}"];
        setState(() {});
      }

      _tabController?.addListener(() {
        int tabIndex = _tabController?.index ?? 0;
        String firstText = "🟠${_tabNames[tabIndex]}";
        List<String> infos = _pickedTabsInfoList[tabIndex] ?? [];
        if (infos.isEmpty) {
          infos.add(firstText);
        }
        if (!infos.contains(firstText)) {
          infos.insert(0, firstText);
        }
        _pickedTabsInfoList[tabIndex] = infos;
        _scrollOffset = 0;
        setState(() {});
      });
    });
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
                preferredSize: const Size.fromHeight(40.0),
                child: _buildAppBarTabArea(context)),
            searchAction: (keyword) {
              //_prevPickedTitleList = _pickedTitleList;

              // _currentSearchedKeyword = keyword;
              // if (keyword.isNotEmpty) {
              //   _reloadedController
              //       .add(TopSearchKeyItem(searchedKey: keyword));
              // }
            },
            cancelAction: (isSearched) {
              if (isSearched) {
                //   _reloadedController
                //       .add(TopSearchKeyItem(searchResultIsCleared: true));
              } else {
                setState(
                  () {
                    Future.delayed(const Duration(milliseconds: 2000), () {
                      // add subInfo
                      ThreadSubInfo subInfo = ThreadSubInfo(
                          index: _tabController!.index,
                          infos:
                              _pickedTabsInfoList[_tabController?.index ?? 0] ??
                                  []);
                      _pickedInfoList?.add(subInfo);

                      // add animationController listner
                      _addListenerOntoAnimationController();
                    });
                  },
                );
              }
              _currentSearchedKeyword = '';
            },
            openSearchAction: () => setState(
                  () {
                    // remove animationController listner
                    _removeListenerFromAnimationController();
                  },
                ),
            refreshAction: () {
              // _reloadedController.add(
              //     TopSearchKeyItem(searchedKey: _currentSearchedKeyword));
            }),
        body: _buildTabPage(context));
  }

  void _addListenerOntoAnimationController() {
    if (_animationController != null) {
      return;
    }
    _scrollOffset = 0;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() {
        _scrollOffset += 20.0;
        if (_animationController!.isCompleted) {
          _animationController!.repeat();
          //_scrollOffset = 0;
        }
        if (!_scrollTextStateChanged) {
          _scrollTextStateChanged = true;
          setState(() {
            Future.delayed(const Duration(milliseconds: 2500), () {
              int tabIndex = _tabController?.index ?? 0;
              if ((_pickedTabsInfoList[tabIndex] ?? []).length <= 1) {
                _scrollOffset = 0.0;
              }
              try {
                _scrollController.jumpTo(_scrollOffset);
              } catch (error) {
                //log.severe("_scrollController.jumpTo error=$error");
                _scrollOffset = 0.0;
                // _scrollController.jumpTo(offset);
              }
            });
          });
        }
      });
    _animationController?.forward();
  }

  void _removeListenerFromAnimationController() {
    if (_animationController == null) {
      return;
    }
    if (_animationController!.isAnimating) {
      _animationController!.stop();
      _animationController!.dispose();
    }
    _animationController = null;
  }

  // ignore: unused_element
  Widget _buildAppBarTitleArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.only(left: 0, right: 20, bottom: 10),
      //alignment: Alignment.centerLeft,
      height: 40.0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 1, color: Colors.grey)],
            color: Colors.white,
            shape: BoxShape.rectangle),
        child: StreamBuilder<ThreadSubInfo>(
            stream: _pickedInfoList?.stream,
            builder: (context, snapshot) {
              int tabIndex = _tabController?.index ?? 0;
              String nameStr = "🟠${_tabNames[_tabController?.index ?? 0]}";

              if (!widget.pageLoadingState.isActive ||
                  snapshot.connectionState == ConnectionState.waiting ||
                  (_pickedTabsInfoList[_tabController?.index ?? 0] ?? [])
                      .isEmpty) {
                if (!widget.pageLoadingState.isActive) {
                  // remove animationController listner
                  _removeListenerFromAnimationController();
                }
                // return empty container
                _pickedTabsInfoList[tabIndex] = [nameStr];
                return Container();
              }
              if (_scrollTextStateChanged) {
                Future.delayed(const Duration(milliseconds: 2000), () {
                  _scrollTextStateChanged = false;
                });
              }

              // add animationController listner
              if (widget.pageLoadingState.isActive &&
                  _animationController == null) {
                _addListenerOntoAnimationController();
              }
              final data = snapshot.data;
              if (data is ThreadSubInfo) {
                ThreadSubInfo subInfo = data;
                List<String> infoList = _pickedTabsInfoList[tabIndex] ?? [];
                _pickedTabsInfoList[subInfo.index] = subInfo.infos;
                log.info(
                    "[${DateTime.now()}][2] infos.first = ${infoList.first},tabIndex = $tabIndex, length = ${infoList.length}");
                // return a listView
                return ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: infoList.length,
                    itemBuilder: (context, index) {
                      return Text(infoList[index],
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 16.0));
                    });
              } else {
                // return an error container
                return Container();
              }
            }),
      ),
    );
  }

  Widget _buildAppBarTitleArea2(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 70),
      height: 30.0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey)],
            color: Colors.white,
            shape: BoxShape.rectangle),
        child: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: const <Widget>[
            Text(" testA testB testC testD ",
                style: TextStyle(color: Colors.grey, fontSize: 18.0)),
            Text(" testA testB testC testD ",
                style: TextStyle(color: Colors.grey, fontSize: 18.0)),
          ],
        ),
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
        appBarTitle: value,
        pickedInfoList: _pickedInfoList,
      ));
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
