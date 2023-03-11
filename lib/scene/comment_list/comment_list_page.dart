import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/comment_list/comment_list_presenter.dart';
import 'package:ses_novajoj/scene/comment_list/comment_list_presenter_output.dart';

class CommentListPage extends StatefulWidget {
  final CommentListPresenter presenter;
  const CommentListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<CommentListPage> createState() => _CommentListPageState();
}

enum _CommentMenuItem {
  fetchLatestInfo,
  fetchEarliestInfo,
  sortByStepAsc,
  sortByStepDesc,
  defaultFontSize,
  zoominFont,
  zoomoutFont,
}

class _CommentListPageState extends State<CommentListPage> {
  static const String _kStepWord = '\u697C';
  static const double _kCommentItemHeaderDefaultFontSize = 14;
  static const double _kCommentItemBodyDefaultFontSize = 16;
  bool _pageLoadIsFirst = true;

  final ScrollController _scrollController = ScrollController();
  SnackBar? _snackBar;

  final Map<int, double> _cardHeightDic = {};
  late String _appBarTitle;
  Map? _parameters;
  NovaItemInfo? _itemInfo;
  NovaItemInfo? _newItemInfo;
  List<NovaComment>? _commentList;
  CommentMenuSetting? _commentMenuSetting;
  double _commentItemHeaderFontSize = _kCommentItemHeaderDefaultFontSize;
  double _commentItemBodyFontSize = _kCommentItemBodyDefaultFontSize;

