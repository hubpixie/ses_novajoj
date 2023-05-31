import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/image_loader_repository.dart';
import 'package:ses_novajoj/data/repositories/image_loader_repository.dart';
import 'image_loader_usecase_output.dart';

class ImageLoaderUseCaseInput {
  String imageSrc;

  ImageLoaderUseCaseInput({required this.imageSrc});
}

abstract class ImageLoaderUseCase with SimpleBloc<ImageLoaderUseCaseOutput> {
  Future<ImageLoaderUseCaseOutput> fetchImageInfo(
      {required ImageLoaderUseCaseInput input});
  Future<bool> saveNetworkMedia({required ImageLoaderUseCaseInput input});
}

class ImageLoaderUseCaseImpl extends ImageLoaderUseCase {
  final ImageLoaderRepositoryImpl repository;
  ImageLoaderUseCaseImpl() : repository = ImageLoaderRepositoryImpl();

  @override
  Future<ImageLoaderUseCaseOutput> fetchImageInfo(
      {required ImageLoaderUseCaseInput input}) async {
    final ret = await repository.fetchImageInfo(
        input: FetchImageLoaderRepoInput(mediaUrlString: input.imageSrc));
    return PresentModel(model: ImageLoaderUseCaseModel(ret.imageInfo));
  }

  @override
  Future<bool> saveNetworkMedia(
      {required ImageLoaderUseCaseInput input}) async {
    return repository.saveNetworkMedia(
        input: FetchImageLoaderRepoInput(mediaUrlString: input.imageSrc));
  }
}
