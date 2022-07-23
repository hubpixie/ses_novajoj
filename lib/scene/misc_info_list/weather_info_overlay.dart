import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/scene/foundation/data/weather_util.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';

typedef _CellEditingDelegate = void Function(dynamic temprtUnit);
typedef _ShowForecastDelegate = void Function();

class WeatherInfoOverlay extends StatefulWidget {
  final WeatherInfo? itemValue;
  final TemperatureUnit temprtUnit;
  final _CellEditingDelegate? onCellEditing;
  final _ShowForecastDelegate? onPresentWeeklyForecast;

  const WeatherInfoOverlay(
      {Key? key,
      this.itemValue,
      this.temprtUnit = TemperatureUnit.celsius,
      this.onCellEditing,
      this.onPresentWeeklyForecast})
      : super(key: key);

  @override
  WeatherInfoOverlayState createState() => WeatherInfoOverlayState();
}

class WeatherInfoOverlayState extends State<WeatherInfoOverlay>
    with WidgetsBindingObserver {
  late CityInfo _cityParam;

  @override
  void initState() {
    _cityParam = CityInfo();
    //_readPrefsData();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_cityParam.zip.isEmpty && _cityParam.name.isEmpty)
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              _buildWeatherTopArea(itemValue: widget.itemValue),
              const SizedBox(height: 1),
              _buildWeatherContentArea(
                context,
                itemValue: widget.itemValue,
              ),
              const SizedBox(height: 1),
              _buildWeatherFunctionArea(
                context,
                itemValue: widget.itemValue,
              ),
            ],
          );
  }

  /// データリロード処理
  /*
  void reloadData({CityInfo? cityParam, TemperatureUnit? temprtUnit}) {
    setState(() {
      if (cityParam != null) {
        _cityParam.zip = cityParam.zip;
        _cityParam.name = cityParam.name;
        _cityParam.nameDesc = cityParam.nameDesc;
        _cityParam.countryCode = cityParam.countryCode;
        _cityParam.isFavorite = cityParam.isFavorite;
      }

      if (temprtUnit != null) {
        _temprtUnit = TemperatureUnit.values[temprtUnit.index];
      }
      // reload this banner due to parameter changed.
      if (_reloaderKey.currentState != null && !_isTabFirstAppeared) {
        _reloaderKey.currentState?.reload();
      }
    });
  }*/

/*
  Widget _buildMessageArea(
      {required BuildContext context,
      String? message,
      bool? needsReload = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 20),
        Container(
            alignment: Alignment.center,
            child: Text(
              message ?? '',
            )),
      ],
    );
  }*/

/*
  Future<void> _readPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    await CityUtil().readCityInfoFromPref(isDefault: true);

    setState(() {
      // CityInfo
      _cityParam.zip = CityUtil().savedCity?.zip ?? '';
      _cityParam.name = CityUtil().savedCity?.name ?? '';
      _cityParam.nameDesc = CityUtil().savedCity?.nameDesc ?? '';
      _cityParam.countryCode = CityUtil().savedCity?.countryCode ?? '';
      _cityParam.isFavorite = CityUtil().savedCity?.isFavorite ?? false;

      // Tempreture Unit
      _temprtUnit = (prefs.getInt('temprtUnit') != null
          ? TemperatureUnit.values[prefs.getInt('temprtUnit') ?? 0]
          : TemperatureUnit.celsius);
    });
  }
  */

