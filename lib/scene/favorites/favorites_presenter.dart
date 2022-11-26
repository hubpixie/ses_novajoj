import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase_output.dart';
import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'favorites_presenter_output.dart';

import 'favorites_router.dart';

class FavoritesPresenterInput {
  String appBarTitle;
  FavoritesViewModel? viewModel;
  Object? completeHandler;
  FavoritesPresenterInput(
      {required this.appBarTitle, this.viewModel, this.completeHandler});
}

abstract class FavoritesPresenter with SimpleBloc<FavoritesPresenterOutput> {
  Future<FavoritesPresenterOutput> eventViewReady(
      {required FavoritesPresenterInput input});
  void eventViewWebPage(Object context,
      {required FavoritesPresenterInput input});
}

class FavoritesPresenterImpl extends FavoritesPresenter {
  final FavoritesUseCase useCase;
  final FavoritesRouter router;

  FavoritesPresenterImpl({required this.router})
      : useCase = FavoritesUseCaseImpl();

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

  void _viewSelectPage(Object context,
      {required FavoritesPresenterInput input}) async {
    router.gotoWebPage(context,
        appBarTitle: input.appBarTitle,
        itemInfo: input.viewModel!.bookmark.itemInfo,
        htmlText: await UserData().readFavoriteData(
            url: input.viewModel?.bookmark.itemInfo.urlString ?? ''),
        completeHandler: input.completeHandler);
  }
}
