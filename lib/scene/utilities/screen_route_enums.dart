/// 遷移元画面クラス
enum ScreenRouteName {
  splash,
  login,
  home,
  tabs,
  topDetail,
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
      case ScreenRouteName.home:
      case ScreenRouteName.login:
      case ScreenRouteName.tabs:
      case ScreenRouteName.topDetail:
        return toString().split(".").last;
      default:
        return null;
    }
  }
}
