import 'package:ses_novajoj/foundation/data/result.dart';
//import 'package:ses_novajoj/networking/api/my_web_api.dart';
// import 'package:ses_novajoj/networking/response/image_loader_item_response.dart';
// import 'package:ses_novajoj/networking/request/image_loader_parameter.dart';
import 'package:ses_novajoj/domain/entities/image_loader_item.dart';
import 'package:ses_novajoj/domain/repositories/image_loader_repository.dart';

/// TODO: This is dummy Web API class.
/// You should  web api class is defined in its dart file, like `my_web_api.dart`
class MyWebApi {}

class ImageLoaderRepositoryImpl extends ImageLoaderRepository {
  final MyWebApi _api;

  // sigleton
  static final ImageLoaderRepositoryImpl _instance =
      ImageLoaderRepositoryImpl._internal();
  ImageLoaderRepositoryImpl._internal() : _api = MyWebApi();
  factory ImageLoaderRepositoryImpl() => _instance;

  @override
  Future<Result<ImageLoaderItem>> fetchImageLoader(

      {required FetchImageLoaderRepoInput input}) async {
    Result<ImageLoaderItem> result =
        Result.success(data: ImageLoaderItem(id: 9999, string: "9999"));    // TODO: call api

    // TODO: change api result for `ImageLoader' repository
    return result;
  }
}
