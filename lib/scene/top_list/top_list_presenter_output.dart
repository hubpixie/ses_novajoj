import 'package:ses_novajoj/domain/usecases/nova_list_usecase_output.dart';
import 'package:ses_novajoj/utilities/data/date_util.dart';
import 'package:ses_novajoj/utilities/data/string_util.dart';

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
  String source;
  String commentUrlString;
  int commentCount;
  DateTime createAt;
  String createAtText;
  int reads;
  String readsText;
  bool isRead;
  bool isNew;
  String isNewText;

  NovaListRowViewModel(NovaListUseCaseRowModel model)
      : id = model.id,
        thunnailUrlString = model.thunnailUrlString,
        title = model.title,
        urlString = model.urlString,
        source = model.source,
        commentUrlString = model.commentUrlString,
        commentCount = model.commentCount,
        createAt = model.createAt,
        createAtText =
            DateUtil().getDateString(date: model.createAt, format: 'M/d (E)'),
        reads = model.reads,
        readsText = StringUtil().thousandFormat(model.reads),
        isRead = model.isRead,
        isNew = model.isNew,
        isNewText = model.isNew ? 'NEW' : '';
}
