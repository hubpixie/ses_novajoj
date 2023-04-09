import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/image_loader_usecase.dart';
import 'package:ses_novajoj/domain/usecases/image_loader_usecase_output.dart';
import 'image_loader_presenter_output.dart';

import 'image_loader_router.dart';

class ImageLoaderPresenterInput {
  String imageSrc;

  ImageLoaderPresenterInput({required this.imageSrc});
}

abstract class ImageLoaderPresenter
    with SimpleBloc<ImageLoaderPresenterOutput> {
  Future<bool> eventRegisterImageIntoGallery(
      {required ImageLoaderPresenterInput input});
}

class ImageLoaderPresenterImpl extends ImageLoaderPresenter {
  final ImageLoaderUseCase useCase;
  final ImageLoaderRouter router;

  ImageLoaderPresenterImpl({required this.router})
      : useCase = ImageLoaderUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowImageLoaderPageModel(
              viewModel: ImageLoaderViewModel(event.model!)));
        } else {
          streamAdd(ShowImageLoaderPageModel(error: event.error));
        }
      }
    });
  }

  @override
  Future<bool> eventRegisterImageIntoGallery(
      {required ImageLoaderPresenterInput input}) async {
    return useCase.saveNetworkMedia(
        input: ImageLoaderUseCaseInput(imageSrc: input.imageSrc));
  }
}
