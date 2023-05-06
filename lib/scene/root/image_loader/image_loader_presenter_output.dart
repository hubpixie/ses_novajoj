import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/usecases/image_loader_usecase_output.dart';

abstract class ImageLoaderPresenterOutput {}

class ShowImageLoaderPageModel extends ImageLoaderPresenterOutput {
  final ImageLoaderViewModel? viewModel;
  final AppError? error;
  ShowImageLoaderPageModel({this.viewModel, this.error});
}

class ImageLoaderViewModel {
  NovaImageInfo imageInfo;

  ImageLoaderViewModel(ImageLoaderUseCaseModel model)
      : imageInfo = model.imageInfo;
}
