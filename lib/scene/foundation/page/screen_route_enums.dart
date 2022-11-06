/// Router Name Enum
enum ScreenRouteName {
  splash,
  login,
  home,
  tabs,
  topDetail,
  localList,
  threadList,
  threadDetail,
  bbsGuide,
  bbsDetail,
  bbsSelectList,
  citySelect,
  miscInfoSelect,
  weeklyReport,
  historio,
  favorites,
  webPage,
}

extension ScreenRouteNameSummary on ScreenRouteName {
  String get name {
    switch (this) {
      case ScreenRouteName.splash:
        return 'splash';
      case ScreenRouteName.login:
        return 'login';
      case ScreenRouteName.home:
        return '/';
      case ScreenRouteName.tabs:
        return 'tabs';
      case ScreenRouteName.topDetail:
        return 'topDetail';
      case ScreenRouteName.localList:
        return 'localList';
      case ScreenRouteName.threadList:
        return 'threadList';
      case ScreenRouteName.threadDetail:
        return 'threadDetail';
      case ScreenRouteName.bbsGuide:
        return 'bbsGuide';
      case ScreenRouteName.bbsDetail:
        return 'bbsDetail';
      case ScreenRouteName.bbsSelectList:
        return 'bbsSelectList';
      case ScreenRouteName.citySelect:
        return 'citySelect';
      case ScreenRouteName.miscInfoSelect:
        return 'miscInfoSelect';
      case ScreenRouteName.weeklyReport:
        return 'weeklyReport';
      case ScreenRouteName.historio:
        return 'historio';
      case ScreenRouteName.favorites:
        return 'favorites';
      case ScreenRouteName.webPage:
        return 'webPage';
      default:
        return '';
    }
  }

  static ScreenRouteName fromString(String string) {
    return ScreenRouteName.values
        .firstWhere((element) => element.name == string);
  }

  String? get stringClass {
    switch (this) {
      case ScreenRouteName.splash:
      case ScreenRouteName.home:
      case ScreenRouteName.login:
      case ScreenRouteName.tabs:
      case ScreenRouteName.topDetail:
      case ScreenRouteName.localList:
      case ScreenRouteName.threadList:
      case ScreenRouteName.threadDetail:
      case ScreenRouteName.bbsGuide:
      case ScreenRouteName.bbsDetail:
      case ScreenRouteName.bbsSelectList:
      case ScreenRouteName.citySelect:
      case ScreenRouteName.miscInfoSelect:
      case ScreenRouteName.weeklyReport:
      case ScreenRouteName.historio:
      case ScreenRouteName.favorites:
      case ScreenRouteName.webPage:
        return toString().split(".").last;
      default:
        return null;
    }
  }
}
