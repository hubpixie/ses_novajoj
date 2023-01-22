import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/nova_detail_usecase.dart';
import 'package:ses_novajoj/domain/usecases/nova_detail_usecase_output.dart';
import 'top_detail_presenter_output.dart';

import 'top_detail_router.dart';

class TopDetailPresenterInput {
  NovaItemInfo itemInfo;

  String? htmlText;
  TopDetailPresenterInput({required this.itemInfo, this.htmlText});
}

abstract class TopDetailPresenter with SimpleBloc<TopDetailPresenterOutput> {
  bool get isProcessing;
  void eventViewReady({required TopDetailPresenterInput input});
  void eventViewCommentList(BuildContext context);
  bool eventSaveBookmark({required TopDetailPresenterInput input});
}

class TopDetailPresenterImpl extends TopDetailPresenter {
  final NewsDetailUseCase useCase;
  final TopDetailRouter router;

  bool _isProcessing = true;

  TopDetailPresenterImpl({required this.router})
      : useCase = NewsDetailUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowNovaDetailPageModel(
              viewModel: NovaDetailViewModel(event.model!)));
        } else {
          streamAdd(ShowNovaDetailPageModel(error: event.error));
        }
      }
      _isProcessing = false;
    });
  }

  @override
  bool get isProcessing => _isProcessing;

  @override
  void eventViewReady({required TopDetailPresenterInput input}) {
    useCase.fetchNewsDetail(
        input: NewsDetailUseCaseInput(itemInfo: input.itemInfo));
  }

  @override
  void eventViewCommentList(BuildContext context) {
    router.gotoCommentList(context);
  }

  @override
  bool eventSaveBookmark({required TopDetailPresenterInput input}) {
    return useCase.saveBookmark(
        input: NewsDetailUseCaseInput(
            itemInfo: input.itemInfo, htmlText: input.htmlText));
  }
}
