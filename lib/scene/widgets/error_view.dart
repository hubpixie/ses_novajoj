import 'package:flutter/material.dart';

typedef FirstButtonAction = void Function();

class ErrorView extends StatelessWidget {
  final String message;
  final FirstButtonAction? onFirstButtonTap;

  const ErrorView({Key? key, required this.message, this.onFirstButtonTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(children: () {
        List<Widget> widgets = [];
        widgets.add(const SizedBox(height: 100));
        widgets.add(Container(
            height: 100,
            width: MediaQuery.of(context).size.width - 100,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xffc5c5c5), width: 0.5),
                right: BorderSide(color: Color(0xffc5c5c5), width: 0.5),
                bottom: BorderSide(color: Color(0xffc5c5c5), width: 0.5),
                left: BorderSide(color: Color(0xffc5c5c5), width: 0.5),
              ),
            ),
            child: Text(message)));
        widgets.add(const SizedBox(height: 10));
        if (onFirstButtonTap != null) {
          widgets.add(
              TextButton(onPressed: onFirstButtonTap, child: const Text('OK')));
        }
        return widgets;
      }()),
    );
  }
}
