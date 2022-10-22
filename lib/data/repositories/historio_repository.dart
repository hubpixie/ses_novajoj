import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/historio_item_response.dart';
// import 'package:ses_novajoj/networking/request/historio_item_parameter.dart';
import 'package:ses_novajoj/domain/entities/historio_item.dart';
import 'package:ses_novajoj/domain/repositories/historio_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class HistorioRepositoryImpl extends HistorioRepository {
  final MyWebApi _api;

  // sigleton
  static final HistorioRepositoryImpl _instance =
      HistorioRepositoryImpl._internal();
  HistorioRepositoryImpl._internal() : _api = MyWebApi();
  factory HistorioRepositoryImpl() => _instance;

  @override
  Future<Result<HistorioItem>> fetchHistorio(

      {required FetchHistorioRepoInput input}) async {
    Result<HistorioItem> result =
        Result.success(data: HistorioItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `Historio' repository
    return result;
  }
}
