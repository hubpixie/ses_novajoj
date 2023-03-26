import 'package:ses_novajoj/domain/foundation/bloc/simple_bloc.dart';
import 'package:ses_novajoj/domain/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/data/repositories/comment_list_repository.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';

import 'comment_list_usecase_output.dart';

class CommentListUseCaseInput {
  NovaItemInfo itemInfo;
  bool latestInfoIsEnabled;
  bool sortingByStepAsc;
  int? pageIndex;

  CommentListUseCaseInput(
      {required this.itemInfo,
      this.latestInfoIsEnabled = true,
      this.sortingByStepAsc = true,
      this.pageIndex});
}

abstract class CommentListUseCase with SimpleBloc<CommentListUseCaseOutput> {
  void fetchCommentList({required CommentListUseCaseInput input});
  void sortCommentList({required CommentListUseCaseInput input});
}

class CommentListUseCaseImpl extends CommentListUseCase {
  static const int _kCommentListCountPerPage = 50;
  final CommentListRepositoryImpl repository;
  CommentListUseCaseImpl() : repository = CommentListRepositoryImpl();

  List<NovaComment>? _originalCommentList;
  CommentMenuSetting? prevCommentMenuSetting;

  @override
  void fetchCommentList({required CommentListUseCaseInput input}) async {
    void updateSubPageIndex(List<NovaComment> list) {
      // update each item pageIndex of its relyList.
      for (var elem in list) {
        elem.replyList?.forEach((subElem) {
          int idx = list.indexWhere((e) => e.step == subElem.step);
          if (idx >= 0) {
            subElem.pageNumber = ((idx + 1) / _kCommentListCountPerPage).ceil();
          }
        });
      }
    }

    List<NovaComment> ret = [];
    List<NovaComment> list = [];
    if (_originalCommentList == null ||
        (input.latestInfoIsEnabled && !input.sortingByStepAsc)) {
      final result = await repository.fetchCommentList(
          input: FetchCommentListRepoInput(
              itemInfo: input.itemInfo, docType: NovaDocType.none));

      result.when(success: (value) {
        _originalCommentList = value.itemInfo.comments; //keep orignal list
        list = _originalCommentList ?? [];
        if (input.sortingByStepAsc) {
          list = list.reversed.toList();
        }
        // take sublist
        ret = _takeCommentListWith(pageIndex: input.pageIndex ?? 1, list: list);

        // update each item pageIndex of its relyList.
        updateSubPageIndex(list);

        // set result
        value.itemInfo.comments = ret;
        streamAdd(PresentModel(model: CommentListUseCaseModel(value.itemInfo)));
      }, failure: (error) {
        streamAdd(PresentModel(error: error));
      });
    } else {
      list = _originalCommentList?.reversed.toList() ?? [];
      // take sublist
      ret = _takeCommentListWith(pageIndex: input.pageIndex ?? 1, list: list);

      // update each item pageIndex of its relyList.
      updateSubPageIndex(list);

      // set result
      input.itemInfo.comments = ret;
      streamAdd(PresentModel(model: CommentListUseCaseModel(input.itemInfo)));
    }
  }

  @override
  void sortCommentList({required CommentListUseCaseInput input}) {
    List<NovaComment> list = [];
    if (input.sortingByStepAsc) {
      list = _originalCommentList?.reversed.toList() ?? [];
    } else {
      list = _originalCommentList ?? [];
    }
    list = _takeCommentListWith(pageIndex: input.pageIndex ?? 1, list: list);
    input.itemInfo.comments = list;
    streamAdd(PresentModel(model: CommentListUseCaseModel(input.itemInfo)));
  }

  List<NovaComment> _takeCommentListWith(
      {required int pageIndex, required List<NovaComment> list}) {
    List<NovaComment> retlist;
    if (list.length <= _kCommentListCountPerPage) {
      retlist = list;
    } else {
      int start = (pageIndex - 1) * _kCommentListCountPerPage;
      int end = start + _kCommentListCountPerPage;
      end = end > list.length ? list.length : end;
      retlist = list.sublist(start, end);
    }

    int pageCnt = (list.length / _kCommentListCountPerPage).ceil();
    pageCnt = pageCnt < 0 ? 1 : pageCnt;

    for (var elem in retlist) {
      elem.pageNumber = pageIndex;
      elem.pageCount = pageCnt;
    }
    return retlist;
  }
}
