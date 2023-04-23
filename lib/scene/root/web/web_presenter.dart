import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';

import 'web_router.dart';

class WebPresenterInput {
  NovaItemInfo itemInfo;
  String? htmlText;

  WebPresenterInput({required this.itemInfo, this.htmlText});
}

abstract class WebPresenter with SimpleBloc<dynamic> {
  void eventViewImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList,
      Object? completeHandler});
}

class WebPresenterImpl extends WebPresenter {
  final WebRouter router;

  WebPresenterImpl({required this.router});

  @override
  void eventViewImageLoader(Object context,
      {required String appBarTitle,
      int? imageSrcIndex,
      List<dynamic>? imageSrcList,
      Object? completeHandler}) {
    router.gotoImageLoader(context,
        appBarTitle: appBarTitle,
        imageSrcIndex: imageSrcIndex,
        imageSrcList: imageSrcList,
        completeHandler: completeHandler);
  }
}
