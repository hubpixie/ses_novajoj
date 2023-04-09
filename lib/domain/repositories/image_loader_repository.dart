import 'package:ses_novajoj/domain/entities/image_loader_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchImageLoaderRepoInput {
  Object id;
  String string;

  FetchImageLoaderRepoInput({required this.id, required this.string});
}

abstract class ImageLoaderRepository {
  Future<Result<ImageLoaderItem>> fetchImageLoader(
      {required FetchImageLoaderRepoInput input});
}
