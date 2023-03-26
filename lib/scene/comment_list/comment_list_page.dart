import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
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

  late AutoScrollController _scrollController;
  SnackBar? _snackBar;
  int _currentPageIndex = 1;
  int _prevPageIndex = -1;
  String _fromStep = "";
  String _toStep = "";
  double _targetOffset = -1;
  bool _topRowIsEnabled = false;

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

    // init scrollController
    _scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

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
      } else {
        _commentMenuSetting = CommentMenuSetting();
      }
      _loadData();
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
                enabled: !_commentMenuSetting!.sortingByStepAscIsEnabled,
                value: _CommentMenuItem.fetchLatestInfo,
                child: Text(
                    UseL10n.of(context_)?.commentListMenuFetchLatestInfo ??
                        '')),
            PopupMenuItem(
                enabled: _commentMenuSetting!.sortingByStepAscIsEnabled,
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
              _topRowIsEnabled = true;
              _commentMenuSetting?.latestInfoIsEnabled = true;
              _currentPageIndex = 1;
              _loadData();
              break;
            case _CommentMenuItem.fetchEarliestInfo:
              _topRowIsEnabled = true;
              _commentMenuSetting?.latestInfoIsEnabled = false;
              _currentPageIndex = 1;
              _loadData();
              break;
            case _CommentMenuItem.sortByStepAsc:
              _topRowIsEnabled = false;
              _commentMenuSetting?.sortingByStepAscIsEnabled = true;
              widget.presenter.eventViewSort(
                  input: CommentListPresenterInput(
                      itemInfo: _newItemInfo!, sortingByStepAsc: true));
              break;
            case _CommentMenuItem.sortByStepDesc:
              _topRowIsEnabled = false;
              _commentMenuSetting?.sortingByStepAscIsEnabled = false;
              widget.presenter.eventViewSort(
                  input: CommentListPresenterInput(
                      itemInfo: _newItemInfo!, sortingByStepAsc: false));
              break;
            case _CommentMenuItem.defaultFontSize:
              _topRowIsEnabled = false;
              _commentMenuSetting?.defaultFontSizeIsEnabled = true;
              setState(() {
                _commentItemHeaderFontSize = _kCommentItemHeaderDefaultFontSize;
                _commentItemBodyFontSize = _kCommentItemBodyDefaultFontSize;
              });
              break;
            case _CommentMenuItem.zoomoutFont:
              _topRowIsEnabled = false;
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
              _topRowIsEnabled = false;
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
    Future.delayed((const Duration(milliseconds: 100)), () {
      _scrollToTargetPageAndRowIfNeed(_commentList,
          fromStep: _fromStep, toStep: _toStep, targetOffset: _targetOffset);
      _toStep = '';
    });

    final itemCnt = comments?.length ?? 0;
    final lastComment = comments?.last;

    return ListView.builder(
        controller: _scrollController,
        itemCount: (comments?.length ?? 0) + 1,
        padding: const EdgeInsets.only(top: 10.0),
        itemBuilder: (context, index) {
          if (lastComment!.pageCount >= 1 && index == itemCnt) {
            if (lastComment.pageCount == 1) {
              return const SizedBox(height: 0);
            }
            return Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: _buildPagingArea(context, novaComment: lastComment));
          }
          return AutoScrollTag(
              key: ValueKey(index),
              controller: _scrollController,
              index: index,
              child: Container(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: _buildRowCardArea(context,
                      comments: comments, index: index)));
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
    return card;
  }

  Widget _buildContentArea(BuildContext context, {NovaComment? novaComment}) {
    const String replyCd = '\u21b1';
    String plainStr = novaComment?.plainString ?? '';

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
                // if scrollTarget pageNumber  is not the current pageNumber, and call loadData()
                _fromStep = novaComment.step;
                _prevPageIndex = _currentPageIndex;
                _toStep = elem.step;
                _currentPageIndex = elem.pageNumber;
                _targetOffset = _scrollController.position.pixels;

                if (_currentPageIndex != _prevPageIndex) {
                  // load data if need
                  _loadData();
                  return;
                }

                // Otherwise directly scroll to destination row.
                // back to `offset` position.
                _scrollToTargetPageAndRowIfNeed(_commentList,
                    fromStep: _fromStep,
                    toStep: _toStep,
                    targetOffset: _scrollController.position.pixels);
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

  Widget _buildPagingArea(BuildContext context,
      {required NovaComment novaComment}) {
    Widget _makeIconButton(IconData? iconData,
        {required int targetPageIndex, required int pageCnt}) {
      return SizedBox(
          height: 35,
          width: 35,
          child: IconButton(
              iconSize: 35,
              padding: const EdgeInsets.only(left: 5),
              onPressed: (targetPageIndex < 1 || targetPageIndex > pageCnt)
                  ? null
                  : () {
                      _currentPageIndex = targetPageIndex;
                      _loadData();
                    },
              icon: Icon(iconData)));
    }

    final pageNum = novaComment.pageNumber;
    final pageCnt = novaComment.pageCount;

    return Card(
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 10),
            _makeIconButton(Icons.first_page,
                targetPageIndex: (pageNum > 1 && pageNum <= pageCnt) ? 1 : -1,
                pageCnt: pageCnt),
            const Spacer(),
            _makeIconButton(Icons.chevron_left,
                targetPageIndex: pageNum - 1, pageCnt: pageCnt),
            const Spacer(flex: 2),
            Text('$pageNum/$pageCnt'),
            const Spacer(flex: 1),
            _makeIconButton(Icons.chevron_right,
                targetPageIndex: pageNum + 1, pageCnt: pageCnt),
            const Spacer(),
            _makeIconButton(Icons.last_page,
                targetPageIndex:
                    (pageNum >= 1 && pageNum < pageCnt) ? pageCnt : -1,
                pageCnt: pageCnt),
            const Spacer(flex: 5),
            SizedBox(
                height: 25,
                width: 25,
                child: IconButton(
                    iconSize: 25,
                    padding: const EdgeInsets.only(left: 5),
                    onPressed: () {
                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    icon: const Icon(Icons.arrow_circle_up))),
            const Spacer(flex: 5)
          ],
        ));
  }

  void _scrollToTargetPageAndRowIfNeed(List<NovaComment>? comments,
      {required String fromStep,
      required String toStep,
      required double targetOffset}) {
    if (toStep.isNotEmpty) {
      int idx = comments?.map((e) => e.step).toList().indexOf(_toStep) ?? -1;
      if (idx >= 0) {
        if (fromStep.isNotEmpty) {
          _scrollController.scrollToIndex(idx,
              preferPosition: AutoScrollPosition.begin,
              duration: const Duration(milliseconds: 300));
        } else {
          // back to targetOffset
          _scrollController.animateTo(targetOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linearToEaseOut);
        }
      }

      // back to `fromStep` position.
      if (fromStep.isNotEmpty) {
        int idx = comments?.map((e) => e.step).toList().indexOf(fromStep) ?? -1;
        _currentPageIndex = _prevPageIndex;
        if (idx < 0) {
          _prevPageIndex = -1;
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          _showSnackBarWhenGoingBack(fromStep: fromStep, offset: targetOffset);
        });
      }
    } else {
      if (_topRowIsEnabled) {
        _topRowIsEnabled = false;
        _scrollController.scrollToIndex(0,
            preferPosition: AutoScrollPosition.begin,
            duration: const Duration(milliseconds: 300));
      }
    }
  }

  void _showSnackBarWhenGoingBack(
      {required String fromStep, required double offset}) {
    // create snackBar
    if (_snackBar != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _snackBar = null;
    }
    final snackBar = SnackBar(
      content: Text(
        'Go back to Step $fromStep',
      ),
      duration: const Duration(seconds: 60),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          _toStep = fromStep;
          _fromStep = '';
          _targetOffset = offset;
          if (_currentPageIndex != _prevPageIndex) {
            // Firstly jump previous page using loadData()
            //

            _loadData();
            return;
          }

          // back to `offset` position.
          _scrollController.animateTo(offset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linearToEaseOut);
        },
      ),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _snackBar = snackBar;
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
    }
  }

  void _loadData() {
    if (_itemInfo != null) {
      widget.presenter.eventViewReady(
          input: CommentListPresenterInput(
              itemInfo: _itemInfo!,
              targetPageIndex: _currentPageIndex,
              latestInfoIsEnabled: _commentMenuSetting!.latestInfoIsEnabled,
              sortingByStepAsc:
                  _commentMenuSetting!.sortingByStepAscIsEnabled));
    } else {
      log.warning('bbs_detail_page: parameter is error!');
    }
  }
}
