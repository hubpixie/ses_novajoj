import 'package:ses_novajoj/foundation/data/user_data.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/comment_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/comment_list_usecase_output.dart';
import 'comment_list_presenter_output.dart';

import 'comment_list_router.dart';

class CommentListPresenterInput {
  NovaItemInfo itemInfo;
  bool sortingByStepAsc;

  CommentListPresenterInput(
      {required this.itemInfo, this.sortingByStepAsc = true});
}

abstract class CommentListPresenter
    with SimpleBloc<CommentListPresenterOutput> {
  void eventViewReady({required CommentListPresenterInput input});
  void eventViewSort({required CommentListPresenterInput input});
  Future<CommentMenuSetting?> eventViewMenuItemSetting();
  void eventUpdateMenuItemSetting({required CommentMenuSetting newValue});
}

class CommentListPresenterImpl extends CommentListPresenter {
  final CommentListUseCase useCase;
  final CommentListRouter router;

  CommentListPresenterImpl({required this.router})
      : useCase = CommentListUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowCommentListPageModel(
              viewModel: CommentListViewModel(event.model!)));
        } else {
          streamAdd(ShowCommentListPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required CommentListPresenterInput input}) {
    useCase.fetchCommentList(
        input: CommentListUseCaseInput(itemInfo: input.itemInfo));
  }

  @override
  void eventViewSort({required CommentListPresenterInput input}) {
    useCase.sortCommentList(
        input: CommentListUseCaseInput(
            itemInfo: input.itemInfo,
            sortingByStepAsc: input.sortingByStepAsc));
  }

  @override
  Future<CommentMenuSetting?> eventViewMenuItemSetting() async {
    CommentMenuSetting? menuItemSetting = await UserData().commentMenuSetting;
    return menuItemSetting;
  }

  @override
  void eventUpdateMenuItemSetting({required CommentMenuSetting newValue}) {
    UserData().saveCommentMenuSetting(newValue: newValue);
  }
}
