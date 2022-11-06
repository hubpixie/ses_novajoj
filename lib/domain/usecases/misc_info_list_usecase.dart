import 'package:ses_novajoj/domain/entities/misc_info_list_item.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_list_repository.dart';
import 'package:ses_novajoj/data/repositories/misc_info_list_repository.dart';

import 'misc_info_list_usecase_output.dart';

class MiscInfoListUseCaseInput {}

abstract class MiscInfoListUseCase with SimpleBloc<MiscInfoListUseCaseOutput> {
  void fetchMiscInfoList({required MiscInfoListUseCaseInput input});
}

class MiscInfoListUseCaseImpl extends MiscInfoListUseCase {
  final MiscInfoListRepositoryImpl repository;
  MiscInfoListUseCaseImpl() : repository = MiscInfoListRepositoryImpl();

  @override
  void fetchMiscInfoList({required MiscInfoListUseCaseInput input}) async {
    final result =
        await repository.fetchMiscInfoList(input: FetchMiscInfoListRepoInput());

    result.when(success: (value) {
      List<MiscInfoListItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => MiscInfoListUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}

/*
result.when(success: (value) {
      List<LocalNovaListItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => LocalNovaListUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
*/