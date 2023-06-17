import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/foundation/color_def.dart';
import 'package:ses_novajoj/scene/foundation/use_l10n.dart';

typedef SearchAction = void Function(String);
typedef CancelAction = void Function();

class NovaSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final bool automaticallyImplyLeading;
  final SearchAction? searchAction;
  final CancelAction? cancelAction;

  const NovaSearchBar(
      {Key? key,
      this.automaticallyImplyLeading = false,
      this.searchAction,
      this.cancelAction})
      : super(key: key);

  @override
  State<NovaSearchBar> createState() => NovaSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NovaSearchBarState extends State<NovaSearchBar> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: ColorDef.appBarBackColor2,
      foregroundColor: ColorDef.appBarTitleColor,
      leadingWidth: widget.automaticallyImplyLeading ? 30 : 0,
      title: SizedBox(
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
                width: widget.automaticallyImplyLeading
                    ? screenWidth - 130
                    : screenWidth - 110,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Theme(
                  data: ThemeData(
                      colorScheme: ColorScheme.fromSwatch()
                          .copyWith(secondary: Colors.blue)),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: UseL10n.of(context)?.searchedHintTitle,
                      hintStyle: const TextStyle(
                          color: Colors.black45, fontSize: 13.0),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                          padding: const EdgeInsets.only(bottom: 5),
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                          }),
                      contentPadding: const EdgeInsets.only(left: 8.0),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusColor: Colors.blue,
                      isDense: true,
                    ),
                    onSubmitted: (text) => widget.searchAction?.call(text),
                  ),
                )),
          ),
          TextButton(
              onPressed: () => widget.cancelAction?.call(),
              child: Text(
                UseL10n.of(context)?.cancelButtonTitle ?? '',
                style: const TextStyle(color: ColorDef.appBarTitleColor),
              ))
        ]),
      ),
    );
  }
}
