import 'package:ses_novajoj/domain/utilities/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/data/repositories/nova_list_repository.dart';
import 'nova_list_usecase_output.dart';

//class NewsListUseCaseOutput {}

class NewsListUseCase with SimpleBloc<NovaListUseCaseOutput> {
  final NovaListRepositoryImpl repository;
  NewsListUseCase() : repository = NovaListRepositoryImpl();

  void fetchNewsList() async {
    List<NovaListItem> list = await repository.fetchNewsList();
    streamAdd(PresentModel(
        list.map((entity) => NovaListUseCaseRowModel(entity)).toList()));
  }
}
