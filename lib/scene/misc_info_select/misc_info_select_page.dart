import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/misc_info_select/misc_info_select_presenter.dart';
import 'package:ses_novajoj/scene/misc_info_select/misc_info_select_presenter_output.dart';
import 'package:ses_novajoj/scene/widgets/focus_dismiss_widget.dart';

class MiscInfoSelectPage extends StatefulWidget {
  final MiscInfoSelectPresenter presenter;
  const MiscInfoSelectPage({Key? key, required this.presenter})
      : super(key: key);

  @override
  _MiscInfoSelectPageState createState() => _MiscInfoSelectPageState();
}

class _MiscInfoSelectPageState extends State<MiscInfoSelectPage> {
  bool _pageLoadIsFirst = true;
  late Map? _parameters;
  late String _appBarTitle;
  late NovaItemInfo? _itemInfo;
  late FocusNode _webTitleFocusNode;
  late FocusNode _webUrlFocusNode;
  late TextEditingController _webTitleEditController;
  late TextEditingController _webUrlEditController;
  int? _selectWebIndex;
  String? _valueOfValidatedInputtedUrl;

  MiscInfoSelectViewModelTry? _dataModel;
  @override
  void initState() {
    super.initState();
    _webTitleFocusNode = FocusNode();
    _webUrlFocusNode = FocusNode();
    _webUrlFocusNode.addListener(() {
      if (!_webUrlFocusNode.hasFocus) {
        setState(() {
          _valueOfValidatedInputtedUrl =
              _validateInputtedUrl(context, inUrl: _webUrlEditController.text);
        });
      }
    });
    _webTitleEditController = TextEditingController();
    _webUrlEditController = TextEditingController();

    widget.presenter.eventViewReady(input: MiscInfoSelectPresenterInput());
  }

