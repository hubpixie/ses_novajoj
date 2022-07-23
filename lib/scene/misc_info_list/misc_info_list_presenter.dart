//import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/misc_info_list_usecase_output.dart';
import 'misc_info_list_presenter_output.dart';

import 'misc_info_list_router.dart';

class MiscInfoListPresenterInput {
  int itemIndex = 0;
}

abstract class MiscInfoListPresenter
    with SimpleBloc<MiscInfoListPresenterOutput> {
  void eventViewReady({required MiscInfoListPresenterInput input});
  void eventViewWebPage(Object context,
      {required String appBarTitle, Object? itemInfo, Object? completeHandler});
}

class MiscInfoListPresenterImpl extends MiscInfoListPresenter {
  final MiscInfoListUseCase useCase;
  final MiscInfoListRouter router;

  MiscInfoListPresenterImpl({required this.router})
      : useCase = MiscInfoListUseCaseImpl() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        if (event.error == null) {
          streamAdd(ShowMiscInfoListPageModel(
              viewModelList: event.model
                  ?.map((row) => MiscInfoListViewModel(row))
                  .toList()));
        } else {
          streamAdd(ShowMiscInfoListPageModel(error: event.error));
        }
      }
    });
  }

  @override
  void eventViewReady({required MiscInfoListPresenterInput input}) {
    useCase.fetchMiscInfoList(input: MiscInfoListUseCaseInput());
  }

  @override
  void eventViewWebPage(Object context,
      {required String appBarTitle,
      Object? itemInfo,
      Object? completeHandler}) {
    router.gotoWebPage(context,
        appBarTitle: appBarTitle,
        itemInfo: itemInfo,
        completeHandler: completeHandler);
  }
}
