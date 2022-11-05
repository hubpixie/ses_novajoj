import 'package:flutter/material.dart';
//import 'package:ses_novajoj/foundation/log_util.dart';
//import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
//import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/root/detail_page.dart';

class WebPageDetailItem {
  NovaItemInfo itemInfo;
  String htmlText;
  List<DetailMenuItem>? menuItems;
  List<void Function()?>? menuActions;

  WebPageDetailItem(
      {required this.itemInfo,
      required this.htmlText,
      this.menuItems,
      this.menuActions});
}

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  bool _pageLoadIsFirst = true;

  late String _appBarTitle;
  late DetailPage _detailPage;
  Map? _parameters;
  NovaItemInfo? _itemInfo;
  WebPageDetailItem? _detailItem;

  @override
  void initState() {
    super.initState();
    _detailPage = DetailPage();
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
          backgroundColor: const Color(0xFF1B80F3),
          centerTitle: true,
          actions: _detailPage.buildAppBarActionArea(context,
              itemInfo: _itemInfo,
              menuItems:
                  _detailItem?.menuItems ?? [DetailMenuItem.openOriginal],
              menuActions: _detailItem?.menuActions),
        ),
        body: _detailPage.buildContentArea(context,
            detailItem: _detailItem,
            imageZommingEnabled:
                (_detailItem?.htmlText.isNotEmpty ?? false) ? true : false));
  }

  void _parseRouteParameter() {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      //
      // get page paratmers via ModalRoute
      //
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      _appBarTitle =
          _parameters?[WebPageParamKeys.appBarTitle] as String? ?? '';
      _itemInfo = _parameters?[WebPageParamKeys.itemInfo] as NovaItemInfo?;
      //
      // WebPageDetailItem
      //
      if (_itemInfo != null) {
        _detailItem = WebPageDetailItem(
            itemInfo: _itemInfo!,
            htmlText: _parameters?[WebPageParamKeys.htmlText] ?? '',
            menuItems: _parameters?[WebPageParamKeys.menuItems],
            menuActions: _parameters?[WebPageParamKeys.menuActions]);
      }
    }
  }
}
