import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/widgets/nova_search_bar.dart';

class SearchPage {
  bool _searchIsEnabled = false;
  bool _isSearched = false;

  PreferredSizeWidget? buildAppBar(BuildContext context,
      {required String appBarTitle,
      bool automaticallyImplyLeading = false,
      Function(String)? searchAction,
      Function(bool)? cancelAction,
      Function()? openSearchAction,
      Function()? refreshAction}) {
    return !_searchIsEnabled
        ? AppBar(
            leadingWidth: 25,
            title: Text(appBarTitle),
            backgroundColor: ColorDef.appBarBackColor2,
            foregroundColor: ColorDef.appBarTitleColor,
            centerTitle: true,
            actions: _buildAppBarActionsArea(context,
                openSearchAction: openSearchAction,
                refreshAction: refreshAction),
          ) as PreferredSizeWidget?
        : NovaSearchBar(
            automaticallyImplyLeading: automaticallyImplyLeading,
            searchAction: (keyword) {
              _isSearched = true;
              searchAction?.call(keyword);
            },
            cancelAction: () {
              _searchIsEnabled = false;
              cancelAction?.call(_isSearched);
              _isSearched = false;
            });
  }

  List<Widget> _buildAppBarActionsArea(BuildContext context,
      {Function()? openSearchAction, Function()? refreshAction}) {
    return [
      SizedBox(
          width: 45,
          height: 45,
          child: IconButton(
              padding: const EdgeInsets.only(top: 5),
              onPressed: () {
                _searchIsEnabled = true;
                openSearchAction?.call();
              },
              icon: const Icon(Icons.search_rounded))),
      SizedBox(
          width: 45,
          height: 45,
          child: IconButton(
              padding: const EdgeInsets.only(top: 5),
              onPressed: refreshAction,
              icon: const Icon(Icons.refresh_rounded)))
    ];
  }
}
