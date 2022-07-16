import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/misc_info_list_item_response.dart';
// import 'package:ses_novajoj/networking/request/misc_info_list_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/misc_info_list_item.dart';
import 'package:ses_novajoj/domain/repositories/misc_info_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class MiscInfoListRepositoryImpl extends MiscInfoListRepository {
  final MyWebApi _api;

  // sigleton
  static final MiscInfoListRepositoryImpl _instance =
      MiscInfoListRepositoryImpl._internal();
  MiscInfoListRepositoryImpl._internal() : _api = MyWebApi();
  factory MiscInfoListRepositoryImpl() => _instance;

  @override
  Future<Result<List<MiscInfoListItem>>> fetchMiscInfoList(
      {required FetchMiscInfoListRepoInput input}) async {
    Result<List<MiscInfoListItem>> result = Result.success(data: [
      MiscInfoListItem(
          itemInfo: NovaItemInfo(
              id: 0,
              urlString: 'https://tms.kinnosuke.jp/',
              title: 'Kinnosuke',
              createAt: DateTime.now(),
              serviceType: ServiceType.time,
              orderIndex: 0)),
      MiscInfoListItem(
          itemInfo: NovaItemInfo(
              id: 1,
              urlString: 'https://www.spreaker.com/user/cock-radio',
              title: 'Hot Radio',
              createAt: DateTime.now(),
              serviceType: ServiceType.audio,
              orderIndex: 0)),
      MiscInfoListItem(
          itemInfo: NovaItemInfo(
              id: 2,
              urlString:
                  'https://www.afnpacific.net/Portals/101/360/AudioPlayer2.html#AFNP_OSN',
              title: 'Freely Listen',
              createAt: DateTime.now(),
              serviceType: ServiceType.audio,
              orderIndex: 1)),
    ]);
    DateTime.now().timeZoneName;
    return result;
  }
}
