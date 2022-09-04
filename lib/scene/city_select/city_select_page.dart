import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:country_icons/country_icons.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
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
  bool _searchEnabled = false;
  late Map? _parameters;
  late String _appBarTitle;
  late NovaItemInfo? _itemInfo;
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

    // TODO: Initialize your variables.
    widget.presenter.eventViewReady(input: CitySelectPresenterInput());
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
      body: BlocProvider<CitySelectPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<CitySelectPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              /*
              final data = snapshot.data;
              if (data is ShowCitySelectPageModel) {
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
            }),
      ),
    );
  }

  void _buildInputRowsArea(BuildContext context,
      {required List<Widget> sourceWidgets,
      _InputMode inputMode = _InputMode.direct}) {
    sourceWidgets.add(Align(
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
                  _countryNameFocusNode.requestFocus();
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
          //FocusScope.of(context).requestFocus(FocusNode());
          if (inputMode == _InputMode.direct) {
            _cityNameFocusNode.unfocus();
            _showModalSheet(context);
            Future.delayed(const Duration(seconds: 0), () {
              // prevent from showing the keyboard.
              _countryNameFocusNode.dispose();
              _countryNameFocusNode = FocusNode();
            });
          } else {
            if (_searchEnabled) {
              setState(() {
                _searchEnabled = false;
              });
            }
            _cityNameFocusNode.requestFocus();
          }
        },
        decoration: InputDecoration(
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
                      _cityNameEditController.clear();
                    })),
        autovalidateMode: AutovalidateMode.always,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (string) {
          setState(() {
            _searchEnabled = _cityNameEditController.text.isNotEmpty;
          });
        },
        style: const TextStyle(
          fontFamily: "Poppins",
        )));

    if (inputMode == _InputMode.direct) {
      return;
    }

    sourceWidgets.add(
      _searchEnabled
          ? FutureBuilder<List<Widget>>(
              future: _buildSuggestions(keyword: _cityNameEditController.text),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                      padding: const EdgeInsets.only(top: 5),
                      height: 300,
                      child: ListView(children: snapshot.data!));
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              },
            )
          : const SizedBox(height: 0.0, width: 0.0),
    );
  }

  void _buildMainCitiesArea(BuildContext context,
      {required List<Widget> sourceWidgets}) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    sourceWidgets.add(const SizedBox(height: 30));
    sourceWidgets.add(Align(
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
        child: GridView.count(
          // Create a grid with 4 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          childAspectRatio: (itemWidth / itemHeight) * 4.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          // Generate 30 widgets that display their index in the List.
          children: List.generate(12, (index) {
            return Container(
                height: 30,
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.lightBlue)),
                    onPressed: () {},
                    child: Text(
                      'Item $index',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )));
          }),
        )));
  }

  Future<List<Widget>> _buildSuggestions({required String keyword}) async {
    final list = <Widget>[];
    final suggestions = await Future.delayed(Duration(seconds: 1),
        () => ["New York", "New City", "City Land", "Tokyo", "TomoroW"]);
    final keyword_ = keyword.toLowerCase();
    suggestions.where((elem) => elem.toLowerCase().contains(keyword_)).forEach(
        (elem) => list.add(ListTile(
            tileColor: Colors.grey[100],
            shape: const ContinuousRectangleBorder(
                side: BorderSide(width: 0.5, color: Colors.grey),
                borderRadius: BorderRadius.zero),
            title: Text(elem),
            subtitle: Text(elem),
            trailing: Image.asset('icons/flags/png/au.png',
                package: 'country_icons', width: 30),
            onTap: () {
              // FIXME: there are dummy codes.
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            })));
    return list;
  }

  void _showModalSheet(BuildContext context) {
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
        });
  }

  SimpleCityInfo _getSelectedCityInfo() {
    return SimpleCityInfo();
  }

  bool _checkNextButtonIsAvailable() {
    return true;
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

      //
      // FA
      //
      // send viewEvent
      FirebaseUtil().sendViewEvent(route: AnalyticsRoute.citySelect);

      // fetch data
      _loadData();
    }
  }

  void _loadData() {}
}
