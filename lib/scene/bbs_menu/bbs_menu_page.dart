import 'package:flutter/material.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/bbs_menu/bbs_menu_presenter.dart';
import 'package:ses_novajoj/scene/bbs_menu/bbs_menu_presenter_output.dart';

class BbsMenuPageState {
  int subPageIndex;
  String subPageTitle;
  BbsMenuPageState({required this.subPageIndex, required this.subPageTitle});
}

class BbsMenuPage extends StatefulWidget {
  final BbsMenuPresenter presenter;
  final BbsMenuPageState pageState;

  const BbsMenuPage(
      {Key? key, required this.presenter, required this.pageState})
      : super(key: key);

  @override
  _BbsMenuPageState createState() => _BbsMenuPageState();
}

class _BbsMenuPageState extends State<BbsMenuPage>
    with AutomaticKeepAliveClientMixin<BbsMenuPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.presenter.eventViewReady(input: BbsMenuPresenterInput());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider<BbsMenuPresenter>(
      bloc: widget.presenter,
      child: StreamBuilder<BbsMenuPresenterOutput>(
          stream: widget.presenter.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowBbsMenuPageModel) {
              if (data.error == null) {
                return _buildMenuList(context,
                    menuDataList: data.viewModelList ?? []);
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

  Widget _buildMenuList(BuildContext context,
      {required List<BbsMenuListRowViewModel> menuDataList}) {
    return ListView.builder(
        itemCount: menuDataList.length,
        itemBuilder: (_, index) {
          bool isSameSection = true;
          String sectionName = menuDataList[index].sectionTitle;
          String nextSectionName = sectionName;
          if (index + 1 < menuDataList.length) {
            nextSectionName = menuDataList[index + 1].sectionTitle;
          }

          if (index == 0) {
            isSameSection = false;
          } else {
            final String prevSectionName = menuDataList[index - 1].sectionTitle;
            isSameSection = (sectionName == prevSectionName);
          }
          if (!(isSameSection)) {
            return Column(children: [
              Container(
                height: 50,
                color: Colors.grey[300],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 70, top: 15),
                      child: Text(sectionName),
                    )
                  ],
                ),
              ),
              _buildRowTile(context, menuDataList: menuDataList, row: index),
              const Divider(thickness: 1.0)
            ]);
          } else {
            List<Widget> widgets = [
              _buildRowTile(context, menuDataList: menuDataList, row: index),
            ];
            if (nextSectionName == sectionName) {
              widgets.add(const Divider(thickness: 1.0));
            }
            return Column(children: widgets);
          }
        });
  }

  Widget _buildRowTile(BuildContext context,
      {required List<BbsMenuListRowViewModel> menuDataList, required int row}) {
    return ListTile(
        leading: const SizedBox(width: 10),
        title: Text(menuDataList[row].title),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          widget.presenter.eventSelectNextList(context,
              appBarTitle: widget.pageState.subPageTitle,
              targetUrl: menuDataList[row].urlString,
              completeHandler: () {});
        });
  }
}
