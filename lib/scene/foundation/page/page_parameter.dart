enum TopDetailParamKeys { source, appBarTitle, itemInfo }

enum ThreadDetailParamKeys { appBarTitle, itemInfo }

enum BbsDetailParamKeys { appBarTitle, itemInfo }

enum BbsSelectListParamKeys { appBarTitle, targetUrl }

enum CitySelectParamKeys { appBarTitle, itemInfo, sourceRoute }

enum MiscInfoSelectParamKeys { appBarTitle, itemInfo }

enum HistorioParamKeys { appBarTitle, itemInfos, sourceRoute }

enum FavoritesParamKeys { appBarTitle, itemInfos, sourceRoute }

enum WeeklyReportParamKeys { appBarTitle, itemInfo, menuItems, menuActions }

enum WebPageParamKeys {
  appBarTitle,
  itemInfo,
  htmlText,
  menuItems,
  menuActions
}

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
