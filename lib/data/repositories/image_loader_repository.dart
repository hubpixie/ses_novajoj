import 'package:ses_novajoj/networking/request/image_loader_item_parameter.dart';
import 'package:ses_novajoj/domain/repositories/image_loader_repository.dart';
import 'package:ses_novajoj/networking/api/base_nova_web_api.dart';

class ImageLoaderRepositoryImpl extends ImageLoaderRepository {
  final BaseNovaWebApi _api;

  // sigleton
  static final ImageLoaderRepositoryImpl _instance =
      ImageLoaderRepositoryImpl._internal();
  ImageLoaderRepositoryImpl._internal() : _api = BaseNovaWebApi();
  factory ImageLoaderRepositoryImpl() => _instance;

  @override
  Future<bool> saveNetworkMedia(
      {required FetchImageLoaderRepoInput input}) async {
    return _api.saveNetworkMedia(
        parameter:
            ImageLoaderItemParameter(mediaUrlString: input.mediaUrlString));
  }
}
