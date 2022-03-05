import 'package:flutter/widgets.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/l10n/l10n.dart';

class UseL10n {
  static L10n? of(BuildContext context) {
    return L10n.of(context);
  }

  static String localizedTextWithError(BuildContext context,
      {AppError? error}) {
    String retStr = 'unknown error!';
    if (error != null) {
      if (error.type == AppErrorType.network) {
        return L10n.of(context)?.msgNetworkUnavailable ?? '';
      }
    }
    return retStr;
  }
}
