import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/networking/api/base_nova_web_api.dart';
import 'package:ses_novajoj/networking/response/misc_info_select_item_response.dart';
import 'package:ses_novajoj/domain/entities/misc_info_select_item.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_select_repository.dart';

class MiscInfoSelectRepositoryImpl extends MiscInfoSelectRepository {
  final BaseNovaWebApi _api;

  // sigleton
  static final MiscInfoSelectRepositoryImpl _instance =
      MiscInfoSelectRepositoryImpl._internal();
  MiscInfoSelectRepositoryImpl._internal() : _api = BaseNovaWebApi();
  factory MiscInfoSelectRepositoryImpl() => _instance;

  @override
  Future<Result<List<MiscInfoSelectItem>>> fetchMiscInfoSelectData(
      {required FetchMiscInfoSelectRepoInput input}) async {
    final resList = await _api.fetchMiscInfoSelectSettings();
    List<MiscInfoSelectItemItemRes> list = [];
    resList.when(success: (value) => list = value, failure: (error) {});

    return Result.success(
        data: list
            .map(
                (elem) => MiscInfoSelectItem(urlSelectInfo: elem.urlSelectInfo))
            .toList());
  }
}
