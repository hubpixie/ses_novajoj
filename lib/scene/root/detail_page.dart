import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/widgets/ext_web_view.dart';
import 'package:ses_novajoj/scene/widgets/confirm_dialog.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';

// enum DetailMenuItem { openOriginal, readComments, miscInfoSelect }

class DetailPage {
  Widget buildContentArea(BuildContext context,
      {dynamic detailItem, bool imageZommingEnabled = true}) {
    return ExtWebView(
      detailItem: detailItem,
      imageZoomingEnabled: imageZommingEnabled,
    );
  }

  List<Widget> buildAppBarActionArea(BuildContext context,
      {dynamic itemInfo,
      List<DetailMenuItem>? menuItems,
      List<void Function()?>? menuActions}) {
    final menuItems_ =
        menuItems ?? [DetailMenuItem.openOriginal, DetailMenuItem.readComments];
    return <Widget>[
      PopupMenuButton(
          // add icon, by default "3 dot" icon
          // icon: Icon(Icons.book)
          itemBuilder: (context) {
        List<PopupMenuItem<DetailMenuItem>> retMenus = [];
        for (var element in menuItems_) {
          int idx = menuItems_.indexOf(element);
          final action = (menuActions != null) ? menuActions[idx] : null;

          if (element == DetailMenuItem.openOriginal) {
            retMenus.add(
              PopupMenuItem<DetailMenuItem>(
                value: DetailMenuItem.openOriginal,
                child: Text(
                    UseL10n.of(context)?.detailPageMenuOpenOriginalPage ?? ''),
              ),
            );
          } else if (element == DetailMenuItem.readComments && action != null) {
            retMenus.add(
              PopupMenuItem<DetailMenuItem>(
                value: DetailMenuItem.readComments,
                child:
                    Text(UseL10n.of(context)?.detailPageMenuReadComments ?? ''),
              ),
            );
          } else if (element == DetailMenuItem.changeSettings &&
              action != null) {
            retMenus.add(
              PopupMenuItem<DetailMenuItem>(
                value: DetailMenuItem.changeSettings,
                child: Text(
                    UseL10n.of(context)?.detailPageMenuChangeMiscInfoSettings ??
                        ''),
              ),
            );
          } else if (element == DetailMenuItem.removeSettings &&
              action != null) {
            retMenus.add(
              PopupMenuItem<DetailMenuItem>(
                value: DetailMenuItem.removeSettings,
                child: Text(
                    UseL10n.of(context)?.detailPageMenuRemoveMiscInfoSettings ??
                        ''),
              ),
            );
          }
        }
        return retMenus;
      }, onSelected: (DetailMenuItem value) {
        int idx = menuItems_.indexOf(value);
        final action = (menuActions != null) ? menuActions[idx] : null;
        if (value == DetailMenuItem.openOriginal) {
          if (action != null) {
            action.call();
            return;
          }
          ExtWebView.openBrowser(context, url: itemInfo?.urlString);
          return;
        } else if (value == DetailMenuItem.changeSettings) {
          action?.call();
          return;
        } else if (value == DetailMenuItem.removeSettings) {
          ConfirmDialog().show(context,
              message: UseL10n.of(context)?.msgConfirmToDeleteSettings ?? '',
              buttonTitles: [
                UseL10n.of(context)?.cancelButtonTitle ?? '',
                UseL10n.of(context)?.deleteButtonTitle ?? ''
              ],
              actions: [
                () {
                  Navigator.of(context).pop();
                },
                () {
                  Navigator.of(context).pop();
                  action?.call();
                }
              ]);
          return;
        } else if (value == DetailMenuItem.readComments) {
          return;
        }
      }),
    ];
  }
}
