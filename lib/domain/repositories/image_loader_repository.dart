import 'package:ses_novajoj/domain/entities/image_loader_item.dart';

class FetchImageLoaderRepoInput {
  String mediaUrlString;

  FetchImageLoaderRepoInput({required this.mediaUrlString});
}

abstract class ImageLoaderRepository {
  Future<bool> saveNetworkMedia({required FetchImageLoaderRepoInput input});
  Future<ImageLoaderItem> fetchImageInfo(
      {required FetchImageLoaderRepoInput input});
}
