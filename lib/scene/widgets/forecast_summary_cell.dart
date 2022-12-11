import 'package:flutter/material.dart';

import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/data/weather_util.dart';

typedef CellEditingDelegate = void Function(
    bool cityChanged, dynamic temprtUnit);

class ForecastSummaryCell extends StatefulWidget {
  final WeatherInfo? itemValue;
  final TemperatureUnit? temprtUnit;
  final CellEditingDelegate? onCellEditing;

  const ForecastSummaryCell(
      {Key? key, this.itemValue, this.temprtUnit, this.onCellEditing})
      : super(key: key);

  @override
  State<ForecastSummaryCell> createState() => _ForecastSummaryCellState();
}

class _ForecastSummaryCellState extends State<ForecastSummaryCell> {
  WeatherInfo? _itemValue;
  TemperatureUnit? _temprtUnit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _itemValue = widget.itemValue;
    _temprtUnit = widget.temprtUnit;
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

    return Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(children: <Widget>[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: 5),
              Text(
                '${DateUtil().getDateMdeString()} ',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
              ),
              const Spacer(),
              Text(
                  '${_itemValue?.temperature?.as(_temprtUnit ?? TemperatureUnit.celsius).round()}°',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 50.0)),
              const Spacer(),
              Container(
                  constraints:
                      BoxConstraints(minWidth: 80, maxWidth: leftSideWidth),
                  padding: const EdgeInsets.only(right: 5.0),
                  child: GestureDetector(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${_itemValue?.city?.nameDesc}',
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 24.0)),
                        _itemValue?.city?.state.isEmpty ?? false
                            ? const SizedBox()
                            : Container(
                                padding:
                                    const EdgeInsets.only(top: 6, right: 8),
                                alignment: Alignment.center,
                                width: leftSideWidth * 0.7,
                                child: Text(
                                    '${_itemValue?.city?.state}, ${_itemValue?.city?.countryCode}',
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        inherit: false,
                                        fontSize: 10,
                                        color: Colors.black54,
                                        decorationColor: Color(0xFFD0D0D0))),
                              ),
                        Text('${_itemValue?.getWeatherDesc()}',
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14.0, color: Colors.black45)),
                      ],
                    ),
                    onTap: () {},
                  )),
            ],
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 65,
                child: Text(
                    '${_itemValue?.maxTemperature?.as(_temprtUnit ?? TemperatureUnit.celsius).round()}°',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16.0)),
              ),
              const Spacer(),
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Icon(
                    _itemValue?.getIconData(),
                    color: Colors.black45,
                    size: 35,
                  )),
              const Spacer(),
              SizedBox(
                width: 65,
                child: Text(
                    '${_itemValue?.minTemperature?.as(_temprtUnit ?? TemperatureUnit.celsius).round()}°',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 16.0, color: Colors.black45)),
              ),
              const Spacer(flex: 2),
              Container(
                  margin: const EdgeInsets.only(right: 0.0),
                  width: 50.0,
                  child: TextButton(
                    child: Text(
                      '°C',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _temprtUnit == TemperatureUnit.celsius
                            ? Colors.blueAccent
                            : Colors.blueAccent.withAlpha(100),
                        fontWeight: _temprtUnit == TemperatureUnit.celsius
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      widget.onCellEditing
                          ?.call(false, TemperatureUnit.celsius);
                    },
                  )),
              SizedBox(
                  width: 50.0,
                  child: TextButton(
                    child: Text(
                      '°F',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _temprtUnit == TemperatureUnit.fahrenheit
                            ? Colors.blueAccent
                            : Colors.blueAccent.withAlpha(100),
                        fontWeight: _temprtUnit == TemperatureUnit.fahrenheit
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      widget.onCellEditing
                          ?.call(false, TemperatureUnit.fahrenheit);
                    },
                  )),
            ],
          ),
        ]));
  }
}
