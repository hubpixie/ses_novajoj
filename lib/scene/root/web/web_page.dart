import 'package:flutter/material.dart';
//import 'package:ses_novajoj/foundation/log_util.dart';
//import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/root/web/web_presenter.dart';
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
  final WebPresenter presenter;
  const WebPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
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
          backgroundColor: ColorDef.appBarBackColor2,
          foregroundColor: ColorDef.appBarTitleColor,
          centerTitle: true,
          actions: _detailPage.buildAppBarActionArea(context,
              itemInfo: _itemInfo,
              menuItems:
                  _detailItem?.menuItems ?? [DetailMenuItem.openOriginal],
              menuActions: _detailItem?.menuActions),
        ),
        body: _detailPage.buildContentArea(context,
            detailItem: _detailItem,
            isWebDetail: true,
            imageZommingEnabled:
                (_detailItem?.htmlText.isNotEmpty ?? false) ? true : false,
            onImageLoad:
                (int srcIndex, List<dynamic> srcList, parentViewImage) {
          widget.presenter.eventViewImageLoader(context,
              appBarTitle: '',
              imageSrcIndex: srcIndex,
              imageSrcList: srcList,
              parentViewImage: parentViewImage, completeHandler: (index) {
            _detailPage.scrollController.scrollTo(index: index);
          });
        }, onInnerLink: (index, href, innerTitle) {
          _itemInfo?.innerLinkDetail?.call(href).then((htmlText) {
            _itemInfo?.isInnerLink = true;
            widget.presenter.eventSelectInnerDetail(context,
                appBarTitle: innerTitle,
                itemInfo: _itemInfo,
                htmlText: htmlText, completeHandler: () {
              if (_itemInfo?.isInnerLink ?? false) {
                log.info('jump to inner link detail!');
                _itemInfo?.urlString = _itemInfo!.previousUrlString!;
                _itemInfo?.previousUrlString = '';
                _itemInfo?.isInnerLink = false;
              }
            });
          });
        }));
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
