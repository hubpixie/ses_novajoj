import 'package:ses_novajoj/domain/entities/nova_list_item.dart';
import 'package:ses_novajoj/domain/repositories/nova_list_repository.dart';
import 'package:ses_novajoj/utilities/data/number_ntil.dart';

class NovaListRepositoryImpl extends NovaListRepository {
  List<NovaListItem> novaItems = <NovaListItem>[];
  // sigleton
  static final NovaListRepositoryImpl _instance =
      NovaListRepositoryImpl._internal();
  NovaListRepositoryImpl._internal() {
    novaItems = <NovaListItem>[];
    novaItems.addAll([
      NovaListItem(
          id: 1,
          thunnailUrlString: "thuilUrlString",
          title: "title",
          urlString: "urlString",
          createAt: DateTime.now(),
          reads: 12,
          isNew: true),
      NovaListItem(
          id: 2,
          thunnailUrlString: "thuilUrlString",
          title: "title",
          urlString: "urlString",
          createAt: DateTime.now().add(const Duration(days: -1)),
          reads: 12)
    ]);
  }
  factory NovaListRepositoryImpl() => _instance;

  @override
  Future<List<NovaListItem>> fetchNewsList() async {
    // Here, do some heavy work lke http requests, async tasks, etc to get data
    Future.delayed(
        Duration(milliseconds: NumberUtil().randomInt(min: 2500, max: 3500)));
    return novaItems;
  }
}
