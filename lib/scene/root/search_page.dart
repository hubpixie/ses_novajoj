import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/widgets/nova_search_bar.dart';

class SearchPage {
  bool _searchIsEnabled = false;
  bool _isSearched = false;

  bool get isSearched => _isSearched;

  PreferredSizeWidget buildAppBar(BuildContext context,
      {required Widget appBarTitle,
      bool automaticallyImplyLeading = false,
      PreferredSizeWidget? bottomBar,
      Function(String)? searchAction,
      Function(bool)? cancelAction,
      Function()? openSearchAction,
      Function()? refreshAction}) {
    return PreferredSize(
        preferredSize: bottomBar == null
            ? const Size.fromHeight(56)
            : Size.fromHeight(bottomBar.preferredSize.height + 56),
        child: !_searchIsEnabled || searchAction == null
            ? AppBar(
                automaticallyImplyLeading: automaticallyImplyLeading,
                leadingWidth: 20,
                title: appBarTitle,
                backgroundColor: ColorDef.appBarBackColor2,
                foregroundColor: ColorDef.appBarTitleColor,
                centerTitle: true,
                bottom: bottomBar,
                actions: _buildAppBarActionsArea(context,
                    openSearchAction: openSearchAction,
                    refreshAction: refreshAction),
              )
            : NovaSearchBar(
                automaticallyImplyLeading: automaticallyImplyLeading,
                searchAction: (keyword) {
                  _isSearched = true;
                  searchAction.call(keyword);
                },
                cancelAction: () {
                  _searchIsEnabled = false;
                  cancelAction?.call(_isSearched);
                  _isSearched = false;
                },
                bottomBar: bottomBar));
  }

  List<Widget> _buildAppBarActionsArea(BuildContext context,
      {Function()? openSearchAction, Function()? refreshAction}) {
    List<Widget> widgets = [];
    if (openSearchAction != null) {
      widgets.add(SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
              padding: const EdgeInsets.only(top: 5),
              onPressed: () {
                _searchIsEnabled = true;
                openSearchAction.call();
              },
              icon: const Icon(Icons.search_rounded))));
    }
    if (refreshAction != null) {
      widgets.add(SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
              padding: const EdgeInsets.only(top: 3),
              onPressed: refreshAction,
              icon: const Icon(Icons.refresh_rounded))));
    }
    widgets.add(const SizedBox(width: 15));
    return widgets;
  }
}
