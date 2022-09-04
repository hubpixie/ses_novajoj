import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

/// アナリティクスイベント
enum AnalyticsEvent {
  button,
}

enum AnalyticsRoute {
  splash,
  topList,
  topDetail,
  localList,
  localDetail,
  threadList,
  threadDetail,
  bbsDetail,
  bbsSelectList,
  citySelect,
  miscInfoSelect,
  webPage,
}

extension AnalyticsRouteInfo on AnalyticsRoute {
  String get screenName {
    switch (this) {
      case AnalyticsRoute.splash:
        return '/splash';
      case AnalyticsRoute.topList:
        return '/topList';
      case AnalyticsRoute.topDetail:
        return '/topDetail';
      case AnalyticsRoute.localList:
        return '/localList';
      case AnalyticsRoute.bbsDetail:
        return '/bbsDetail';
      case AnalyticsRoute.bbsSelectList:
        return '/bbsSelectList';
      case AnalyticsRoute.miscInfoSelect:
        return '/miscInfoSelect';
      case AnalyticsRoute.citySelect:
        return '/miscInfoSelect';
      case AnalyticsRoute.webPage:
        return '/webPage';
      default:
        return '';
    }
  }

  String get screenClass {
    switch (this) {
      case AnalyticsRoute.splash:
      case AnalyticsRoute.topList:
      case AnalyticsRoute.topDetail:
      case AnalyticsRoute.localList:
      case AnalyticsRoute.bbsDetail:
      case AnalyticsRoute.bbsSelectList:
      case AnalyticsRoute.citySelect:
      case AnalyticsRoute.miscInfoSelect:
      case AnalyticsRoute.webPage:
        return toString().split(".")[1];
      default:
        return '';
    }
  }
}

/// アナリティクス
class FirebaseUtil {
  factory FirebaseUtil() {
    if (_instanceEnbled) {
      _instance._analytics = FirebaseAnalytics();
      _instance._observer =
          FirebaseAnalyticsObserver(analytics: _instance._analytics);
      _instanceEnbled = false;
    }
    return _instance;
  }
  FirebaseUtil._();

  static final _instance = FirebaseUtil._();
  static bool _instanceEnbled = true;

  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  FirebaseAnalytics get analytics => _instance._analytics;
  FirebaseAnalyticsObserver get observer => _instance._observer;
  List<FirebaseAnalyticsObserver> get observers =>
      kIsWeb ? [] : [_instance._observer];

  /// 画面遷移時に画面名を送信
  Future<void> sendViewEvent({required AnalyticsRoute route}) async {
    if (kIsWeb) {
      return;
    }
    _analytics.setCurrentScreen(
        screenName: route.screenName, screenClassOverride: route.screenClass);
  }

  /// ボタンタップイベント送信
  Future<void> sendButtonEvent({required String buttonName}) async {
    if (kIsWeb) {
      return;
    }
    sendEvent(
        event: AnalyticsEvent.button, parameterMap: {'buttonName': buttonName});
  }

  /// イベントを送信する
  /// [event] AnalyticsEvent
  /// [parameterMap] パラメータMap
  Future<void> sendEvent(
      {required AnalyticsEvent event,
      Map<String, dynamic>? parameterMap}) async {
    final eventName = event.toString().split('.')[1];
    analytics.logEvent(name: eventName, parameters: parameterMap);
  }
}
