import 'package:ses_novajoj/domain/entities/historio_item.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/result.dart';

class FetchHistorioRepoInput {}

abstract class HistorioRepository {
  Future<Result<List<HistorioItem>>> fetchHistorio(
      {required FetchHistorioRepoInput input});
}
