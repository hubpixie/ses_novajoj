import 'package:ses_novajoj/data/repositories/favorites_repository.dart';
import 'package:ses_novajoj/data/repositories/historio_repository.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_detail_repository.dart';
import 'package:ses_novajoj/data/repositories/bbs_nova_detail_repository.dart';
import 'package:ses_novajoj/domain/repositories/favorites_repository.dart';
import 'package:ses_novajoj/domain/repositories/historio_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'bbs_nova_detail_usecase_output.dart';

class BbsNovaDetailUseCaseInput {
  NovaItemInfo itemInfo;
  String? htmlText;
  bool favoriteIsEnabled;

  BbsNovaDetailUseCaseInput(
      {required this.itemInfo, this.htmlText, this.favoriteIsEnabled = false});
}

abstract class BbsNovaDetailUseCase
    with SimpleBloc<BbsNovaDetailUseCaseOutput> {
  void fetchBbsNovaDetail({required BbsNovaDetailUseCaseInput input});
  Future<BbsNovaDetailUseCaseOutput> fetchBbsNovaInnerDetail(
      {required BbsNovaDetailUseCaseInput input});
  bool saveBookmark({required BbsNovaDetailUseCaseInput input});
}

class BbsNovaDetailUseCaseImpl extends BbsNovaDetailUseCase {
  final BbsNovaDetailRepository repository;
  final FavoritesRepository favoriteRepository;
  final HistorioRepository historioRepository;
  BbsNovaDetailUseCaseImpl()
      : repository = BbsNovaDetailRepositoryImpl(),
        favoriteRepository = FavoritesRepositoryImpl(),
        historioRepository = HistorioRepositoryImpl();

  @override
  void fetchBbsNovaDetail({required BbsNovaDetailUseCaseInput input}) async {
    final result = await repository.fetchBbsNovaDetail(
        input: FetchBbsNovaDetailRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.detail));

    result.when(success: (value) {
      // set result
      streamAdd(BbsNovaDetaiPresentModel(
          model:
              BbsNovaDetailUseCaseModel(value.itemInfo, value.toHtmlString())));
      // save history
      bool savedFlg = true;
      if (input.itemInfo.isInnerLink) {
        List<String> innerLinks = value.itemInfo.innerLinks ?? [];
        if (!innerLinks.contains(input.itemInfo.urlString)) {
          innerLinks.add(input.itemInfo.urlString);
          value.itemInfo.innerLinks = innerLinks;
        } else {
          savedFlg = false;
        }
      }
      if (savedFlg) {
        historioRepository.saveNovaDetailHistory(
            input: FetchHistorioRepoInput(
                itemInfo: value.itemInfo,
                bodyString: value.bodyString,
                category: 'bbs',
                isUpdate: input.itemInfo.isInnerLink));
      }
    }, failure: (error) {
      streamAdd(BbsNovaDetaiPresentModel(error: error));
    });
  }

  @override
  Future<BbsNovaDetailUseCaseOutput> fetchBbsNovaInnerDetail(
      {required BbsNovaDetailUseCaseInput input}) async {
    final result = await repository.fetchBbsNovaDetail(
        input: FetchBbsNovaDetailRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.detail));

    late BbsNovaDetaiPresentModel output;
    result.when(success: (value) {
      // set result
      output = BbsNovaDetaiPresentModel(
          model:
              BbsNovaDetailUseCaseModel(value.itemInfo, value.toHtmlString()));
      List<String> innerLinks = value.itemInfo.innerLinks ?? [];
      if (!innerLinks.contains(input.itemInfo.urlString)) {
        innerLinks.add(input.itemInfo.urlString);
        value.itemInfo.innerLinks = innerLinks;
        if (input.favoriteIsEnabled) {
          HistorioInfo bookmark = HistorioInfo();
          {
            bookmark.id = bookmark.hashCode;
            bookmark.category = "bbs";
            bookmark.itemInfo = value.itemInfo;
            bookmark.htmlText = value.bodyString;
            bookmark.createdAt = DateTime.now();
          }
          favoriteRepository.saveBookmark(
              input: FetchFavoritesRepoInput(bookmark: bookmark));
        } else {
          // save history
          historioRepository.saveNovaDetailHistory(
              input: FetchHistorioRepoInput(
                  itemInfo: value.itemInfo,
                  bodyString: value.bodyString,
                  category: 'bbs',
                  isUpdate: true));
        }
      }
    }, failure: (error) {
      output = BbsNovaDetaiPresentModel(error: error);
    });
    return output;
  }

  @override
  bool saveBookmark({required BbsNovaDetailUseCaseInput input}) {
    HistorioInfo bookmark = HistorioInfo();
    {
      bookmark.id = bookmark.hashCode;
      bookmark.category = "bbs";
      bookmark.itemInfo = input.itemInfo;
      bookmark.htmlText = input.htmlText;
      bookmark.createdAt = DateTime.now();
    }
    return favoriteRepository.saveBookmark(
        input: FetchFavoritesRepoInput(bookmark: bookmark));
  }
}
