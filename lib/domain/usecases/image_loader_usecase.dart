import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/image_loader_repository.dart';
import 'package:ses_novajoj/data/repositories/image_loader_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'image_loader_usecase_output.dart';

class ImageLoaderUseCaseInput {

}

abstract class ImageLoaderUseCase with SimpleBloc<ImageLoaderUseCaseOutput> {
  void fetchImageLoader({required ImageLoaderUseCaseInput input});
}

class ImageLoaderUseCaseImpl extends ImageLoaderUseCase {
  final ImageLoaderRepositoryImpl repository;
  ImageLoaderUseCaseImpl() : repository = ImageLoaderRepositoryImpl();

  @override
  void fetchImageLoader({required ImageLoaderUseCaseInput input}) async {
    final result = await repository.fetchImageLoader(
        input: FetchImageLoaderRepoInput(
            id: 9999, string: "99999" /* // TODO: dummy code*/));

    result.when(success: (value) {
      streamAdd(
          PresentModel(model: ImageLoaderUseCaseModel(9999, value.toString() /* // TODO: dummy code*/)));
    }, failure: (error) {
      streamAdd(PresentModel(error: error));
    });
  }
}
