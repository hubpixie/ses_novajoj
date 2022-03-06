import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter.dart';
import 'package:ses_novajoj/scene/top_list/top_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/top_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/square_text_icon_button.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class TopListPage extends StatefulWidget {
  final TopListPresenter presenter;
  const TopListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _TopListPageState createState() => _TopListPageState();
}

class _TopListPageState extends State<TopListPage> {
  int _selectedIconIndex = 0;

  late final List<String> _appBarTitleList = [
    UseL10n.of(context)?.appBarFullNameLatest ?? '',
    UseL10n.of(context)?.appBarFullNameOptic ?? '',
    UseL10n.of(context)?.appBarFullNameRecommending ?? '',
    UseL10n.of(context)?.appBarFullNameHot ?? '',
    UseL10n.of(context)?.appBarFullNameCommenting ?? '',
  ];
  String _prefixNovaTitle = '';
  late final _prefixNovaTitleHot = UseL10n.of(context)?.todayHotNews ?? '';
  late final _prefixNovaTitlePopulary =
      UseL10n.of(context)?.todayPopularNews ?? '';

  late String _selectedAppBarTitle = _appBarTitleList[_selectedIconIndex];

  @override
  void initState() {
    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topList);
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B80F3),
        automaticallyImplyLeading: false,
        leading: const SizedBox(width: 0),
        title: _buildAppBarTitleArea(context),
        actions: _buildAppBarActionArea(context),
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 10,
      ),
      body: BlocProvider<TopListPresenter>(
        bloc: widget.presenter,
        child: SafeArea(
          child: StreamBuilder<TopListPresenterOutput>(
              stream: widget.presenter.stream,
              builder: (context, snapshot) {
                if (widget.presenter.isProcessing) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: Colors.amber,
                          backgroundColor: Colors.grey[850]));
                }
                final data = snapshot.data;
                if (data is ShowNovaListModel) {
                  if (data.error == null) {
                    return ListView.builder(
                        itemCount: data.viewModelList?.length,
                        itemBuilder: (context, index) => TopListCell(
                            viewModel: data.viewModelList![index],
                            onCellSelecting: (selIndex) {
                              widget.presenter.eventSelectDetail(context,
                                  appBarTitle: _selectedAppBarTitle,
                                  itemInfo: data.viewModelList![selIndex]
                                      .itemInfo, completeHandler: () {
                                _loadData(isReloaded: true);
                              });
                            },
                            onThumbnailShowing: (thumbIndex) async {
                              if (data.viewModelList![thumbIndex].itemInfo
                                  .thunnailUrlString.isNotEmpty) {
                                return data.viewModelList![thumbIndex].itemInfo
                                    .thunnailUrlString;
                              }
                              final retUrl = await widget.presenter
                                  .eventFetchThumbnail(
                                      targetUrl: data.viewModelList![thumbIndex]
                                          .itemInfo.urlString);
                              data.viewModelList![thumbIndex].itemInfo
                                  .thunnailUrlString = retUrl;
                              return retUrl;
                            },
                            index: index));
                  } else {
                    return ErrorView(
                      message: UseL10n.localizedTextWithError(context,
                          error: data.error),
                      onFirstButtonTap: data.error?.type == AppErrorType.network
                          ? () {
                              _selectTextIcon(_selectedIconIndex,
                                  isReloaded: true);
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
      ),
    );
  }

  Widget _buildAppBarTitleArea(BuildContext context) {
    return SizedBox(
        width: 265,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareTextIconButton(
              string: UseL10n.of(context)?.appBarIconNameLatest ?? '',
              index: 0,
              selected: _selectedIconIndex == 0,
              onCellSelecting: () {
                _selectTextIcon(0);
              },
            ),
            SquareTextIconButton(
              string: UseL10n.of(context)?.appBarIconNameOptic ?? '',
              index: 1,
              selected: _selectedIconIndex == 1,
              onCellSelecting: () {
                _selectTextIcon(1);
              },
            ),
            SquareTextIconButton(
              string: UseL10n.of(context)?.appBarIconNameRecommending ?? '',
              index: 2,
              selected: _selectedIconIndex == 2,
              onCellSelecting: () {
                _selectTextIcon(2);
              },
            ),
            SquareTextIconButton(
              string: UseL10n.of(context)?.appBarIconNameHot ?? '',
              index: 3,
              selected: _selectedIconIndex == 3,
              onCellSelecting: () {
                _selectTextIcon(3);
              },
            ),
            SquareTextIconButton(
              string: UseL10n.of(context)?.appBarIconNameCommenting ?? '',
              index: 4,
              selected: _selectedIconIndex == 4,
              onCellSelecting: () {
                _selectTextIcon(4);
              },
            ),
            SizedBox(
                width: 140,
                height: 35,
                child: IconButton(
                    padding: const EdgeInsets.only(left: 5),
                    onPressed: null,
                    icon: Text(_selectedAppBarTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ));
  }

  List<Widget> _buildAppBarActionArea(BuildContext context) {
    return <Widget>[
      SizedBox(
          width: 45,
          height: 45,
          child: IconButton(
              padding: const EdgeInsets.all(0.0),
              color: Colors.white,
              onPressed: () {
                // reload data
                _loadData(isReloaded: true);
              },
              icon: const Icon(Icons.refresh_rounded))),
      SizedBox(
        width: MediaQuery.of(context).size.width <= 375 ? 0 : 25,
        height: 50,
      )
    ];
  }

  void _selectTextIcon(int index, {bool isReloaded = false}) {
    if (isReloaded == false) {
      if (index == _selectedIconIndex) {
        return;
      } else {
        _selectedIconIndex = index;
        _selectedAppBarTitle = _appBarTitleList[index];
        _prefixNovaTitle = () {
          String retStr = "";
          if (index == 3) {
            retStr = _prefixNovaTitleHot;
          } else if (index == 4) {
            retStr = _prefixNovaTitlePopulary;
          }
          return retStr;
        }();
      }
    }

    // reload data
    _loadData(isReloaded: true);
  }

  void _loadData({bool isReloaded = false}) {
    // fetch data
    widget.presenter.eventViewReady(
        targetUrlIndex: _selectedIconIndex,
        prefixTitle: _prefixNovaTitle,
        isReloaded: isReloaded);

    if (isReloaded) {
      Future.delayed(Duration.zero, () {
        setState(() {});
      });
    }
  }
}
