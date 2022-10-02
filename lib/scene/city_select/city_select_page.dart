import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/foundation/log_util.dart';
//import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/city_select/city_select_presenter.dart';
import 'package:ses_novajoj/scene/city_select/city_select_presenter_output.dart';

enum _InputMode { direct, searching }

class CitySelectPage extends StatefulWidget {
  final CitySelectPresenter presenter;
  const CitySelectPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _CitySelectPageState createState() => _CitySelectPageState();
}

class _CitySelectPageState extends State<CitySelectPage> {
  bool _pageLoadIsFirst = true;
  bool _suggestChanged = false;
  Map? _parameters;
  late String _appBarTitle;
  NovaItemInfo? _itemInfo;
  String? _sourceRoute;
  String? _cityNameDesc;
  late FocusNode _countryNameFocusNode;
  late FocusNode _cityNameFocusNode;
  late TextEditingController _countryNameEditController;
  late TextEditingController _cityNameEditController;

  @override
  void initState() {
    super.initState();
    _countryNameFocusNode = FocusNode();
    _cityNameFocusNode = FocusNode();
    _countryNameEditController = TextEditingController();
    _cityNameEditController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _countryNameFocusNode.dispose();
    _cityNameFocusNode.dispose();
    _countryNameEditController.dispose();
    _cityNameEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _parseRouteParameter();

    return Scaffold(
        appBar: AppBar(
          title: Text(UseL10n.of(context)?.infoServiceWeatherSelectCity ?? ''),
          backgroundColor: const Color(0xFF1B80F3),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: true,
        body: () {
          List<Widget> widgets = [];
          _buildInputRowsArea(context, sourceWidgets: widgets);
          _buildMainCitiesArea(context, sourceWidgets: widgets);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          );
        }());
  }

  void _buildInputRowsArea(BuildContext context,
      {required List<Widget> sourceWidgets,
      _InputMode inputMode = _InputMode.direct}) {
    sourceWidgets.add(Container(
        padding: const EdgeInsets.only(left: 5),
        height: inputMode == _InputMode.direct ? 30 : 50,
        color: inputMode == _InputMode.direct ? Colors.blue[50] : Colors.white,
        alignment: Alignment.centerLeft,
        child: Text(
            inputMode == _InputMode.direct
                ? UseL10n.of(context)
                        ?.infoServiceWeatherSelectCityGuideFirstMessage ??
                    ''
                : UseL10n.of(context)
                        ?.infoServiceWeatherSelectCitySearchGuideMessage ??
                    '',
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16))));
    sourceWidgets.add(const SizedBox(height: 10));

