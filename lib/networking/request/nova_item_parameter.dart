import 'package:ses_novajoj/foundation/data/user_types.dart';

class NovaItemParameter {
  String targetUrl;
  NovaDocType docType;
  int pageBlockIndex;
  int limitPerBlock;
  int fetchedBlockItemIndex;

  NovaItemParameter(
      {required this.targetUrl,
      required this.docType,
      this.pageBlockIndex = 0,
      this.limitPerBlock = 10,
      this.fetchedBlockItemIndex = 0});
}
