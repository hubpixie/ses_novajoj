import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/widgets/ext_web_view.dart';

enum _MenuItems { openOriginal, readComments }

class DetailPage {
  Widget buildContentArea(BuildContext context, {dynamic detailItem}) {
    return ExtWebView(detailItem: detailItem);
  }

  List<Widget> buildAppBarActionArea(BuildContext context, {dynamic itemInfo}) {
    return <Widget>[
      PopupMenuButton(
          // add icon, by default "3 dot" icon
          // icon: Icon(Icons.book)
          itemBuilder: (context) {
        return [
          PopupMenuItem<_MenuItems>(
            value: _MenuItems.openOriginal,
            child:
                Text(UseL10n.of(context)?.detailPageMenuOpenOriginalPage ?? ''),
          ),
          PopupMenuItem<_MenuItems>(
            value: _MenuItems.readComments,
            child: Text(UseL10n.of(context)?.detailPageMenuReadComments ?? ''),
          ),
        ];
      }, onSelected: (_MenuItems value) {
        if (value == _MenuItems.openOriginal) {
          ExtWebView.openBrowser(context, url: itemInfo?.urlString);
          return;
        } else if (value == _MenuItems.readComments) {
          return;
        }
      }),
    ];
  }
}
