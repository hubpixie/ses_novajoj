import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase.dart';
import 'package:ses_novajoj/domain/usecases/historio_usecase_output.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'historio_presenter_output.dart';

import 'historio_router.dart';

class HistorioPresenterInput {
  String appBarTitle;
  HistorioViewModel? viewModel;
  Object? completeHandler;
  HistorioPresenterInput(
      {required this.appBarTitle, this.viewModel, this.completeHandler});
}

abstract class HistorioPresenter with SimpleBloc<HistorioPresenterOutput> {
  Future<HistorioPresenterOutput> eventViewReady(
      {required HistorioPresenterInput input});
  void eventViewWebPage(Object context,
      {required HistorioPresenterInput input});
}

class HistorioPresenterImpl extends HistorioPresenter {
  final HistorioUseCase useCase;
  final FavoritesUseCase favoriteUseCase;
  final HistorioRouter router;

  HistorioPresenterImpl({required this.router})
      : useCase = HistorioUseCaseImpl(),
        favoriteUseCase = FavoritesUseCaseImpl();

  @override
  Future<HistorioPresenterOutput> eventViewReady(
      {required HistorioPresenterInput input}) async {
    final output = await useCase.fetchHistorio(input: HistorioUseCaseInput());
    List<HistorioViewModel>? list;
    if (output is PresentModel) {
      list = output.models?.map((e) => HistorioViewModel(e)).toList();
    }
    return ShowHistorioPageModel(viewModelList: list, error: null);
  }

  @override
  void eventViewWebPage(Object context,
      {required HistorioPresenterInput input}) {
    _viewSelectPage(context, input: input);
  }

  void _viewSelectPage(Object context,
      {required HistorioPresenterInput input}) async {
    // remove selected historio
    final itemInfo = input.viewModel?.hisInfo.itemInfo;
    final bodyString =
        await UserData().readHistorioData(url: itemInfo?.urlString ?? '');
    HistorioInfo? bookmark = input.viewModel?.hisInfo;
    bookmark?.htmlText = bodyString;
    void changeFavoriteAction() {
      favoriteUseCase.saveBookmark(
          input: FavoritesUseCaseInput(bookmark: bookmark));
    }

    void removeAction() {
      UserData().removeHistorio(url: itemInfo?.urlString ?? '');
    }

    router.gotoWebPage(context,
        appBarTitle: input.appBarTitle,
        itemInfo: itemInfo,
        htmlText: await useCase.fetchHtmlTextWithScript(
            input: HistorioUseCaseInput(
                itemInfo: itemInfo, bodyString: bodyString)),
        changeFavoriteAction:
            itemInfo?.isFavorite == false ? changeFavoriteAction : null,
        removeAction: removeAction,
        completeHandler: input.completeHandler);
  }
}
