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
  NewsDetailUseCaseImpl() : repository = NovaDetailRepositoryImpl();

  @override
  void fetchNewsDetail({required NewsDetailUseCaseInput input}) async {
    final result = await repository.fetchNewsDetail(
        input: FetchNewsDetailRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.detail));

    result.when(success: (value) {
      streamAdd(PresentModel(
          model: NovaDetailUseCaseModel(value.itemInfo, value.toHtmlString())));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  bool saveBookmark({required NewsDetailUseCaseInput input}) {
    return repository.saveBookmark(
        input: FetchNewsDetailRepoInput(
            itemInfo: input.itemInfo,
            docType: NovaDocType.detail,
            htmlText: input.htmlText));
  }
}
