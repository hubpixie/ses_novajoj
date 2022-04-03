import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_detail_repository.dart';
import 'package:ses_novajoj/data/repositories/thread_nova_detail_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'thread_nova_detail_usecase_output.dart';

class ThreadNovaDetailUseCaseInput {}

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
    NovaItemInfo itemInfo = NovaItemInfo(
        id: 0,
        thunnailUrlString: "https://google.com",
        title: "title",
        urlString: "https://google.com",
        source: "source",
        author: '',
        createAt: DateTime.now(),
        loadCommentAt: '',
        commentUrlString: "commentUrlString",
        commentCount: 0,
        reads: 0,
        isNew: false,
        isRead: false);

    final result = await repository.fetchThreadNovaDetail(
        input: FetchThreadNovaDetailRepoInput(
            itemInfo: itemInfo, docType: NovaDocType.detail));

    result.when(success: (value) {
      streamAdd(PresentModel(
          model: ThreadNovaDetailUseCaseModel(itemInfo, value.toString())));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