  @override
  void dispose() {
    super.dispose();
    _webTitleFocusNode.dispose();
    _webUrlFocusNode.dispose();
    _webTitleEditController.dispose();
    _webUrlEditController.dispose();
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
      body: BlocProvider<MiscInfoSelectPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<MiscInfoSelectPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              /*
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowMiscInfoSelectPageModel) {
                if (data.error == null) {
                  return Column(
                    children: [Text("${data.viewModel}")],
                  );
                } else {
                  return Text("${data.error}");
                }
              } else {
                assert(false, "unknown event $data");
                return Container(color: Colors.red);
              }
              */
              return FocusDismiss(
                  onEndEditing: (focused) {
                    if (!focused) {
                      if (!_webUrlFocusNode.hasFocus) {
                        setState(() {
                          _valueOfValidatedInputtedUrl = _validateInputtedUrl(
                              context,
                              inUrl: _webUrlEditController.text);
                        });
                      }
                    }
                  },
                  child: CustomScrollView(
                      slivers:
                          _buildSelectRowsArea(context, model: _dataModel)));
            }),
      ),
    );
  }

  List<Widget> _buildSelectRowsArea(context,
      {MiscInfoSelectViewModelTry? model}) {
    if (model == null || model.urlInfoList.isEmpty) {
      return [];
    }
    int cnt = model.urlInfoList.length;
    return <Widget>[
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        final urlInfo = model.urlInfoList[index];
        List<Widget> widgets = [];
        if (index == 0) {
          widgets.add(Align(
              alignment: Alignment.centerLeft,
              child: Text(
                UseL10n.of(context)?.infoServicelistSelectHintMessage ?? '',
              )));
          widgets.add(const Divider());
        }
        if (index == cnt - 1) {
          List<Widget> subWidgets = [];
          _buildInputRowsArea(context, sourceWidgets: subWidgets);

          widgets.add(RadioListTile<int>(
            activeColor: Colors.lightBlue,
            title: Text(UseL10n.of(context)?.infoServicelistInputOther ?? ''),
            subtitle: Column(children: subWidgets),
            contentPadding:
                const EdgeInsets.only(left: 20, right: 10, top: 0, bottom: 20),
            groupValue: _selectWebIndex,
            onChanged: (int? value) {
              setState(() {
                _selectWebIndex = value;
              });
            },
            value: index,
          ));
          widgets.add(const Divider(
            thickness: 1.0,
          ));

          // add next button
          _buildNextButtonArea(context, sourceWidgets: widgets);
        } else {
          widgets.add(RadioListTile<int>(
            activeColor: Colors.lightBlue,
            title: Text(urlInfo.title),
            subtitle: Text(urlInfo.urlString),
            contentPadding:
                const EdgeInsets.only(left: 20, right: 10, top: 0, bottom: 0),
            groupValue: _selectWebIndex,
            onChanged: (int? value) {
              setState(() {
                _selectWebIndex = value;
                _valueOfValidatedInputtedUrl = null;
              });
            },
            value: index,
          ));
          widgets.add(const Divider());
        }
        return Padding(
          padding: () {
            if (index == 0) {
              return const EdgeInsets.only(
                  top: 20, left: 20, bottom: 0, right: 30);
              // } else if (index == cnt - 1) {
              //   return const EdgeInsets.only(
              //       top: 0, left: 20, bottom: 20, right: 20);
            } else {
              return const EdgeInsets.only(left: 20, right: 20);
            }
          }(),
          child: Column(
            children: widgets,
          ),
        );
      }, childCount: cnt))
    ];
  }

  void _buildInputRowsArea(BuildContext context,
      {required List<Widget> sourceWidgets}) {
    sourceWidgets.add(Align(
        alignment: Alignment.centerLeft,
        child: Text(UseL10n.of(context)?.infoServicelistInputHintMessage ?? '',
            textAlign: TextAlign.left)));
    sourceWidgets.add(const SizedBox(height: 20));
    sourceWidgets.add(TextFormField(
        focusNode: _webTitleFocusNode,
        controller: _webTitleEditController,
        onTap: () {
          _webTitleFocusNode.requestFocus();
          setState(() {
            _valueOfValidatedInputtedUrl = null;
            _selectWebIndex = (_dataModel?.urlInfoList.length ?? 0) - 1;
          });
        },
        decoration: InputDecoration(
            labelText: UseL10n.of(context)?.infoServicelistInputWebTitle,
            hintText:
                UseL10n.of(context)?.infoServicelistInputWebTitlePlaceHolder,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(),
            ),
            suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _webTitleFocusNode.requestFocus();
                  _webTitleEditController.clear();
                })),
        //validator: (val) {return '';},
        keyboardType: TextInputType.text,
        style: const TextStyle(
          fontFamily: "Poppins",
        )));
    sourceWidgets.add(const SizedBox(height: 20));
    sourceWidgets.add(TextFormField(
        focusNode: _webUrlFocusNode,
        controller: _webUrlEditController,
        onTap: () {
          _webUrlFocusNode.requestFocus();
          setState(() {
            _valueOfValidatedInputtedUrl = null;
            _selectWebIndex = (_dataModel?.urlInfoList.length ?? 0) - 1;
          });
        },
        decoration: InputDecoration(
            labelText: UseL10n.of(context)?.infoServicelistInputWebUrl,
            hintText:
                UseL10n.of(context)?.infoServicelistInputWebUrlPlaceHolder,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: null,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _webUrlFocusNode.requestFocus();
                  _webUrlEditController.clear();
                })),
        autovalidateMode: AutovalidateMode.always,
        validator: (val) => _valueOfValidatedInputtedUrl,
        keyboardType: TextInputType.url,
        style: const TextStyle(
          fontFamily: "Poppins",
        )));
  }

  void _buildNextButtonArea(BuildContext context,
      {required List<Widget> sourceWidgets}) {
    sourceWidgets.add(const SizedBox(height: 30));
    sourceWidgets.add(SizedBox(
      width: 160,
      height: 40,
      child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: _checkNextButtonIsAvailable()
                ? MaterialStateProperty.all<Color>(Colors.lightBlue)
                : MaterialStateProperty.all<Color>(Colors.blueGrey),
          ),
          onPressed: _checkNextButtonIsAvailable()
              ? () {
                  // TODO:save selected url info into shared_pref.
                  // transform current screen to target web site.
                  widget.presenter.eventSelectingUrlInfo(context,
                      input: MiscInfoSelectPresenterInput(
                          selectedUrlInfo: _getSelectedUrlInfo(),
                          serviceType:
                              _itemInfo?.serviceType ?? ServiceType.none));
                }
              : null,
          child: const Text('OK')),
    ));
    sourceWidgets.add(const SizedBox(height: 30));
  }

  SimpleUrlInfo? _getSelectedUrlInfo() {
    int cnt = _dataModel?.urlInfoList.length ?? 0;

    if (_selectWebIndex == null) {
      return null;
    } else if (_selectWebIndex! < cnt - 1) {
      return _dataModel?.urlInfoList[_selectWebIndex!];
    } else if (_webTitleEditController.text.isEmpty ||
        _webUrlEditController.text.isEmpty) {
      return null;
    }
    return SimpleUrlInfo(
        title: _webUrlEditController.text,
        urlString: _webUrlEditController.text);
  }

  String? _validateInputtedUrl(BuildContext context, {required String inUrl}) {
    int cnt = _dataModel?.urlInfoList.length ?? 0;
    if (_selectWebIndex == null || _selectWebIndex! < cnt - 1) {
      return null;
    }

    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (inUrl.isEmpty) {
      return UseL10n.of(context)?.infoServicelistInputWebUrlEmptyMessage ?? '';
    } else if (!regExp.hasMatch(inUrl)) {
      return UseL10n.of(context)?.infoServicelistInputWebUrlValidMessage ?? '';
    }
    return null;
  }

  bool _checkNextButtonIsAvailable() {
    int cnt = _dataModel?.urlInfoList.length ?? 0;
    if (_selectWebIndex == null) {
      return false;
    } else if (_selectWebIndex! < cnt - 1) {
      return true;
    } else if (_webTitleEditController.text.isEmpty ||
        _webUrlEditController.text.isEmpty) {
      return false;
    } else {
      return _valueOfValidatedInputtedUrl == null;
    }
  }

  void _parseRouteParameter() {
    if (_pageLoadIsFirst) {
      _pageLoadIsFirst = false;
      //
      // get page paratmers via ModalRoute
      //
      _parameters = ModalRoute.of(context)?.settings.arguments as Map?;
      _appBarTitle =
          _parameters?[MiscInfoSelectParamKeys.appBarTitle] as String? ?? '';
      _itemInfo =
          _parameters?[MiscInfoSelectParamKeys.itemInfo] as NovaItemInfo?;

      //
      // FA
      //
      // send viewEvent
      FirebaseUtil().sendViewEvent(route: AnalyticsRoute.miscInfoSelect);

      // fetch data
      _loadData();
    }
  }

  void _loadData() {
    _dataModel = MiscInfoSelectViewModelTry(_itemInfo!, [
      SimpleUrlInfo(title: 'AAA', urlString: 'http://google.com/123/'),
      SimpleUrlInfo(title: 'BBB', urlString: 'http://google.com/123/'),
      SimpleUrlInfo(title: 'CCC', urlString: 'http://google.com/123/'),
      SimpleUrlInfo(title: 'DDD', urlString: 'http://google.com/123/'),
      SimpleUrlInfo(title: 'EEE', urlString: 'http://google.com/123/'),
      SimpleUrlInfo(title: 'FFF', urlString: 'http://google.com/123/'),
      SimpleUrlInfo(title: '', urlString: ''),
    ]);
    // if (_targetUrl != null) {
    //   widget.presenter.eventViewReady(
    //       input: BbsSelectListPresenterInput(targetUrl: _targetUrl ?? ''));
    // } else {
    //   log.warning('thread_detail_page: parameter is error!');
    // }
  }
}
