import 'package:ses_novajoj/domain/utilities/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/usecases/nova_list_usecase.dart';
import 'package:ses_novajoj/domain/usecases/nova_list_usecase_output.dart';
import 'top_list_router.dart';
import 'top_list_presenter_output.dart';

abstract class TopListPresenter with SimpleBloc<TopListPresenterOutput> {
  void eventViewReady();
  void startLogin(Object context);
  void startTopDetail(Object context);
}

class TopListPresenterImpl extends TopListPresenter {
  final NewsListUseCase useCase;
  final TopListRouter router;

  TopListPresenterImpl({required this.router}) : useCase = NewsListUseCase() {
    useCase.stream.listen((event) {
      if (event is PresentModel) {
        streamAdd(ShowNovaListModel(
            event.model.map((row) => NovaListRowViewModel(row)).toList()));
      } else if (event is PresentItemDetail) {
        //router.routeShowItemDetail();
      }
    });
  }

  @override
  void eventViewReady() {
    useCase.fetchNewsList();
  }

  @override
  void startLogin(Object context) {
    router.gotoLogin(context);
  }

  @override
  void startTopDetail(Object context) {
    router.gotoTopDetail(context);
  }
}
