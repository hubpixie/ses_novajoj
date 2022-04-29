import 'package:ses_novajoj/domain/entities/bbs_nova_menu_item.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_menu_repository.dart';
import 'package:ses_novajoj/data/repositories/bbs_nova_menu_repository.dart';

import 'bbs_nova_menu_usecase_output.dart';

class BbsNovaMenuUseCaseInput {}

abstract class BbsNovaMenuUseCase with SimpleBloc<BbsNovaMenuUseCaseOutput> {
  void fetchBbsNovaMenu({required BbsNovaMenuUseCaseInput input});
}

class BbsNovaMenuUseCaseImpl extends BbsNovaMenuUseCase {
  final BbsNovaMenuRepositoryImpl repository;
  BbsNovaMenuUseCaseImpl() : repository = BbsNovaMenuRepositoryImpl();

  @override
  void fetchBbsNovaMenu({required BbsNovaMenuUseCaseInput input}) async {
    final result = await repository.fetchBbsNovaMenuList(
        input: FetchBbsNovaMenuRepoInput(langCode: 'cn'));

    result.when(success: (value) {
      List<BbsNovaMenuItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => BbsNovaMenuUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
