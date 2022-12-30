import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/local_list/local_list_presenter.dart';
import 'package:ses_novajoj/scene/local_list/local_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/nova_list_cell.dart';
import 'package:ses_novajoj/scene/widgets/error_view.dart';

class LocalListPage extends StatefulWidget {
  final LocalListPresenter presenter;
  const LocalListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<LocalListPage> createState() => _LocalListPageState();
}

enum _MenuItemValueKey { key, text }

class _LocalListPageState extends State<LocalListPage> {
  late String? _appBarTitle = UseL10n.of(context)?.localListAppBarTitle;
  late String? _selectedMenuItemText = UseL10n.of(context)?.localListMenuAll;
  int _selectedMenuItemIndex = 0;

  @override
  void initState() {
    super.initState();
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.localList);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorDef.appBarBackColor2,
        foregroundColor: ColorDef.appBarTitleColor,
        automaticallyImplyLeading: false,
        leading: _buildAppBarMenuArea(context),
        leadingWidth: 85,
        title: Text(
          "$_appBarTitle[$_selectedMenuItemText]",
          style: const TextStyle(color: Colors.black87),
        ),
        actions: _buildAppBarActionArea(context),
        centerTitle: true,
        titleSpacing: 0,
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
                      itemBuilder: (context, index) => NovaListCell(
                          viewModel: data.viewModelList![index],
                          onCellSelecting: (selIndex) {
                            widget.presenter.eventSelectDetail(context,
                                appBarTitle: _selectedMenuItemText ?? "",
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
    return PopupMenuButton(
      offset: const Offset(-1.0, -240.0),
      elevation: 0,
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      itemBuilder: (context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: Container(
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              height: 250,
              width: 100,
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final obj = items[index];
                    return ListTile(
                      selected: index == _selectedMenuItemIndex,
                      selectedColor: Colors.blue,
                      title: Text(
                        obj[_MenuItemValueKey.text],
                        style: const TextStyle(fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        if (_selectedMenuItemIndex != index) {
                          setState(() {
                            _selectedMenuItemIndex = index;
                            _selectedMenuItemText =
                                items[index][_MenuItemValueKey.text];
                          });
                          _loadData(isReloaded: true);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          )
        ];
      },
      child: Container(
        alignment: Alignment.center,
        height: 45,
        width: 45,
        margin: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.white)],
            color: Colors.white,
            shape: BoxShape.rectangle),
        child: const Icon(
          Icons.list,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActionArea(BuildContext context) {
    return <Widget>[
      SizedBox(
          width: 45,
          height: 45,
          child: IconButton(
              padding: const EdgeInsets.all(0.0),
              color: ColorDef.appBarTitleColor,
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

  void _loadData({bool isReloaded = false}) {
    // fetch data
    widget.presenter.eventViewReady(
        input: LocalListPresenterInput(
            itemIndex: _selectedMenuItemIndex, isReloaded: isReloaded));

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }
}
