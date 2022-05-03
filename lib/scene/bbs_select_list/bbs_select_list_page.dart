import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/page/screen_route_enums.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/bbs_select_list/bbs_select_list_presenter.dart';
import 'package:ses_novajoj/scene/bbs_select_list/bbs_select_list_presenter_output.dart';

class BbsSelectListPage extends StatefulWidget {
  final BbsSelectListPresenter presenter;
  const BbsSelectListPage({Key? key, required this.presenter})
      : super(key: key);

  @override
  _BbsSelectListPageState createState() => _BbsSelectListPageState();
}

class _BbsSelectListPageState extends State<BbsSelectListPage> {
  bool _pageLoadIsFirst = true;
  late Map? _parameters;
  late String _appBarTitle;
  late String? _targetUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: const Color(0xFF1B80F3),
        centerTitle: true,
      ),
      body: BlocProvider<BbsSelectListPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<BbsSelectListPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowBbsSelectListPageModel) {
                if (data.error == null) {
                  return CustomScrollView(
                    slivers: [
                      _buildForYouList(context, dataList: data.viewModelList!),
                      _buildLatestList(context, dataList: data.viewModelList!)
                    ],
                  );
                } else {
                  return Text("${data.error}");
                }
              } else {
                assert(false, "unknown event $data");
                return Container(color: Colors.red);
              }
            }),
      ),
    );
  }

  Widget _buildForYouList(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList}) {
    List<BbsSelectListRowViewModel> foryouList =
        dataList.where((element) => element.itemInfo.id < 100).toList();
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      if (index == 0) {
        return Column(children: [
          Container(
            height: 40,
            color: Colors.grey[300],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(UseL10n.of(context)?.bbsSelectListForYou ?? ''),
                )
              ],
            ),
          ),
          _buildForYouRowTile(context, dataList: foryouList, row: index),
        ]);
      } else {
        return _buildForYouRowTile(context, dataList: foryouList, row: index);
      }
    }, childCount: foryouList.length));
  }

  Widget _buildLatestList(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList}) {
    List<BbsSelectListRowViewModel> latestList =
        dataList.where((element) => element.itemInfo.id >= 100).toList();
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      if (index == 0) {
        return Column(children: [
          Container(
            height: 40,
            color: Colors.grey[300],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(UseL10n.of(context)?.bbsSelectListLatest ?? ''),
                )
              ],
            ),
          ),
          _buildLatestRowTile(context, dataList: latestList, row: index),
        ]);
      } else {
        return _buildLatestRowTile(context, dataList: latestList, row: index);
      }
    }, childCount: latestList.length));
  }

  Widget _buildForYouRowTile(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList, required int row}) {
    return ListTile(
        tileColor: Colors.grey[100],
        shape: const ContinuousRectangleBorder(
            side: BorderSide(width: 0.0, color: Colors.grey),
            borderRadius: BorderRadius.zero),
        title: Text(dataList[row].itemInfo.title),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          widget.presenter.eventSelectDetail(context,
              appBarTitle: _appBarTitle,
              itemInfo: dataList[row].itemInfo, completeHandler: () {
            _loadData();
          });
        });
  }

  Widget _buildLatestRowTile(BuildContext context,
      {required List<BbsSelectListRowViewModel> dataList, required int row}) {
    return Card(
      color: Colors.grey[100],
      child: ExpansionTile(
        title: TextButton(
            style: TextButton.styleFrom(
              primary: Colors.black,
            ),
            onPressed: () {
              widget.presenter.eventSelectDetail(context,
                  appBarTitle: _appBarTitle,
                  itemInfo: dataList[row].itemInfo, completeHandler: () {
                _loadData();
              });
            },
            child: Text(
              dataList[row].itemInfo.title,
              style: const TextStyle(fontSize: 16.0),
            )),
        children: <Widget>[
          ListTile(
              title: Row(children: [
                const SizedBox(width: 10),
                Text(
                  dataList[row].itemInfo.children?.first.title ?? '',
                  style: const TextStyle(fontSize: 15.0),
                ),
              ]),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                widget.presenter.eventSelectDetail(context,
                    appBarTitle: _appBarTitle,
                    itemInfo: dataList[row].itemInfo.children?.first,
                    completeHandler: () {
                  _loadData();
                });
              })
        ],
        iconColor: Colors.black54,
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
          _parameters?[BbsSelectListParamKeys.appBarTitle] as String? ?? '';
      _targetUrl = _parameters?[BbsSelectListParamKeys.targetUrl] as String?;

      //
      // FA
      //
      // send viewEvent
      FirebaseUtil().sendViewEvent(route: AnalyticsRoute.bbsSelectList);

      // fetch data
      _loadData();
    }
  }

  void _loadData() {
    if (_targetUrl != null) {
      widget.presenter.eventViewReady(
          input: BbsSelectListPresenterInput(itemUrl: _targetUrl ?? ''));
    } else {
      log.warning('thread_detail_page: parameter is error!');
    }
  }
}
