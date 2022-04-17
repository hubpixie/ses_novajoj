import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/bbs_nova_guide_repository.dart';
import 'package:ses_novajoj/data/repositories/bbs_nova_guide_repository.dart';
import 'package:ses_novajoj/domain/entities/bbs_guide_list_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'bbs_nova_guide_usecase_output.dart';

class BbsNovaGuideUseCaseInput {
  int itemIndex;
  String itemUrl;

  BbsNovaGuideUseCaseInput({required this.itemIndex, this.itemUrl = ""});
}

abstract class BbsNovaGuideUseCase with SimpleBloc<BbsNovaGuideUseCaseOutput> {
  void fetchBbsGuideList({required BbsNovaGuideUseCaseInput input});
  Future<String> fetchThumbUrl({required BbsNovaGuideUseCaseInput input});
}

class BbsNovaGuideUseCaseImpl extends BbsNovaGuideUseCase {
  final BbsNovaGuideRepositoryImpl repository;
  BbsNovaGuideUseCaseImpl() : repository = BbsNovaGuideRepositoryImpl();

  static final List<FetchBbsGuideRepoInput> _inputUrlData = [
    FetchBbsGuideRepoInput(
        // bbs guide 1
        targetUrl: "https://www.6park.com/pub/aimain.php?act=parkyc",
        docType: NovaDocType.bbsList),
    FetchBbsGuideRepoInput(
        // bbs guide 2
        targetUrl: "https://www.6park.com/pub/aimain.php?act=jingfill",
        docType: NovaDocType.bbsList),
    FetchBbsGuideRepoInput(
        // bbs guide 3
        targetUrl: "https://www.6park.com/pub/aimain.php?act=bbshot",
        docType: NovaDocType.bbsEtcList),
  ];

  @override
  void fetchBbsGuideList({required BbsNovaGuideUseCaseInput input}) async {
    final result = await repository.fetchBbsNovaGuideList(
        input: _inputUrlData[input.itemIndex]);

    result.when(success: (value) {
      List<BbsGuideListItem> list = value;
      streamAdd(PresentModel(
          model: list
              .map((entity) => BbsNovaGuideUseCaseRowModel(entity))
              .toList()));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }

  @override
  Future<String> fetchThumbUrl(
      {required BbsNovaGuideUseCaseInput input}) async {
    final result = await repository.fetchThumbUrl(
        input: FetchBbsGuideRepoInput(
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