/*
  Future<void> _savePrefsData({CityInfo? cityValue}) async {
    if (cityValue == null) {
      return;
    }
    setState(() {
      _cityParam.zip = cityValue.zip;
      _cityParam.name = cityValue.name;
      _cityParam.nameDesc = cityValue.nameDesc;
      _cityParam.countryCode = cityValue.countryCode;
      _cityParam.isFavorite = cityValue.isFavorite;
    });
  }*/

  Widget _buildWeatherTopArea({WeatherInfo? itemValue}) {
    List<Widget> wlist = <Widget>[
      const SizedBox(width: 10),
      Text(
        '${DateUtil().getDateMdeString()} ',
        style: _createTextStyle(fontSize: 16.0, color: Colors.black54),
      ),
      const Spacer(),
      Text(
        UseL10n.of(context)?.infoServiceWeatherLabelHumidity ?? '',
        style: _createTextStyle(fontSize: 11.0, color: Colors.black38),
      ),
      const Spacer(),
      Text('${itemValue?.humidity}% ',
          style: _createTextStyle(fontSize: 16.0, color: Colors.black54)),
    ];

    if (itemValue?.hasPrecit ?? false) {
      wlist.addAll([
        const Spacer(),
        Text(
          '${itemValue?.getPrecipLabel()} ',
          style: _createTextStyle(fontSize: 11.0, color: Colors.black54),
        ),
        const Spacer(),
        Text('${itemValue?.getPrecipValue()}',
            style: _createTextStyle(fontSize: 16.0, color: Colors.black54))
      ]);
    } else {
      wlist.addAll([
        const Spacer(),
        Text(
          UseL10n.of(context)?.infoServiceWeatherLabelWindSpeed ?? '',
          style: _createTextStyle(fontSize: 11.0, color: Colors.black38),
        ),
        const Spacer(),
        Text('${itemValue?.windSpeed} ',
            style: _createTextStyle(fontSize: 14.0, color: Colors.black54)),
        Text('m/s (${itemValue?.getWindDirectionValue()})',
            style: _createTextStyle(fontSize: 11.0, color: Colors.black54)),
      ]);
    }
    wlist.add(const Padding(
      padding: EdgeInsets.only(right: 10.0),
    ));

    final double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(width: screenWidth - 20, child: Row(children: wlist));
  }

  Widget _buildWeatherContentArea(BuildContext context,
      {WeatherInfo? itemValue}) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
        width: screenWidth - 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Container(
                constraints: BoxConstraints(
                    minWidth: 80,
                    maxWidth: () {
                      if (screenWidth <= 280) return 110.0;
                      if (screenWidth <= 360) return 150.0;
                      if (screenWidth <= 420) {
                        return 180.0;
                      } else {
                        return 250.0;
                      }
                    }()),
                child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${itemValue?.city?.name}',
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: _createTextStyle(
                                fontSize: 19.0, color: Colors.black54)),
                      ),
                      Text('${itemValue?.getWeatherDesc()}',
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: _createTextStyle(
                              fontSize: 11.0, color: Colors.black54)),
                    ],
                  ),
                  onTap: () {
                    // setState(() {
                    //   widget.onCellEditing?.call();
                    // });
                  },
                )),
            const Spacer(),
            Text('${itemValue?.temperature?.as(widget.temprtUnit).round()}°',
                style: _createTextStyle(fontSize: 40.0, color: Colors.black54)),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Icon(
                  itemValue?.getIconData(),
                  color: Colors.black54,
                  size: 30,
                )),
            const Spacer(),
            Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        '${itemValue?.maxTemperature?.as(widget.temprtUnit).round()}°',
                        style: _createTextStyle(
                            fontSize: 16.0, color: Colors.black54)),
                    Text(
                        '${itemValue?.minTemperature?.as(widget.temprtUnit).round()}°',
                        style: _createTextStyle(
                            fontSize: 16.0, color: Colors.black54)),
                  ],
                )),
            const Spacer(),
          ],
        ));
  }

  Widget _buildWeatherFunctionArea(BuildContext context,
      {WeatherInfo? itemValue}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: screenWidth - 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: TextButton(
                child: Text(
                    UseL10n.of(context)
                            ?.infoServiceWeatherLabelWeeklyForecast ??
                        '',
                    style: _createTextStyle(
                        fontSize: 18.0,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black)),
                onPressed: () => widget.onPresentWeeklyForecast?.call(),
              ),
            ),
            const Spacer(),
            Text(
              UseL10n.of(context)?.infoServiceWeatherLabelApparent ?? '',
              style: _createTextStyle(fontSize: 11.0, color: Colors.black38),
            ),
            const Spacer(),
            Text('${itemValue?.feelsLike?.as(widget.temprtUnit).round()}°',
                style: _createTextStyle(fontSize: 20.0, color: Colors.black54)),
            const Spacer(),
            Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        UseL10n.of(context)?.infoServiceWeatherLabelSunshine ??
                            '',
                        style: _createTextStyle(
                            fontSize: 11.0, color: Colors.black38)),
                    Text('${itemValue?.getSunriseFormattedString()}',
                        style: _createTextStyle(
                            fontSize: 16.0, color: Colors.black54)),
                  ],
                )),
            const Spacer(),
            Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        UseL10n.of(context)?.infoServiceWeatherLabelSunset ??
                            '',
                        style: _createTextStyle(
                            fontSize: 11.0, color: Colors.black38)),
                    Text('${itemValue?.getSunsetFormattedString()}',
                        style: _createTextStyle(
                            fontSize: 16.0, color: Colors.black54)),
                  ],
                )),
            const Spacer(),
          ],
        ));
  }

  TextStyle _createTextStyle(
      {required double fontSize,
      required Color color,
      Color? decorationColor,
      TextDecoration? decoration}) {
    return TextStyle(
        inherit: false,
        fontSize: fontSize,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor ?? const Color(0xFFD0D0D0));
  }
}
