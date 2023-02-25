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

class _CommentListPageState extends State<CommentListPage> {
  static const String kStepWord = '\u697C';
  bool _pageLoadIsFirst = true;

  final ScrollController _scrollController = ScrollController();
  SnackBar? _snackBar;
  final Map<int, double> _cardHeightDic = {};
  late String _appBarTitle;
  Map? _parameters;
  NovaItemInfo? _itemInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter(context);

    return WillPopScope(
        onWillPop: () {
          if (_snackBar != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _snackBar = null;
          }
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle),
            backgroundColor: ColorDef.appBarBackColor2,
            foregroundColor: ColorDef.appBarTitleColor,
            centerTitle: true,
          ),
          body: BlocProvider<CommentListPresenter>(
            bloc: widget.presenter,
            child: StreamBuilder<CommentListPresenterOutput>(
                stream: widget.presenter.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: Colors.amber,
                            backgroundColor: Colors.grey[850]));
                  }
                  final data = snapshot.data;
                  if (data is ShowCommentListPageModel) {
                    if (data.error == null) {
                      final commentList =
                          data.viewModel?.itemInfo.comments?.reversed.toList();
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: data.viewModel?.itemInfo.comments?.length,
                          padding: const EdgeInsets.only(top: 10.0),
                          itemBuilder: (context, index) {
                            return Container(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: _buildCard(context,
                                    comments: commentList, index: index));
                          });
                    } else {
                      return Text("${data.error}");
                    }
                  } else {
                    assert(false, "unknown event $data");
                    return Container(color: Colors.red);
                  }
                }),
          ),
        ));
  }

  Widget _buildCard(BuildContext context,
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
                  Text('[${novaComment?.step}$kStepWord]'),
                  const SizedBox(width: 10),
                  Flexible(
                      child: SizedBox(
                          width: 160, child: Text('${novaComment?.author}'))),
                  const SizedBox(width: 10),
                  Text('${novaComment?.createAt}')
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
    const double staticFontSize = 20.0;
    const String replyCd = '\u21b1';
    String plainStr = novaComment?.plainString ?? '';
    double currOffset = calcScrollOffset(novaComment: novaComment);

    String contentStr = () {
      String retStr = '';

      novaComment?.replyList?.forEach((elem) {
        retStr += '\n$replyCd [${elem.step}$kStepWord] ${elem.plainString}';
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
          style: {"div": Style(fontSize: FontSize(staticFontSize))});
    } else {
      if (contentStr.isEmpty) {
        return Text(UseL10n.of(context)?.commentAreaNoContentString ?? '',
            style: const TextStyle(
                fontSize: staticFontSize, color: ColorDef.illeagalTextColor));
      }
      List<TextSpan> textSpans = [];
      if (!contentStr.contains('$replyCd ')) {
        textSpans.add(TextSpan(
            text: plainStr,
            style: const TextStyle(
                fontSize: staticFontSize, color: ColorDef.generalTextColor)));
      } else {
        novaComment?.replyList?.forEach((elem) {
          textSpans.add(const TextSpan(
              text: replyCd,
              style: TextStyle(
                  fontSize: staticFontSize + 8,
                  height: 0.7,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepOrangeAccent)));
          textSpans.add(const TextSpan(
              text: ' [',
              style: TextStyle(
                  fontSize: staticFontSize, color: ColorDef.generalTextColor)));
          textSpans.add(TextSpan(
            text: '${elem.step}$kStepWord',
            style: const TextStyle(
                fontSize: staticFontSize, color: ColorDef.linkColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                double targetOffset = calcScrollOffset(novaComment: elem);
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
          textSpans.add(const TextSpan(
              text: ']: ',
              style: TextStyle(
                  fontSize: staticFontSize, color: ColorDef.generalTextColor)));
          textSpans.add(TextSpan(
              text: elem.plainString,
              style: const TextStyle(
                  fontSize: staticFontSize, color: ColorDef.generalTextColor)));
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

  double calcScrollOffset({NovaComment? novaComment}) {
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
      _appBarTitle = UseL10n.of(context)?.commentAreaTitle ?? '';
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
