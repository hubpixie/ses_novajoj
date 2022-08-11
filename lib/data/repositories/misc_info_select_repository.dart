import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/misc_info_select_item_response.dart';
// import 'package:ses_novajoj/networking/request/misc_info_select_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/misc_info_select_item.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_select_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class MiscInfoSelectRepositoryImpl extends MiscInfoSelectRepository {
  final MyWebApi _api;

  // sigleton
  static final MiscInfoSelectRepositoryImpl _instance =
      MiscInfoSelectRepositoryImpl._internal();
  MiscInfoSelectRepositoryImpl._internal() : _api = MyWebApi();
  factory MiscInfoSelectRepositoryImpl() => _instance;

  @override
  Future<Result<MiscInfoSelectItem>> fetchMiscInfoSelect(

      {required FetchMiscInfoSelectRepoInput input}) async {
    Result<MiscInfoSelectItem> result =
        Result.success(data: MiscInfoSelectItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `MiscInfoSelect' repository
    return result;
  }
}
