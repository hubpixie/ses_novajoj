import 'package:ses_novajoj/domain/entities/historio_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchHistorioRepoInput {
  Object id;
  String string;

  FetchHistorioRepoInput({required this.id, required this.string});
}

abstract class HistorioRepository {
  Future<Result<HistorioItem>> fetchHistorio(
      {required FetchHistorioRepoInput input});
}
