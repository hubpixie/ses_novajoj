import 'package:ses_novajoj/domain/entities/historio_item.dart';
import 'package:ses_novajoj/foundation/data/result.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

class FetchHistorioRepoInput {
  NovaItemInfo? itemInfo;
  String? bodyString;
  String? category;

  FetchHistorioRepoInput({this.itemInfo, this.bodyString, this.category});
}

abstract class HistorioRepository {
  Future<Result<List<HistorioItem>>> fetchHistorio(
      {required FetchHistorioRepoInput input});
  Future<String> fetchHtmlTextWithScript(
      {required FetchHistorioRepoInput input});
  void saveNovaDetailHistory({required FetchHistorioRepoInput input});
}
