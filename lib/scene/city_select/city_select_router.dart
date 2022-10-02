import 'package:flutter/material.dart';

abstract class CitySelectRouter {
  void gotoMiscListPage(Object context,
      {Object? itemInfo, Object? completeHandler});
  void gotoWeeklyReportPage(Object context,
      {Object? itemInfo, Object? completeHandler});
}

class CitySelectRouterImpl extends CitySelectRouter {
  CitySelectRouterImpl();

  @override
  void gotoMiscListPage(Object context,
      {Object? itemInfo, Object? completeHandler}) {
    BuildContext context_ = context as BuildContext;
    Navigator.of(context_).pop();
  }

  @override
  void gotoWeeklyReportPage(Object context,
      {Object? itemInfo, Object? completeHandler}) {
    BuildContext context_ = context as BuildContext;
    Navigator.of(context_).pop(itemInfo);
  }
}
