import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/widgets/ext_web_view.dart';

enum DetailMenuItem { openOriginal, readComments }

class DetailPage {
  Widget buildContentArea(BuildContext context,
      {dynamic detailItem, bool imageZommingEnabled = true}) {
    return ExtWebView(
      detailItem: detailItem,
      imageZoomingEnabled: imageZommingEnabled,
    );
  }

  List<Widget> buildAppBarActionArea(BuildContext context,
      {dynamic itemInfo, List<DetailMenuItem>? menuItems}) {
    final menuItems_ =
        menuItems ?? [DetailMenuItem.openOriginal, DetailMenuItem.readComments];
    return <Widget>[
      PopupMenuButton(
          // add icon, by default "3 dot" icon
          // icon: Icon(Icons.book)
          itemBuilder: (context) {
        List<PopupMenuItem<DetailMenuItem>> retMenus = [];
        for (var element in menuItems_) {
          if (element == DetailMenuItem.openOriginal) {
            retMenus.add(
              PopupMenuItem<DetailMenuItem>(
                value: DetailMenuItem.openOriginal,
                child: Text(
                    UseL10n.of(context)?.detailPageMenuOpenOriginalPage ?? ''),
              ),
            );
          } else if (element == DetailMenuItem.readComments) {
            retMenus.add(
              PopupMenuItem<DetailMenuItem>(
                value: DetailMenuItem.readComments,
                child:
                    Text(UseL10n.of(context)?.detailPageMenuReadComments ?? ''),
              ),
            );
          }
        }
        return retMenus;
      }, onSelected: (DetailMenuItem value) {
        if (value == DetailMenuItem.openOriginal) {
          ExtWebView.openBrowser(context, url: itemInfo?.urlString);
          return;
        } else if (value == DetailMenuItem.readComments) {
          return;
        }
      }),
    ];
  }
}
