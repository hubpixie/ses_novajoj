import 'package:ses_novajoj/foundation/data/date_util.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/user_types_descript.dart';
import 'package:ses_novajoj/domain/usecases/favorites_usecase_output.dart';

abstract class FavoritesPresenterOutput {}

class ShowFavoritesPageModel extends FavoritesPresenterOutput {
  final List<FavoritesViewModel>? viewModelList;
  final AppError? error;
  ShowFavoritesPageModel({this.viewModelList, this.error});

  List<FavoritesViewModel>? _viewModelList;
  List<FavoritesViewModel>? get reshapedViewModelList => () {
        if (viewModelList == null) {
          return null;
        }
        if (_viewModelList != null) {
          return _viewModelList;
        }
        FavoritesViewModel? prevModel;
        _viewModelList = [...viewModelList!];
        for (final FavoritesViewModel model in _viewModelList!) {
          if (prevModel?.createdAtText == model.createdAtText) {
            model.createdAtText = '';
          } else {
            prevModel = model;
          }
        }
        return _viewModelList;
      }();
}

class FavoritesViewModel {
  HistorioInfo bookmark;
  HistorioInfo? hisInfo;
  String createdAtText;
  String itemInfoCreatedAtText;

  FavoritesViewModel(FavoritesUseCaseModel model)
      : bookmark = model.bookmark,
        createdAtText = '',
        itemInfoCreatedAtText = DateUtil().getDateString(
            date: model.bookmark.itemInfo.createAt, format: 'M/d (E)');
}
