import 'package:ses_novajoj/domain/entities/nova_list_item.dart';

abstract class NovaListRepository {
  Future<List<NovaListItem>> fetchNewsList();
}
