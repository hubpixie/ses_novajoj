enum TopDetailParamKeys { source, appBarTitle, itemInfo }

enum ThreadDetailParamKeys { appBarTitle, itemInfo }

enum BbsDetailParamKeys { appBarTitle, itemInfo }

enum BbsSelectListParamKeys { appBarTitle, targetUrl }

enum CitySelectParamKeys { appBarTitle, itemInfo }

enum MiscInfoSelectParamKeys { appBarTitle, itemInfo }

enum WebPageParamKeys { appBarTitle, itemInfo, menuItems, menuActions }

enum WeeklyReportParamKeys { appBarTitle, itemInfo, menuItems, menuActions }

enum DetailMenuItem {
  openOriginal,
  readComments,
  changeSettings,
  removeSettings
}

class PageParameter<T> {
  PageParameter({required this.key, this.value});

  final String key;
  T? value;
}
