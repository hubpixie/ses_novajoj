import 'package:ses_novajoj/domain/entities/misc_info_select_item.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_select_repository.dart';
import 'package:ses_novajoj/data/repositories/misc_info_select_repository.dart';

import 'misc_info_select_usecase_output.dart';

class MiscInfoSelectUseCaseInput {}

abstract class MiscInfoSelectUseCase
    with SimpleBloc<MiscInfoSelectUseCaseOutput> {
  void fetchMiscInfoSelectData({required MiscInfoSelectUseCaseInput input});
}

class MiscInfoSelectUseCaseImpl extends MiscInfoSelectUseCase {
  final MiscInfoSelectRepositoryImpl repository;
  MiscInfoSelectUseCaseImpl() : repository = MiscInfoSelectRepositoryImpl();
  static List<MiscInfoSelectItem> _g_select_item_list = [];

  @override
  void fetchMiscInfoSelectData(
      {required MiscInfoSelectUseCaseInput input}) async {
    final result = await repository.fetchMiscInfoSelectData(
        input: FetchMiscInfoSelectRepoInput());

    if (_g_select_item_list.isEmpty) {
      result.when(success: (value) {
        _g_select_item_list.addAll(value);
        streamAdd(PresentModel(
            models: value
                .map((entity) => MiscInfoSelectUseCaseRowModel(entity))
                .toList()));
      }, failure: (error) {
        streamAdd(PresentModel(error: error));
      });
    } else {
      streamAdd(PresentModel(
          models: _g_select_item_list
              .map((entity) => MiscInfoSelectUseCaseRowModel(entity))
              .toList()));
    }
  }
}
