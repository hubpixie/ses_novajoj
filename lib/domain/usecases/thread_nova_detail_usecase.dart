import 'package:ses_novajoj/data/repositories/favorites_repository.dart';
import 'package:ses_novajoj/data/repositories/historio_repository.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/favorites_repository.dart';
import 'package:ses_novajoj/domain/repositories/historio_repository.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_detail_repository.dart';
import 'package:ses_novajoj/data/repositories/thread_nova_detail_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'thread_nova_detail_usecase_output.dart';

class ThreadNovaDetailUseCaseInput {
  NovaItemInfo itemInfo;
  String? htmlText;

  ThreadNovaDetailUseCaseInput({required this.itemInfo, this.htmlText});
}

abstract class ThreadNovaDetailUseCase
    with SimpleBloc<ThreadNovaDetailUseCaseOutput> {
  void fetchThreadNovaDetail({required ThreadNovaDetailUseCaseInput input});
  bool saveBookmark({required ThreadNovaDetailUseCaseInput input});
}

class ThreadNovaDetailUseCaseImpl extends ThreadNovaDetailUseCase {
  final ThreadNovaDetailRepositoryImpl repository;
  final FavoritesRepository favoriteRepository;
  final HistorioRepository historioRepository;
  ThreadNovaDetailUseCaseImpl()
      : repository = ThreadNovaDetailRepositoryImpl(),
        favoriteRepository = FavoritesRepositoryImpl(),
        historioRepository = HistorioRepositoryImpl();

  @override
  void fetchThreadNovaDetail(
      {required ThreadNovaDetailUseCaseInput input}) async {
    final result = await repository.fetchThreadNovaDetail(
        input: FetchThreadNovaDetailRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.detail));

    result.when(success: (value) {
      // set result
      streamAdd(PresentModel(
          model: ThreadNovaDetailUseCaseModel(
              value.itemInfo, value.toHtmlString())));
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
  bool saveBookmark({required ThreadNovaDetailUseCaseInput input}) {
    HistorioInfo bookmark = HistorioInfo();
    {
      bookmark.id = bookmark.hashCode;
      bookmark.category = "thread";
      bookmark.itemInfo = input.itemInfo;
      bookmark.htmlText = input.htmlText;
      bookmark.createdAt = DateTime.now();
    }
    return favoriteRepository.saveBookmark(
        input: FetchFavoritesRepoInput(bookmark: bookmark));
  }
}
