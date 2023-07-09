import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/root/detail_page.dart';
import 'package:ses_novajoj/scene/bbs_detail/bbs_detail_presenter.dart';
import 'package:ses_novajoj/scene/bbs_detail/bbs_detail_presenter_output.dart';

import 'package:ses_novajoj/scene/widgets/error_view.dart';

class BbsDetailPage extends StatefulWidget {
  final BbsDetailPresenter presenter;
  const BbsDetailPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<BbsDetailPage> createState() => _BbsDetailPageState();
}

class _BbsDetailPageState extends State<BbsDetailPage> {
  bool _pageLoadIsFirst = true;

  late String _appBarTitle;
  late DetailPage _detailPage;
  Map? _parameters;
  NovaItemInfo? _itemInfo;
  String? _htmlText;

  @override
  void initState() {
    super.initState();
    _detailPage = DetailPage();
    _htmlText = '';
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
        actions: _detailPage
            .buildAppBarActionArea(context, itemInfo: _itemInfo, menuItems: [
          DetailMenuItem.openOriginal,
          DetailMenuItem.favorite,
          DetailMenuItem.readComments
        ], menuActions: [
          null,
          () {
            if (_htmlText == null || _htmlText!.isEmpty) {
              return;
            }
            widget.presenter.eventSaveBookmark(
                input: BbsDetailPresenterInput(
                    itemInfo: _itemInfo!, htmlText: _htmlText!));
          },
          () {
            widget.presenter.eventViewCommentList(context,
                appBarTitle: '', itemInfo: _itemInfo);
          }
        ]),
      ),
      body: BlocProvider<BbsDetailPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<BbsDetailPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowBbsDetailPageModel) {
                if (data.error == null) {
                  _htmlText = data.viewModel?.htmlText;
                  _itemInfo = data.viewModel?.itemInfo;
                  return Column(children: [
                    _detailPage.buildContentArea(context,
                        detailItem: data.viewModel, onImageLoad: (int srcIndex,
                            List<dynamic> srcList, parentViewImage) {
                      widget.presenter.eventViewImageLoader(context,
                          appBarTitle: '',
                          imageSrcIndex: srcIndex,
                          imageSrcList: srcList,
                          parentViewImage: parentViewImage,
                          completeHandler: (index) {
                        _detailPage.scrollController.scrollTo(index: index);
                      });
                    }, onInnerLink: (index, href, innerTitle) {
                      _itemInfo?.previousUrlString = _itemInfo?.urlString;
                      _itemInfo?.urlString = href;
                      _itemInfo?.isInnerLink = true;
                      widget.presenter.eventSelectInnerDetail(context,
                          appBarTitle: innerTitle,
                          itemInfo: _itemInfo, completeHandler: () {
                        if (_itemInfo?.isInnerLink ?? false) {
                          log.info('jump to inner link detail!');
                          _itemInfo?.urlString = _itemInfo!.previousUrlString!;
                          _itemInfo?.previousUrlString = '';
                          _itemInfo?.isInnerLink = false;
                        }
                        //_detailPage.scrollController.scrollTo(index: index);
                      });
                    })
                  ]);
                } else {
                  return ErrorView(
                    message: UseL10n.localizedTextWithError(context,
                        error: data.error),
                    onFirstButtonTap: data.error?.type == AppErrorType.network
                        ? () {
                            _loadData();
                            setState(() {});
                          }
                        : null,
                  );
                }
              } else {
                assert(false, "unknown event $data");
                return Container(color: Colors.red);
              }
            }),
      ),
    );
  }

  void _parseRouteParameter() {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      //
      // get page paratmers via ModalRoute
      //
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      _appBarTitle =
          _parameters?[BbsDetailParamKeys.appBarTitle] as String? ?? '';
      _itemInfo = _parameters?[BbsDetailParamKeys.itemInfo] as NovaItemInfo?;

      //
      // FA
      //
      if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
          ScreenRouteName.tabs.name) {
        // send viewEvent
        FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsDetail);
      }

      // fetch data
      _loadData();
    }
  }

  void _loadData() {
    if (_itemInfo != null) {
      widget.presenter
          .eventViewReady(input: BbsDetailPresenterInput(itemInfo: _itemInfo!));
    } else {
      log.warning('bbs_detail_page: parameter is error!');
    }
  }
}
