import 'package:flutter/material.dart';

import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/data/weather_util.dart';

class HourlyForecastCell extends StatefulWidget {
  final List<WeatherInfo>? hourlyForecastValue;
  final TemperatureUnit? temprtUnit;

  const HourlyForecastCell(
      {Key? key, this.hourlyForecastValue, this.temprtUnit})
      : super(key: key);

  @override
  State<HourlyForecastCell> createState() => _HourlyForecastCellState();
}

class _HourlyForecastCellState extends State<HourlyForecastCell> {
  List<WeatherInfo>? _hourlyForecastValue;
  TemperatureUnit? _temprtUnit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _hourlyForecastValue = widget.hourlyForecastValue ?? [];
    _temprtUnit = widget.temprtUnit ?? TemperatureUnit.celsius;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _hourlyForecastValue?.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return _buildHourlyItem(context, index);
          }),
    );
  }

  Widget _buildHourlyItem(BuildContext context, int index) {
    WeatherInfo hourValue = (_hourlyForecastValue?.length ?? 0) > index
        ? _hourlyForecastValue![index]
        : WeatherInfo();

    return Column(
      children: <Widget>[
        Text(hourValue.getTimeFormattedString()),
        Container(
          padding: const EdgeInsets.only(bottom: 15.0),
          width: 60,
          height: 60,
          child: Icon(
            hourValue.getIconData(),
            color: Colors.black45,
            size: 35,
          ),
        ),
        Text('${hourValue.temperature?.as(_temprtUnit!).round()}°'),
      ],
    );
  }
}
