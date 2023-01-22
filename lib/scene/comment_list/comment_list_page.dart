import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/domain/foundation/bloc/bloc_provider.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';
import 'package:ses_novajoj/scene/foundation/page/page_parameter.dart';
import 'package:ses_novajoj/scene/comment_list/comment_list_presenter.dart';
import 'package:ses_novajoj/scene/comment_list/comment_list_presenter_output.dart';

class CommentListPage extends StatefulWidget {
  final CommentListPresenter presenter;
  const CommentListPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _CommentListPageState createState() => _CommentListPageState();
}

class _CommentListPageState extends State<CommentListPage> {
  @override
  void initState() {
    super.initState();
    // TODO: Initialize your variables.
    widget.presenter.eventViewReady(input: CommentListPresenterInput());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("title"),
        backgroundColor: ColorDef.appBarBackColor2,
        foregroundColor: ColorDef.appBarTitleColor,
        centerTitle: true,
      ),
      body: BlocProvider<CommentListPresenter>(
        bloc: widget.presenter,
        child: StreamBuilder<CommentListPresenterOutput>(
            stream: widget.presenter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.grey[850]));
              }
              final data = snapshot.data;
              if (data is ShowCommentListPageModel) {
                if (data.error == null) {
                  return Column(
                    children: [Text("${data.viewModel}")],
                  );
                } else {
                  return Text("${data.error}");
                }
              } else {
                assert(false, "unknown event $data");
                return Container(color: Colors.red);
              }
            }),
      ),
    );
  }
}
