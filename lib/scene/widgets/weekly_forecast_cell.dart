import 'package:flutter/material.dart';

import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/scene/foundation/data/weather_util.dart';

class WeeklyForecastCell extends StatefulWidget {
  final List<WeatherInfo>? weeklyForecastValue;
  final TemperatureUnit temprtUnit;

  const WeeklyForecastCell(
      {Key? key, this.weeklyForecastValue, required this.temprtUnit})
      : super(key: key);

  @override
  State<WeeklyForecastCell> createState() => _WeeklyForecastCellState();
}

class _WeeklyForecastCellState extends State<WeeklyForecastCell> {
  List<WeatherInfo>? _weeklyForecastValue;
  late TemperatureUnit _temprtUnit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _weeklyForecastValue = widget.weeklyForecastValue;
    _temprtUnit = widget.temprtUnit;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(_weeklyForecastValue != null &&
                  (_weeklyForecastValue?.isNotEmpty ?? false)
              ? '${_weeklyForecastValue?.first.getDataFormattedString()} 〜 ${_weeklyForecastValue?.last.getDataFormattedString()}'
              : ''),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _weeklyForecastValue?.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return _buildHourlyItem(context, index);
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(BuildContext context, int index) {
    WeatherInfo? weeklyValue = _weeklyForecastValue?[index];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
            width: 70, child: Text('${weeklyValue?.getDataFormattedString()}')),
        Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          child: Icon(
            weeklyValue?.getIconData(),
            color: Colors.black45,
            size: 35,
          ),
        ),
        Text(
            '${weeklyValue?.maxTemperatureOfForecast?.as(_temprtUnit).round()}°'),
        Text(
          '${weeklyValue?.minTemperatureOfForecast?.as(_temprtUnit).round()}°',
          style: const TextStyle(color: Colors.black38),
        ),
      ],
    );
  }
}