  @override
  void initState() {
    super.initState();
    // fetch commentNenuSetting
    widget.presenter.eventViewMenuItemSetting().then((value) {
      _commentMenuSetting = value;
      if (_commentMenuSetting != null) {
        if (_commentMenuSetting!.defaultFontSizeIsEnabled) {
          _commentItemHeaderFontSize = _kCommentItemHeaderDefaultFontSize;
          _commentItemBodyFontSize = _kCommentItemBodyDefaultFontSize;
        } else {
          _commentItemHeaderFontSize = _commentMenuSetting!.itemHeaderFontSize;
          _commentItemBodyFontSize = _commentMenuSetting!.itemBodyFontSize;
        }
        // TODO: sort - 1
        //
      } else {
        // TODO: sort - 2
        _commentMenuSetting = CommentMenuSetting();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter(context);

    return WillPopScope(
        onWillPop: () {
          if (_snackBar != null) {
            // dismiss snackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _snackBar = null;
          }
          // save menuSetting
          if (_commentMenuSetting != null) {
            widget.presenter
                .eventUpdateMenuItemSetting(newValue: _commentMenuSetting!);
          }
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle),
            backgroundColor: ColorDef.appBarBackColor2,
            foregroundColor: ColorDef.appBarTitleColor,
            centerTitle: true,
            actions: _buildAppBarMenus(context),
          ),
          body: _buildBody(context),
        ));
  }

  List<Widget> _buildAppBarMenus(BuildContext context) {
    return <Widget>[
      PopupMenuButton<_CommentMenuItem>(
        itemBuilder: (context_) {
          // List<PopupMenuEntry<_CommentMenuItem>> menuItems_ = [];
          if (_commentList?.isEmpty ?? true) {
            return [];
          }
          return <PopupMenuEntry<_CommentMenuItem>>[
            PopupMenuItem(
                enabled: false,
                value: _CommentMenuItem.fetchEarliestInfo,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuFetchLatestInfo ??
                        '')),
            PopupMenuItem(
                enabled: false,
                value: _CommentMenuItem.fetchEarliestInfo,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuFetchEarliestInfo ??
                        '')),
            const PopupMenuDivider(height: 8),
            PopupMenuItem(
                value: _CommentMenuItem.sortByStepAsc,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuStepAscend ?? '')),
            PopupMenuItem(
                value: _CommentMenuItem.sortByStepDesc,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuStepDwscend ?? '')),
            const PopupMenuDivider(height: 8),
            PopupMenuItem(
                value: _CommentMenuItem.defaultFontSize,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuDefaultFontSize ??
                        '')),
            PopupMenuItem(
                value: _CommentMenuItem.zoominFont,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuZoominFont ?? '')),
            PopupMenuItem(
                value: _CommentMenuItem.zoomoutFont,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuZoomoutFont ?? '')),
          ];
        },
        onSelected: (_CommentMenuItem value) {
          // print onSelected
          switch (value) {
            case _CommentMenuItem.fetchLatestInfo:
              break;
            case _CommentMenuItem.fetchEarliestInfo:
              break;
            case _CommentMenuItem.sortByStepAsc:
              // setState(() {
              //   _commentList?.sort((a, b) => NumberUtil()
              //       .parseInt(string: a.step)!
              //       .compareTo(NumberUtil().parseInt(string: b.step)!));
              // });
              _commentMenuSetting?.sortingByStepAscIsEnabled = true;
              widget.presenter.eventViewSort(
                  input: CommentListPresenterInput(
                      itemInfo: _newItemInfo!, sortingByStepAsc: true));
              break;
            case _CommentMenuItem.sortByStepDesc:
              _commentMenuSetting?.sortingByStepAscIsEnabled = false;
              widget.presenter.eventViewSort(
                  input: CommentListPresenterInput(
                      itemInfo: _newItemInfo!, sortingByStepAsc: false));
              break;
            case _CommentMenuItem.defaultFontSize:
              _commentMenuSetting?.defaultFontSizeIsEnabled = true;
              setState(() {
                _commentItemHeaderFontSize = _kCommentItemHeaderDefaultFontSize;
                _commentItemBodyFontSize = _kCommentItemBodyDefaultFontSize;
              });
              break;
            case _CommentMenuItem.zoomoutFont:
              double headFontSize = _commentItemHeaderFontSize;
              double bodyFontSize = _commentItemBodyFontSize;
              headFontSize -= 2;
              if (headFontSize < _kCommentItemHeaderDefaultFontSize) {
                headFontSize = _kCommentItemHeaderDefaultFontSize;
              }
              bodyFontSize -= 3;
              if (bodyFontSize < _kCommentItemBodyDefaultFontSize) {
                bodyFontSize = _kCommentItemBodyDefaultFontSize;
              }

              _commentMenuSetting?.defaultFontSizeIsEnabled = false;
              _commentMenuSetting?.itemHeaderFontSize = headFontSize;
              _commentMenuSetting?.itemBodyFontSize = bodyFontSize;
              setState(() {
                _commentItemHeaderFontSize = headFontSize;
                _commentItemBodyFontSize = bodyFontSize;
              });
              break;
            case _CommentMenuItem.zoominFont:
              double headFontSize = _commentItemHeaderFontSize;
              double bodyFontSize = _commentItemBodyFontSize;
              headFontSize += 2;
              if (headFontSize > 22) {
                headFontSize = 22;
              }
              bodyFontSize += 3;
              if (bodyFontSize > 28) {
                bodyFontSize = 28;
              }

              _commentMenuSetting?.defaultFontSizeIsEnabled = false;
              _commentMenuSetting?.itemHeaderFontSize = headFontSize;
              _commentMenuSetting?.itemBodyFontSize = bodyFontSize;

              setState(() {
                _commentItemHeaderFontSize = headFontSize;
                _commentItemBodyFontSize = bodyFontSize;
              });
              break;
          }
        },
      )
    ];
  }

  Widget _buildBody(BuildContext context) {
    return BlocProvider<CommentListPresenter>(
      bloc: widget.presenter,
      child: StreamBuilder<CommentListPresenterOutput>(
          stream: widget.presenter.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowCommentListPageModel) {
              if (data.error == null) {
                _newItemInfo = data.viewModel?.itemInfo;
                _commentList = _newItemInfo?.comments;

                return _buildBodyItemListArea(context, comments: _commentList);
              } else {
                return Text("${data.error}");
              }
            } else {
              assert(false, "unknown event $data");
              return Container(color: Colors.red);
            }
          }),
    );
  }

  Widget _buildBodyItemListArea(BuildContext context,
      {List<NovaComment>? comments}) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: comments?.length,
        padding: const EdgeInsets.only(top: 10.0),
        itemBuilder: (context, index) {
          return Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child:
                  _buildRowCardArea(context, comments: comments, index: index));
        });
  }

  Widget _buildRowCardArea(BuildContext context,
      {List<NovaComment>? comments, int index = 0}) {
    final columnKey = GlobalKey();
    NovaComment? novaComment = comments?[index];

    Card card = Card(
        key: columnKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    '[${novaComment?.step}$_kStepWord]',
                    style: TextStyle(fontSize: _commentItemHeaderFontSize),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                      child: SizedBox(
                          width: 120,
                          child: Text('${novaComment?.author}',
                              style: TextStyle(
                                  fontSize: _commentItemHeaderFontSize)))),
                  //const SizedBox(width: 6),
                  Flexible(
                      child: SizedBox(
                          width: 200,
                          child: Text('${novaComment?.createAt}',
                              style: TextStyle(
                                  fontSize: _commentItemHeaderFontSize))))
                ],
              )),
          Flexible(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 1000,
                    child:
                        _buildContentArea(context, novaComment: novaComment))),
          )
        ]));
    Future.delayed(const Duration(milliseconds: 100), () {
      _calcCardSizes(columnKey, index);
    });
    return card;
  }

  Widget _buildContentArea(BuildContext context, {NovaComment? novaComment}) {
    const String replyCd = '\u21b1';
    String plainStr = novaComment?.plainString ?? '';
    double currOffset = _calcScrollOffset(novaComment: novaComment);

    String contentStr = () {
      String retStr = '';

      novaComment?.replyList?.forEach((elem) {
        retStr += '\n$replyCd [${elem.step}$_kStepWord] ${elem.plainString}';
      });
      retStr = retStr.isEmpty
          ? plainStr
          : (retStr.contains(plainStr)
              ? retStr.substring(1)
              : '$plainStr\n$retStr');
      return retStr;
    }();

    if (contentStr.contains(RegExp(r'<div|<img|<p|<table|<span'))) {
      contentStr = contentStr.replaceFirst('\u56DE\u590D',
          '<span style="font-size:150%;color:#FF6E40;">$replyCd</span>');
      return Html(
          data: '<div>$contentStr</div>',
          style: {"div": Style(fontSize: FontSize(_commentItemBodyFontSize))});
    } else {
      if (contentStr.isEmpty) {
        return Text(UseL10n.of(context)?.commentListAreaNoContentString ?? '',
            style: TextStyle(
                fontSize: _commentItemBodyFontSize,
                color: ColorDef.illeagalTextColor));
      }
      List<TextSpan> textSpans = [];
      if (!contentStr.contains('$replyCd ')) {
        textSpans.add(TextSpan(
            text: plainStr,
            style: TextStyle(
                fontSize: _commentItemBodyFontSize,
                color: ColorDef.generalTextColor)));
      } else {
        novaComment?.replyList?.forEach((elem) {
          textSpans.add(const TextSpan(
              text: replyCd,
              style: TextStyle(
                  fontSize: _kCommentItemBodyDefaultFontSize + 6,
                  height: 0.7,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepOrangeAccent)));
          textSpans.add(TextSpan(
              text: ' [',
              style: TextStyle(
                  fontSize: _commentItemBodyFontSize,
                  color: ColorDef.generalTextColor)));
          textSpans.add(TextSpan(
            text: '${elem.step}$_kStepWord',
            style: TextStyle(
                fontSize: _commentItemBodyFontSize, color: ColorDef.linkColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                double targetOffset = _calcScrollOffset(novaComment: elem);
                _scrollController.animateTo(
                  targetOffset,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                );

                if (_snackBar != null) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _snackBar = null;
                }
                final snackBar = SnackBar(
                  content: Text(
                    'Go back to Step ${novaComment.step}',
                  ),
                  duration: const Duration(seconds: 60),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {
                      _scrollController.animateTo(
                        currOffset,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                );
                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                _snackBar = snackBar;
              },
          ));
          textSpans.add(TextSpan(
              text: ']: ',
              style: TextStyle(
                  fontSize: _commentItemBodyFontSize,
                  color: ColorDef.generalTextColor)));
          textSpans.add(TextSpan(
              text: elem.plainString,
              style: TextStyle(
                  fontSize: _commentItemBodyFontSize,
                  color: ColorDef.generalTextColor)));
        });
      }
      return RichText(text: TextSpan(children: textSpans));
    }
  }

  void _calcCardSizes(GlobalKey key, int index) async {
    if (key.currentContext != null) {
      Size? size = key.currentContext?.size;
      final height = size?.height ?? 50;
      _cardHeightDic[index] = height;
    }
  }

  double _calcScrollOffset({NovaComment? novaComment}) {
    double offset = 0;
    for (int idx = 0; idx < _cardHeightDic.length; idx++) {
      offset += _cardHeightDic[idx] ?? 0;
      if ('${idx + 2}' == novaComment?.step) {
        offset += 10;
        offset = offset > _scrollController.position.maxScrollExtent
            ? _scrollController.position.maxScrollExtent
            : offset;
        break;
      }
    }
    return offset;
  }

  void _parseRouteParameter(BuildContext context) {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      //
      // get page paratmers via ModalRoute
      //
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      _appBarTitle = UseL10n.of(context)?.commentListAreaTitle ?? '';
      _itemInfo = _parameters?[CommentListParamKeys.itemInfo] as NovaItemInfo?;

      //
      // FA
      //
      if ((_parameters?[TopDetailParamKeys.source] as String? ?? '') ==
          ScreenRouteName.tabs.name) {
        // send viewEvent
        FirebaseUtil().sendViewEvent(route: AnalyticsRoute.commentList);
      }

      // fetch data
      _loadData();
    }
  }

  void _loadData() {
    if (_itemInfo != null) {
      widget.presenter.eventViewReady(
          input: CommentListPresenterInput(itemInfo: _itemInfo!));
    } else {
      log.warning('bbs_detail_page: parameter is error!');
    }
  }
}
