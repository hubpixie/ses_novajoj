import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_presenter.dart';
import 'package:ses_novajoj/scene/misc_info_list/misc_info_list_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/info_service_cell.dart';

class MiscInfoListPage extends StatefulWidget {
  final MiscInfoListPresenter presenter;
  const MiscInfoListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _MiscInfoListPageState createState() => _MiscInfoListPageState();
}

class _MiscInfoListPageState extends State<MiscInfoListPage> {
  @override
  void initState() {
    super.initState();
    widget.presenter.eventViewReady(input: MiscInfoListPresenterInput());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UseL10n.of(context)?.infoServiceTop ?? ''),
        backgroundColor: const Color(0xFF1B80F3),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: BlocProvider<MiscInfoListPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<MiscInfoListPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowMiscInfoListPageModel) {
                if (data.error == null) {
                  return Column(
                    children: [
                      _buildMyTimeArea(context,
                          viewModelList: data.viewModelList),
                      _buildOnlineLiveArea(context,
                          viewModelList: data.viewModelList),
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

  Widget _buildMyTimeArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceMyTime ?? '',
      rowTitleList: [
        UseL10n.of(context)?.infoServiceMyTimeWork ?? '',
        UseL10n.of(context)?.infoServiceMyTimeRest ?? '',
        UseL10n.of(context)?.infoServiceMyTimeHoliday ?? '',
        UseL10n.of(context)?.infoServiceMyTimeCalendar ?? ''
      ],
      onRowSelecting: (index) {
        final itemInfo = viewModelList
            ?.firstWhere((element) =>
                element.itemInfo.serviceType == ServiceType.time &&
                element.itemInfo.orderIndex == index)
            .itemInfo;
        widget.presenter.eventViewWebPage(context,
            appBarTitle: itemInfo?.title ?? '',
            itemInfo: itemInfo,
            completeHandler: () {});
      },
      onOtherRowSelecting: (index) {},
    );
  }

  Widget _buildOnlineLiveArea(BuildContext context,
      {List<MiscInfoListViewModel>? viewModelList}) {
    return InfoServiceCell(
      sectionTitle: UseL10n.of(context)?.infoServiceOnline ?? '',
      rowTitleList: [
        UseL10n.of(context)?.infoServiceOnlineHotRadio ?? '',
        UseL10n.of(context)?.infoServiceOnlineAfn ?? '',
      ],
      otherTitle: UseL10n.of(context)?.infoServiceItemOther,
      onRowSelecting: (index) {
        final itemInfo = viewModelList
            ?.firstWhere((element) =>
                element.itemInfo.serviceType == ServiceType.audio &&
                element.itemInfo.orderIndex == index)
            .itemInfo;
        widget.presenter.eventViewWebPage(context,
            appBarTitle: itemInfo?.title ?? '',
            itemInfo: itemInfo,
            completeHandler: () {});
      },
      onOtherRowSelecting: (index) {},
    );
  }
}
