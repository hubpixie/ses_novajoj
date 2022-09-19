import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    final leftSideWidth = () {
      if (screenWidth <= 280) return 110.0;
      if (screenWidth <= 360) return 150.0;
      if (screenWidth <= 420) {
        return 210.0;
      } else {
        return 250.0;
      }
    }();
    return SizedBox(
        width: screenWidth - 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                constraints:
                    BoxConstraints(minWidth: 80, maxWidth: leftSideWidth),
                child: GestureDetector(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${itemValue?.city?.nameDesc}',
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: _createTextStyle(
                                  fontSize: 19.0, color: Colors.black54)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              itemValue?.city?.state.isEmpty ?? false
                                  ? const SizedBox()
                                  : Container(
                                      padding: const EdgeInsets.only(
                                          top: 6, right: 8),
                                      alignment: Alignment.center,
                                      width: leftSideWidth - 20,
                                      child: Text(
                                          '${itemValue?.city?.state}, ${itemValue?.city?.countryCode}',
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          style: _createTextStyle(
                                              fontSize: 10.0,
                                              color: Colors.black54)),
                                    ),
                            ],
                          ),
                          Text('${itemValue?.getWeatherDesc()}',
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: _createTextStyle(
                                  fontSize: 14.0, color: Colors.black54)),
                        ],
                      )),
                  onTap: () {
                    // setState(() {
                    //   widget.onCellEditing?.call();
                    // });
                  },
                )),
            Text('${itemValue?.temperature?.as(widget.temprtUnit).round()}°',
                style: _createTextStyle(fontSize: 32.0, color: Colors.black54)),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  itemValue?.getIconData(),
                  color: Colors.black54,
                  size: 30,
                )),
            const Spacer(),
            Container(
                width: 32,
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
