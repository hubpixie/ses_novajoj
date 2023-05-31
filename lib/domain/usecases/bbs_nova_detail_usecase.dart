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

  BbsNovaDetailUseCaseInput({required this.itemInfo, this.htmlText});
}

abstract class BbsNovaDetailUseCase
    with SimpleBloc<BbsNovaDetailUseCaseOutput> {
  void fetchBbsNovaDetail({required BbsNovaDetailUseCaseInput input});
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
      streamAdd(PresentModel(
          model:
              BbsNovaDetailUseCaseModel(value.itemInfo, value.toHtmlString())));
      // save history
      historioRepository.saveNovaDetailHistory(
          input: FetchHistorioRepoInput(
              itemInfo: value.itemInfo,
              bodyString: value.bodyString,
              category: 'bbs'));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
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
