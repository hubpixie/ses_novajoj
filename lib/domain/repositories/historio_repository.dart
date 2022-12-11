import 'package:ses_novajoj/domain/entities/detail_item.dart';
import 'package:ses_novajoj/domain/entities/historio_item.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchHistorioRepoInput {
  DetailItem? detailItem;
  String? category;

  FetchHistorioRepoInput({this.detailItem, this.category});
}

abstract class HistorioRepository {
  Future<Result<List<HistorioItem>>> fetchHistorio(
      {required FetchHistorioRepoInput input});
  void saveNovaDetailHistory({required FetchHistorioRepoInput input});
}
