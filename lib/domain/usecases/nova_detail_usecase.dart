import 'package:ses_novajoj/data/repositories/favorites_repository.dart';
import 'package:ses_novajoj/data/repositories/historio_repository.dart';
import 'package:ses_novajoj/domain/repositories/favorites_repository.dart';
import 'package:ses_novajoj/domain/repositories/historio_repository.dart';
import 'package:ses_novajoj/domain/repositories/nova_detail_repository.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/data/repositories/nova_detail_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'nova_detail_usecase_output.dart';

class NewsDetailUseCaseInput {
  NovaItemInfo itemInfo;
  String? htmlText;

  NewsDetailUseCaseInput({required this.itemInfo, this.htmlText});
}

abstract class NewsDetailUseCase with SimpleBloc<NovaDetailUseCaseOutput> {
  void fetchNewsDetail({required NewsDetailUseCaseInput input});
  bool saveBookmark({required NewsDetailUseCaseInput input});
}

class NewsDetailUseCaseImpl extends NewsDetailUseCase {
  final NovaDetailRepositoryImpl repository;
  final FavoritesRepository favoriteRepository;
  final HistorioRepository historioRepository;

  NewsDetailUseCaseImpl()
      : repository = NovaDetailRepositoryImpl(),
        favoriteRepository = FavoritesRepositoryImpl(),
        historioRepository = HistorioRepositoryImpl();

  @override
  void fetchNewsDetail({required NewsDetailUseCaseInput input}) async {
    final result = await repository.fetchNewsDetail(
        input: FetchNewsDetailRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.detail));

    result.when(success: (value) {
      // set result
      streamAdd(PresentModel(
          model: NovaDetailUseCaseModel(value.itemInfo, value.toHtmlString())));
      // save history
      historioRepository.saveNovaDetailHistory(
          input: FetchHistorioRepoInput(
              itemInfo: value.itemInfo,
              bodyString: value.bodyString,
              category: 'news'));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  bool saveBookmark({required NewsDetailUseCaseInput input}) {
    HistorioInfo bookmark = HistorioInfo();
    {
      bookmark.id = bookmark.hashCode;
      bookmark.category = "news";
      bookmark.itemInfo = input.itemInfo;
      bookmark.htmlText = input.htmlText;
      bookmark.createdAt = DateTime.now();
    }
    return favoriteRepository.saveBookmark(
        input: FetchFavoritesRepoInput(bookmark: bookmark));
  }
}
