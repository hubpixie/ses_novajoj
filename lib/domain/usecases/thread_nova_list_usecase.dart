import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/thread_nova_list_repository.dart';
import 'package:ses_novajoj/data/repositories/thread_nova_list_repository.dart';
import 'package:ses_novajoj/domain/entities/thread_nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'thread_nova_list_usecase_output.dart';

class ThreadNovaListUseCaseInput {
  int itemIndex;
  String itemUrl;

  ThreadNovaListUseCaseInput({required this.itemIndex, this.itemUrl = ""});
}

abstract class ThreadNovaListUseCase
    with SimpleBloc<ThreadNovaListUseCaseOutput> {
  void fetchThreadNovaList({required ThreadNovaListUseCaseInput input});
  Future<String> fetchThumbUrl({required ThreadNovaListUseCaseInput input});
}

class ThreadNovaListUseCaseImpl extends ThreadNovaListUseCase {
  final ThreadNovaListRepositoryImpl repository;
  ThreadNovaListUseCaseImpl() : repository = ThreadNovaListRepositoryImpl();
  static final List<FetchThreadNovaListRepoInput> _inputUrlData = [
    FetchThreadNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=11",
        docType: NovaDocType.list),
  ];

  @override
  void fetchThreadNovaList({required ThreadNovaListUseCaseInput input}) async {
    final result = await repository.fetchThreadNovaList(
        input: _inputUrlData[input.itemIndex]);

    result.when(success: (value) {
      List<ThreadNovaListItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => ThreadNovaListUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  Future<String> fetchThumbUrl(
      {required ThreadNovaListUseCaseInput input}) async {
    final result = await repository.fetchThumbUrl(
        input: FetchThreadNovaListRepoInput(
            targetUrl: input.itemUrl, docType: NovaDocType.thumb));
    String retUrl = '';
    result.when(
        success: (value) {
          retUrl = value;
        },
        failure: (error) {});
    return retUrl;
  }
}
