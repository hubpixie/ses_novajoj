import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_detail_repository.dart';
import 'package:ses_novajoj/data/repositories/thread_nova_detail_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'thread_nova_detail_usecase_output.dart';

class ThreadNovaDetailUseCaseInput {
  NovaItemInfo itemInfo;

  ThreadNovaDetailUseCaseInput({required this.itemInfo});
}

abstract class ThreadNovaDetailUseCase
    with SimpleBloc<ThreadNovaDetailUseCaseOutput> {
  void fetchThreadNovaDetail({required ThreadNovaDetailUseCaseInput input});
}

class ThreadNovaDetailUseCaseImpl extends ThreadNovaDetailUseCase {
  final ThreadNovaDetailRepositoryImpl repository;
  ThreadNovaDetailUseCaseImpl() : repository = ThreadNovaDetailRepositoryImpl();

  @override
  void fetchThreadNovaDetail(
      {required ThreadNovaDetailUseCaseInput input}) async {
    final result = await repository.fetchThreadNovaDetail(
        input: FetchThreadNovaDetailRepoInput(
            itemInfo: input.itemInfo, docType: NovaDocType.detail));

    result.when(success: (value) {
      streamAdd(PresentModel(
          model: ThreadNovaDetailUseCaseModel(
              value.itemInfo, value.toHtmlString())));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
