import 'package:ses_novajoj/domain/repositories/nova_detail_repository.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/data/repositories/nova_detail_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'nova_detail_usecase_output.dart';

class NewsDetailUseCase with SimpleBloc<NovaDetailUseCaseOutput> {
  final NovaDetailRepositoryImpl repository;
  NewsDetailUseCase() : repository = NovaDetailRepositoryImpl();

  void fetchNewsDetail({required NovaItemInfo info}) async {
    final result = await repository.fetchNewsDetail(
        input: FetchNewsDetailRepoInput(
            itemInfo: info, docType: NovaDocType.detail));

    result.when(success: (value) {
      streamAdd(PresentModel(
          model: NovaDetailUseCaseModel(value.itemInfo, value.toHtmlString())));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
