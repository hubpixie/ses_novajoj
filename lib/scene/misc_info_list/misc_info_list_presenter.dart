import 'package:ses_novajoj/domain/usecases/bbs_nova_detail_usecase.dart';
import 'package:ses_novajoj/domain/usecases/bbs_nova_detail_usecase_output.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase_output.dart';
import 'misc_info_list_presenter_output.dart';

import 'misc_info_list_router.dart';

class MiscInfoListPresenterInput {
  String appBarTitle;
  List<MiscInfoListViewModel>? viewModelList;
  int itemIndex;
  ServiceType serviceType;
  Object? completeHandler;
  MiscInfoListPresenterInput(
      {this.appBarTitle = '',
      this.viewModelList,
      this.itemIndex = 0,
      this.serviceType = ServiceType.none,
      this.completeHandler});
}

abstract class MiscInfoListPresenter
    with SimpleBloc<MiscInfoListPresenterOutput> {
  void eventViewReady({required MiscInfoListPresenterInput input});
  void eventViewReportPage(Object context,
      {required MiscInfoListPresenterInput input});
  void eventViewWebPage(Object context,
      {required MiscInfoListPresenterInput input});
  void eventViewHistorioPage(Object context,
      {required MiscInfoListPresenterInput input});
  void eventViewHistorioWebPage(Object context,
      {required MiscInfoListPresenterInput input});
  void eventViewFavoritesPage(Object context,
      {required MiscInfoListPresenterInput input});
  void eventViewFavoritesWebPage(Object context,
      {required MiscInfoListPresenterInput input});
}

class MiscInfoListPresenterImpl extends MiscInfoListPresenter {
  final MiscInfoListUseCase useCase;
  final HistorioUseCase hisUseCase;
  final FavoritesUseCase favoriteUseCase;
  final BbsNovaDetailUseCase bbsNovaDetailUseCase;
  final MiscInfoListRouter router;

