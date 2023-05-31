import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase_output.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'favorites_presenter_output.dart';

import 'favorites_router.dart';

class FavoritesPresenterInput {
  String appBarTitle;
  FavoritesViewModel? viewModel;
  Object? completeHandler;
  HistorioInfo? bookmark;
  FavoritesPresenterInput(
      {required this.appBarTitle, this.viewModel, this.completeHandler});
}

abstract class FavoritesPresenter with SimpleBloc<FavoritesPresenterOutput> {
  Future<FavoritesPresenterOutput> eventViewReady(
      {required FavoritesPresenterInput input});
  void eventViewWebPage(Object context,
      {required FavoritesPresenterInput input});
  bool saveBookmark({required FavoritesPresenterInput input});
}

class FavoritesPresenterImpl extends FavoritesPresenter {
  final FavoritesUseCase useCase;
  final HistorioUseCase hisCseCase;
  final FavoritesRouter router;

  FavoritesPresenterImpl({required this.router})
      : useCase = FavoritesUseCaseImpl(),
        hisCseCase = HistorioUseCaseImpl();

  @override
  Future<FavoritesPresenterOutput> eventViewReady(
      {required FavoritesPresenterInput input}) async {
    final output = await useCase.fetchFavorites(input: FavoritesUseCaseInput());
    List<FavoritesViewModel>? list;
    if (output is PresentModel) {
      list = output.models?.map((e) => FavoritesViewModel(e)).toList();
    }
    return ShowFavoritesPageModel(viewModelList: list, error: null);
  }

  @override
  void eventViewWebPage(Object context,
      {required FavoritesPresenterInput input}) {
    _viewSelectPage(context, input: input);
  }

  @override
  bool saveBookmark({required FavoritesPresenterInput input}) {
    return useCase.saveBookmark(
        input: FavoritesUseCaseInput(bookmark: input.bookmark));
  }

  void _viewSelectPage(Object context,
      {required FavoritesPresenterInput input}) async {
    // remove selected favorite
    final itemInfo = input.viewModel?.bookmark.itemInfo;
    final bodyString =
        await UserData().readFavoriteData(url: itemInfo?.urlString ?? '');
    void removeAction() {
      useCase.saveBookmark(
          input: FavoritesUseCaseInput(bookmark: input.bookmark));
    }

    router.gotoWebPage(context,
        appBarTitle: input.appBarTitle,
        itemInfo: itemInfo,
        htmlText: await hisCseCase.fetchHtmlTextWithScript(
            input: HistorioUseCaseInput(
                itemInfo: itemInfo, bodyString: bodyString)),
        removeAction: removeAction,
        completeHandler: input.completeHandler);
  }
}
