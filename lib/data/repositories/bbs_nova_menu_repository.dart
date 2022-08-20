import 'dart:convert';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/base_nova_web_api.dart';
import 'package:ses_novajoj/domain/entities/bbs_nova_menu_item.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_menu_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/app_state.dart';

class MyWebApi {}

class BbsNovaMenuRepositoryImpl extends BbsNovaMenuRepository {
  final BaseNovaWebApi _api;

  // sigleton
  static final BbsNovaMenuRepositoryImpl _instance =
      BbsNovaMenuRepositoryImpl._internal();
  BbsNovaMenuRepositoryImpl._internal() : _api = BaseNovaWebApi();
  factory BbsNovaMenuRepositoryImpl() => _instance;

  @override
  Future<Result<List<BbsNovaMenuItem>>> fetchBbsNovaMenuList(
      {required FetchBbsNovaMenuRepoInput input}) async {
    final Result<String> retSetting = await _api.fetchBbsMenuSettings();
    String settingJson = '';
    retSetting.when(
        success: (value) => settingJson = value, failure: (error) {});
    if (settingJson.isEmpty) {
      return Result.failure(
          error: AppError(
              type: AppErrorType.dataError,
              reason: FailureReason.missingBbsMenuNode));
    }

    final jsonData = await json.decode(settingJson);
    final menuItems = jsonData['bbs_menu'];
    final menuLang = jsonData['menu_lang'];

    if (menuItems == null) {
      return Result.failure(
          error: AppError(
              type: AppErrorType.dataError,
              reason: FailureReason.missingBbsMenuNode));
    }
    if (menuLang == null) {
      return Result.failure(
          error: AppError(
              type: AppErrorType.dataError,
              reason: FailureReason.missingBbsLangNode));
    }
    final langItems = menuLang[input.langCode];
    if (langItems == null) {
      return Result.failure(
          error: AppError(
              type: AppErrorType.dataError,
              reason: FailureReason.missingBbsLangNode));
    }
    final menuList = menuItems as List<dynamic>?;
    final langItemList = langItems as List<dynamic>?;
    final menuList_ =
        menuList?.map((element) => BbsNovaMenuItem.fromJson(element)).toList();

    List<BbsNovaMenuItem> retLangItemList = [];
    var langItemList_ = langItemList
        ?.map((element) => BbsNovaMenuItem.fromJson(element))
        .toList();
    menuList_?.asMap().forEach((index, value) {
      langItemList_?[index].urlString = menuList_[index].urlString;
      if (langItemList_?[index] != null) {
        if (AppState.isLogined) {
          if (menuList_[index].urlString != '-') {
            retLangItemList.add(langItemList_![index]);
          }
        } else {
          if (menuList_[index].accessFlag) {
            retLangItemList.add(langItemList_![index]);
          }
        }
      }
    });

    Result<List<BbsNovaMenuItem>> result =
        Result.success(data: retLangItemList);
    return result;
  }
}