  MiscInfoListPresenterImpl({required this.router})
      : useCase = MiscInfoListUseCaseImpl(),
        favoriteUseCase = FavoritesUseCaseImpl(),
        hisUseCase = HistorioUseCaseImpl(),
        bbsNovaDetailUseCase = BbsNovaDetailUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowMiscInfoListPageModel(
              viewModelList: event.model
                  ?.map((row) => MiscInfoListViewModel(row))
                  .toList()));
        } else {
          streamAdd(ShowMiscInfoListPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required MiscInfoListPresenterInput input}) {
    useCase.fetchMiscInfoList(input: MiscInfoListUseCaseInput());
  }

  @override
  void eventViewReportPage(Object context,
      {required MiscInfoListPresenterInput input}) {
    _viewSelectPage(context, input: input);
  }

  @override
  void eventViewWebPage(Object context,
      {required MiscInfoListPresenterInput input}) {
    _viewSelectPage(context, input: input);
  }

  @override
  void eventViewHistorioPage(Object context,
      {required MiscInfoListPresenterInput input}) {
    router.gotoHistorioPage(context,
        itemInfos: input.viewModelList,
        appBarTitle: input.appBarTitle,
        completeHandler: input.completeHandler);
  }

  @override
  void eventViewHistorioWebPage(Object context,
      {required MiscInfoListPresenterInput input}) async {
    // remove selected favorite if need
    final itemInfo = input.viewModelList?[input.itemIndex].itemInfo;

    // set innerLinkDetail closure into the itemInfo
    itemInfo?.innerLinkDetail = (innerLinkUrl) async {
      return await _fetchInnerDetailInfo(
          itemInfo: itemInfo,
          innerUrl: innerLinkUrl,
          cateory:
              input.viewModelList?[input.itemIndex].hisInfo?.category ?? '',
          isFavorite: false);
    };

    final bodyString =
        await UserData().readHistorioData(url: itemInfo?.urlString ?? '');
    HistorioInfo? bookmark = input.viewModelList?[input.itemIndex].hisInfo;
    bookmark?.htmlText = bodyString;

    void changeFavoriteAction() {
      favoriteUseCase.saveBookmark(
          input: FavoritesUseCaseInput(bookmark: bookmark));
    }

    void removeAction() {
      // remove selected favorite
      UserData().removeHistorio(url: itemInfo?.urlString ?? '');
    }

    router.gotoHistorioWebPage(context,
        itemInfo: itemInfo,
        htmlText: await hisUseCase.fetchHtmlTextWithScript(
            input: HistorioUseCaseInput(
                itemInfo: itemInfo, bodyString: bodyString)),
        changeFavoriteAction:
            itemInfo?.isFavorite == false ? changeFavoriteAction : null,
        removeAction: removeAction,
        appBarTitle: input.appBarTitle,
        completeHandler: input.completeHandler);
  }

  @override
  void eventViewFavoritesPage(Object context,
      {required MiscInfoListPresenterInput input}) {
    router.gotoFavoritesPage(context,
        itemInfos: input.viewModelList,
        appBarTitle: input.appBarTitle,
        completeHandler: input.completeHandler);
  }

  @override
  void eventViewFavoritesWebPage(Object context,
      {required MiscInfoListPresenterInput input}) async {
    // get itemInfo
    final itemInfo = input.viewModelList?[input.itemIndex].itemInfo;

    // set innerLinkDetail closure into the itemInfo
    itemInfo?.innerLinkDetail = (innerLinkUrl) async {
      return await _fetchInnerDetailInfo(
          itemInfo: itemInfo,
          innerUrl: innerLinkUrl,
          cateory:
              input.viewModelList?[input.itemIndex].bookmark?.category ?? '',
          isFavorite: true);
    };

    // remove selected favorite if need
    void removeAction() {
      // remove selected favorite
      UserData().saveFavorites(bookmark: '', url: itemInfo?.urlString);
    }

    final bodyString =
        await UserData().readFavoriteData(url: itemInfo?.urlString ?? '');

    router.gotoFavoritesWebPage(context,
        itemInfo: itemInfo,
        htmlText: await hisUseCase.fetchHtmlTextWithScript(
            input: HistorioUseCaseInput(
                itemInfo: itemInfo, bodyString: bodyString)),
        removeAction: removeAction,
        appBarTitle: input.appBarTitle,
        completeHandler: input.completeHandler);
  }

  void _viewSelectPage(Object context,
      {required MiscInfoListPresenterInput input}) {
    final itemInfos = input.viewModelList?.where((element) =>
        element.itemInfo.serviceType == input.serviceType &&
        element.itemInfo.orderIndex == input.itemIndex);

    void removeAction() {
      UserData().saveUserInfoList(
          newValue: input.serviceType == ServiceType.weather
              ? CityInfo()
              : SimpleUrlInfo(),
          order: input.itemIndex,
          allowsRemove: true,
          serviceType: input.serviceType);
    }

    NovaItemInfo? itemInfo;
    if (itemInfos == null || itemInfos.isEmpty || input.itemIndex == -1) {
      if (input.serviceType == ServiceType.weather) {
        itemInfo = CityInfo().toItemInfo(
            orderIndex: input.itemIndex, serviceType: input.serviceType);
      } else {
        itemInfo = SimpleUrlInfo().toItemInfo(
            orderIndex: input.itemIndex, serviceType: input.serviceType);
      }
    } else {
      itemInfo = itemInfos.first.itemInfo;
    }
    if (input.itemIndex == -1) {
      if (input.serviceType == ServiceType.weather) {
        router.gotoCitySelectPage(context,
            appBarTitle: input.appBarTitle,
            itemInfo: itemInfo,
            completeHandler: input.completeHandler);
      } else {
        router.gotoSelectPage(context,
            appBarTitle: input.appBarTitle,
            itemInfo: itemInfo,
            completeHandler: input.completeHandler);
      }
      return;
    }

    // transit the screen page via router
    if (input.serviceType == ServiceType.weather) {
      router.gotoReportPage(context,
          appBarTitle: input.appBarTitle,
          itemInfo: itemInfo,
          removeAction: removeAction,
          completeHandler: input.completeHandler);
    } else {
      router.gotoWebPage(context,
          appBarTitle: input.appBarTitle,
          itemInfo: itemInfo,
          removeAction: [ServiceType.audio].contains(input.serviceType)
              ? null
              : removeAction,
          completeHandler: input.completeHandler);
    }
  }

  Future<String> _fetchInnerDetailInfo(
      {required NovaItemInfo itemInfo,
      required String innerUrl,
      required String cateory,
      bool isFavorite = false}) async {
    itemInfo.previousUrlString = itemInfo.urlString;
    itemInfo.urlString = innerUrl;
    itemInfo.isInnerLink = true;
    if ((itemInfo.innerLinks ?? []).contains(innerUrl)) {
      String bodyString;
      if (isFavorite) {
        bodyString = await UserData().readFavoriteData(
            url: itemInfo.previousUrlString ?? '', innerUrl: innerUrl);
      } else {
        bodyString = await UserData().readHistorioData(
            url: itemInfo.previousUrlString ?? '', innerUrl: innerUrl);
      }
      return await hisUseCase.fetchHtmlTextWithScript(
          input:
              HistorioUseCaseInput(itemInfo: itemInfo, bodyString: bodyString));
    } else {
      if (cateory == 'bbs') {
        BbsNovaDetailUseCaseOutput output =
            await bbsNovaDetailUseCase.fetchBbsNovaInnerDetail(
                input: BbsNovaDetailUseCaseInput(itemInfo: itemInfo));
        if (output is BbsNovaDetaiPresentModel) {
          return output.model?.htmlText ?? '';
        }
      }
    }
    return '';
  }
}
