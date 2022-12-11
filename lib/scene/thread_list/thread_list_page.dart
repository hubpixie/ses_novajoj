import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/thread_list/thread_sub_page.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/thread_list/thread_list_presenter.dart';

class ThreadListPage extends StatefulWidget {
  final List<ThreadListPresenter> presenters;
  const ThreadListPage({Key? key, required this.presenters}) : super(key: key);

  @override
  State<ThreadListPage> createState() => _ThreadListPageState();
}

class _ThreadListPageState extends State<ThreadListPage> {
  List<String> _tabNames = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initTabNames(context);

    return DefaultTabController(
      length: _tabNames.length,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B80F3),
            automaticallyImplyLeading: false,
            leading: const SizedBox(width: 0),
            centerTitle: false,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.0),
                child: _buildAppBarTabArea(context)),
            titleSpacing: 0,
            leadingWidth: 10,
          ),
          body: _buildTabPage(context)),
    );
  }

  // ignore: unused_element
  Widget _buildAppBarTitleArea(BuildContext context) {
    return SizedBox(
        width: 265,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 125,
              height: 35,
            ),
            SizedBox(
                width: 140,
                height: 35,
                child: IconButton(
                    padding: const EdgeInsets.only(left: 5),
                    onPressed: null,
                    icon: Text(
                        UseL10n.of(context)?.hotThreadListAppBarTitle ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ));
  }

  Widget _buildAppBarTabArea(BuildContext context) {
    List<Tab> tabs = [];
    for (final name in _tabNames) {
      tabs.add(Tab(
        child: Text(name),
      ));
    }

    return TabBar(
        isScrollable: true,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: Colors.white,
        tabs: tabs);
  }

  Widget _buildTabPage(BuildContext context) {
    List<Widget> pages = [];
    _tabNames.asMap().forEach((int index, String value) {
      pages.add(ThreadSubPage(
        presenter: widget.presenters[index],
        tabIndex: index,
        appBarTitle: value,
      ));
    });

    return TabBarView(
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
