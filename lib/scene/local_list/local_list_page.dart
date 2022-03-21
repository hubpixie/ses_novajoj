import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/local_list/local_list_presenter.dart';
import 'package:ses_novajoj/scene/local_list/local_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/local_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class LocalListPage extends StatefulWidget {
  final LocalListPresenter presenter;
  const LocalListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _LocalListPageState createState() => _LocalListPageState();
}

enum _MenuItemValueKey { key, text }

class _LocalListPageState extends State<LocalListPage> {
  late String? _selectMenuItemText = UseL10n.of(context)?.localListMenuAll;
  int _selectMenuItemIndex = 0;

  @override
  void initState() {
    super.initState();
    // TODO: Initialize your variables.
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.localList);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B80F3),
        automaticallyImplyLeading: false,
        leading: const SizedBox(width: 0),
        title: _buildAppBarMenuArea(context),
        actions: _buildAppBarActionArea(context),
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 10,
      ),
      body: BlocProvider<LocalListPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<LocalListPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowLocalListPageModel) {
                if (data.error == null) {
                  return ListView.builder(
                      itemCount: data.viewModelList?.length,
                      itemBuilder: (context, index) => LocalListCell(
                          viewModel: data.viewModelList![index],
                          onCellSelecting: (selIndex) {
                            // widget.presenter.eventSelectDetail(context,
                            //     appBarTitle: _selectMenuItemText,
                            //     itemInfo: data.viewModelList![selIndex]
                            //         .itemInfo, completeHandler: () {
                            //   _loadData(isReloaded: true);
                            // });
                          },
                          onThumbnailShowing: (thumbIndex) async {
                            if (data.viewModelList![thumbIndex].itemInfo
                                .thunnailUrlString.isNotEmpty) {
                              return data.viewModelList![thumbIndex].itemInfo
                                  .thunnailUrlString;
                            }
                            final retUrl = await widget.presenter
                                .eventFetchThumbnail(
                                    input: LocalListPresenterInput(
                                        itemIndex: thumbIndex,
                                        itemUrl: data.viewModelList![thumbIndex]
                                            .itemInfo.urlString));
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
                            _loadData();
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

  Widget _buildAppBarMenuArea(BuildContext context) {
    int index = 0;
    List<Map> items = <Map>[
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuAll
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuUs
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuCa
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuAu
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuNz
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuUk
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuDe
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuJp
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuSg
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuIe
      },
      {
        _MenuItemValueKey.key: index++,
        _MenuItemValueKey.text: UseL10n.of(context)?.localListMenuEu
      },
    ];

    final Widget scrollChildButton = SizedBox(
      width: 100,
      height: 35,
      child: Container(
        color: const Color(0xFF1B80F3),
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                _selectMenuItemText ?? "",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 5),
            const SizedBox(
              width: 15,
              height: 20,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
        width: 280,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            MenuButton<Map>(
              child: scrollChildButton,
              items: items,
              topDivider: true,
              scrollPhysics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (Map value) => Container(
                color: Colors.grey[200],
                height: 40,
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                child: Text(value[_MenuItemValueKey.text]),
              ),
              toggledChild: Container(
                child: scrollChildButton,
              ),
              divider: Container(
                height: 1,
                color: Colors.grey[350],
              ),
              onItemSelected: (Map value) {
                if (_selectMenuItemIndex != value[_MenuItemValueKey.key]) {
                  _selectMenuItemIndex = value[_MenuItemValueKey.key];
                  _selectMenuItemText = value[_MenuItemValueKey.text];
                  _loadData(isReloaded: true);
                }
              },
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(3.0),
                  )),
              onMenuButtonToggle: (bool isToggle) {
                print(isToggle);
              },
              popupHeight: 250,
            ),
            //const SizedBox(width: 10),
            SizedBox(
                width: 140,
                height: 35,
                child: IconButton(
                    padding: const EdgeInsets.only(left: 5),
                    onPressed: null,
                    icon: Text(UseL10n.of(context)?.localListAppBarTitle ?? "",
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
                //_loadData(isReloaded: true);
              },
              icon: const Icon(Icons.refresh_rounded))),
      SizedBox(
        width: MediaQuery.of(context).size.width <= 375 ? 0 : 25,
        height: 50,
      )
    ];
  }

  void _loadData({bool isReloaded = false}) {
    // fetch data
    widget.presenter.eventViewReady(
        input: LocalListPresenterInput(
            itemIndex: _selectMenuItemIndex, isReloaded: isReloaded));

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }
}
