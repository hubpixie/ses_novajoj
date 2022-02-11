import 'package:ses_novajoj/domain/usecases/nova_list_usecase_output.dart';
import 'package:ses_novajoj/utilities/data/date_util.dart';

abstract class TopListPresenterOutput {}

class ShowNovaListModel extends TopListPresenterOutput {
  final List<NovaListRowViewModel> viewModelList;
  ShowNovaListModel(this.viewModelList);
}

class NovaListRowViewModel {
  int id;
  String thunnailUrlString;
  String title;
  String urlString;
  DateTime createAt;
  String createAtText;
  int reads;
  bool isRead;
  bool isNew;
  String isNewText;

  NovaListRowViewModel(NovaListUseCaseRowModel model)
      : id = model.id,
        thunnailUrlString = model.thunnailUrlString,
        title = model.title,
        urlString = model.urlString,
        createAt = model.createAt,
        createAtText = DateUtil().getDateMdeHmsString(date: model.createAt),
        reads = model.reads,
        isRead = model.isRead,
        isNew = model.isNew,
        isNewText = model.isNew ? 'NEW' : '';
}