    sourceWidgets.add(TextFormField(
        focusNode: _countryNameFocusNode,
        controller: _countryNameEditController,
        onTap: () async {
          _countryNameFocusNode.unfocus();
          if (inputMode == _InputMode.direct) {
            FocusScope.of(context).unfocus();
            _countryNameFocusNode.requestFocus();
          }
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 15),
            labelText: UseL10n.of(context)
                ?.infoServiceWeatherSelectCityLabelCountryName,
            hintText: UseL10n.of(context)
                ?.infoServiceWeatherSelectCityHintCountryName,
            hintStyle: TextStyle(color: Colors.grey[350]),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            alignLabelWithHint: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _countryNameEditController.clear();
                })),
        keyboardType: TextInputType.text,
        style: const TextStyle(
          fontFamily: "Poppins",
        )));
    sourceWidgets.add(const SizedBox(height: 10));

    sourceWidgets.add(TextFormField(
        focusNode: _cityNameFocusNode,
        controller: _cityNameEditController,
        onTap: () {
          _countryNameFocusNode.unfocus();
          if (inputMode == _InputMode.direct) {
            _cityNameFocusNode.unfocus();
            _showModalSheet(context);
            Future.delayed(const Duration(seconds: 0), () {
              // prevent from showing the keyboard.
              _countryNameFocusNode.dispose();
              _countryNameFocusNode = FocusNode();
            });
          } else {
            if (_cityNameEditController.text.isNotEmpty) {
              _suggestChanged = false;
              _submitSelectCityData(dataCleared: true);
            }
            _cityNameFocusNode.requestFocus();
          }
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 15),
            label: Row(children: [
              Text(UseL10n.of(context)
                      ?.infoServiceWeatherSelectCityLabelCityName ??
                  ''),
              const SizedBox(width: 20),
              Text(
                UseL10n.of(context)?.requiredLabelOfTextField ?? '',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600),
              )
            ]),
            hintText:
                UseL10n.of(context)?.infoServiceWeatherSelectCityHintCityName,
            hintStyle: TextStyle(color: Colors.grey[350]),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor: Colors.white,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: null,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            suffixIcon: inputMode == _InputMode.direct
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      if (_cityNameEditController.text.isEmpty) {
                        return;
                      }
                      _cityNameEditController.clear();
                      setState(() {
                        _suggestChanged = false;
                      });
                      _submitSelectCityData(dataCleared: true);
                      _cityNameFocusNode.requestFocus();
                    })),
        autovalidateMode: AutovalidateMode.always,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (string) {
          _suggestChanged = true;
          _submitSelectCityData(dataCleared: false);
        },
        style: const TextStyle(
          fontFamily: "Poppins",
        )));
    inputMode == _InputMode.searching || _cityNameEditController.text.isEmpty
        ? const SizedBox(height: 0.0, width: 0.0)
        : sourceWidgets.add(Container(
            padding: const EdgeInsets.only(top: 5, left: 20),
            alignment: Alignment.centerLeft,
            height: 25,
            child: Text(
              _cityNameEditController.text.isEmpty ? '' : _cityNameDesc ?? '',
              style: const TextStyle(fontSize: 11),
            ),
          ));

    if (inputMode == _InputMode.direct) {
      return;
    }

    sourceWidgets.add(
      StreamBuilder<CitySelectPresenterOutput>(
          stream: widget.presenter.stream,
          builder: (context, snapshot) {
            if (!_suggestChanged) {
              return const SizedBox(height: 0.0, width: 0.0);
            }
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }

            final data = snapshot.data;
            if (data is ShowCitySelectPageModel) {
              if (data.error == null) {
                if (data.viewModel!.dataCleared) {
                  return const SizedBox(height: 0.0, width: 0.0);
                } else {
                  return Container(
                      padding: const EdgeInsets.only(top: 5),
                      height: 300,
                      child: ListView(
                          children:
                              _buildSuggestions(viewModel: data.viewModel)));
                }
              } else {
                log.severe('${data.error}');
                return const Text("Not found");
              }
            } else {
              assert(false, "unknown event $data");
              return Container(color: Colors.red);
            }
          }),
    );
  }

  void _buildMainCitiesArea(BuildContext context,
      {required List<Widget> sourceWidgets}) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    sourceWidgets.add(const SizedBox(height: 30));
    sourceWidgets.add(Container(
        padding: const EdgeInsets.only(left: 5),
        height: 30,
        color: Colors.blue[50],
        alignment: Alignment.centerLeft,
        child: Text(
          UseL10n.of(context)?.infoServiceWeatherSelectCityGuideSecondMessage ??
              '',
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 16),
        )));

    sourceWidgets.add(const SizedBox(height: 10));
    sourceWidgets.add(SizedBox(
        height: 300,
        child: FutureBuilder(
          future: widget.presenter
              .eventSelectMainCities(input: CitySelectPresenterInput()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.amber, backgroundColor: Colors.grey[850]));
            }
            final data = snapshot.data;
            if (data is ShowCitySelectPageModel) {
              if (data.error == null) {
                return GridView.count(
                    // Create a grid with 4 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    childAspectRatio: (itemWidth / itemHeight) * 4.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    // Generate 30 widgets that display their index in the List.
                    children: data.viewModel?.cityInfos.map((elem) {
                          return Container(
                              height: 30,
                              padding: const EdgeInsets.all(5),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.lightBlue)),
                                  onPressed: () {
                                    _didSelectedCity(context, cityInfo: elem);
                                  },
                                  child: Text(
                                    elem.nameDesc,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  )));
                        }).toList() ??
                        []);
              } else {
                return Text("${data.error}");
              }
            } else {
              assert(false, "unknown event $data");
              return Container(color: Colors.red);
            }
          },
        )));
  }

  List<Widget> _buildSuggestions({CitySelectViewModel? viewModel}) {
    final list = <Widget>[];

    (viewModel?.cityInfos ?? []).asMap().forEach((idx, elem) {
      list.add(ListTile(
          tileColor: Colors.grey[100],
          shape: const ContinuousRectangleBorder(
              side: BorderSide(width: 0.5, color: Colors.grey),
              borderRadius: BorderRadius.zero),
          title: Text(elem.nameDesc),
          subtitle: Text('${elem.state} - ${elem.countryCode}'),
          trailing: Image.asset(
              'icons/flags/png/${elem.countryCode.toLowerCase()}.png',
              package: 'country_icons',
              width: 30),
          onTap: () {
            _didSelectedCity(context, cityInfo: elem, modal: true);
            setState(() {});
          }));
    });
    return list;
  }

  void _showModalSheet(BuildContext context) {
    _suggestChanged = false;
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          List<Widget> widgets = [];
          _buildInputRowsArea(context,
              sourceWidgets: widgets, inputMode: _InputMode.searching);

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            color: Colors.white12,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widgets,
              ),
            ),
          );
        }).whenComplete(() {
      if (_cityNameEditController.text !=
          (_itemInfo?.weatherInfo?.city?.name ?? '')) {
        _cityNameDesc = '';
        setState(() {});
      }
    });
  }

  void _didSelectedCity(BuildContext context,
      {required CityInfo cityInfo, bool? modal}) {
    if (modal == true) {
      Navigator.of(context).pop();
    }
    // transform current screen to target web site.
    bool retVal = widget.presenter.eventSelectingCityInfo(
      context,
      input: CitySelectPresenterInput(
          appBarTitle: _appBarTitle,
          selectedCityInfo: cityInfo,
          order: _itemInfo?.orderIndex ?? 0,
          serviceType: _itemInfo?.serviceType ?? ServiceType.none,
          sourceRoute: _sourceRoute),
    );

    // if selecting is failure
    if (!retVal) {
      final snackBar = SnackBar(
        content: Text(UseL10n.of(context)?.msgSelectedTargetIsExisted ?? ''),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          _parameters?[CitySelectParamKeys.appBarTitle] as String? ?? '';
      _itemInfo = _parameters?[CitySelectParamKeys.itemInfo] as NovaItemInfo?;
      _sourceRoute = _parameters?[CitySelectParamKeys.sourceRoute] as String?;
      _cityNameDesc = _itemInfo?.weatherInfo?.city?.nameDesc;
      _cityNameEditController.text = _itemInfo?.weatherInfo?.city?.name ?? '';
      _countryNameEditController.text =
          _itemInfo?.weatherInfo?.city?.countryCode ?? '';

      //
      // FA
      //
      // send viewEvent
      FirebaseUtil().sendViewEvent(route: AnalyticsRoute.citySelect);
    }
  }

  void _submitSelectCityData({required bool dataCleared}) {
    widget.presenter.eventViewReady(
        input: CitySelectPresenterInput(
            selectedCityInfo: () {
              CityInfo cityInfo = CityInfo();
              cityInfo.countryCode = _countryNameEditController.text;
              cityInfo.name = _cityNameEditController.text;
              return cityInfo;
            }(),
            dataCleared: dataCleared));
  }
}
