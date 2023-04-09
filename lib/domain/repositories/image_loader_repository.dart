class FetchImageLoaderRepoInput {
  String mediaUrlString;

  FetchImageLoaderRepoInput({required this.mediaUrlString});
}

abstract class ImageLoaderRepository {
  // Future<Result<ImageLoaderItem>> fetchImageLoader(
  //     {required FetchImageLoaderRepoInput input});
  Future<bool> saveNetworkMedia({required FetchImageLoaderRepoInput input});
}
