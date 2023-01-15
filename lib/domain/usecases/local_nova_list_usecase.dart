import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/local_nova_list_repository.dart';
import 'package:ses_novajoj/data/repositories/local_nova_list_repository.dart';
import 'package:ses_novajoj/domain/entities/local_nova_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'local_nova_list_usecase_output.dart';

class LocalNovaListUseCaseInput {
  int itemIndex;
  int targetPageIndex;
  String itemUrl;

  LocalNovaListUseCaseInput(
      {required this.itemIndex, this.targetPageIndex = 1, this.itemUrl = ""});
}

abstract class LocalNovaListUseCase
    with SimpleBloc<LocalNovaListUseCaseOutput> {
  void fetchLocalNovaList({required LocalNovaListUseCaseInput input});
  Future<String> fetchThumbUrl({required LocalNovaListUseCaseInput input});
}

class LocalNovaListUseCaseImpl extends LocalNovaListUseCase {
  final LocalNovaListRepositoryImpl repository;
  LocalNovaListUseCaseImpl() : repository = LocalNovaListRepositoryImpl();

  static final List<FetchLocalNovaListRepoInput> _inputUrlData = [
    FetchLocalNovaListRepoInput(
        targetUrl:
            "https://local.6parknews.com/index.php?type_id=11&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=1&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=2&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=3&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=4&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=5&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=6&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=8&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=9&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl:
            "https://local.6parknews.com/index.php?type_id=10&p={{page}}",
        docType: NovaDocType.list),
    FetchLocalNovaListRepoInput(
        targetUrl: "https://local.6parknews.com/index.php?type_id=7&p={{page}}",
        docType: NovaDocType.list),
  ];

  @override
  void fetchLocalNovaList({required LocalNovaListUseCaseInput input}) async {
    _inputUrlData[input.itemIndex].pageIndex = input.targetPageIndex;
    final result = await repository.fetchLocalNovaList(
        input: _inputUrlData[input.itemIndex]);

    result.when(success: (value) {
      List<LocalNovaListItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => LocalNovaListUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  Future<String> fetchThumbUrl(
      {required LocalNovaListUseCaseInput input}) async {
    final result = await repository.fetchThumbUrl(
        input: FetchLocalNovaListRepoInput(
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
