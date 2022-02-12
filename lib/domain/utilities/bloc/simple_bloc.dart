import 'dart:async';

import 'abstract_bloc.dart';

mixin SimpleBloc<Output> implements AbstractBloc {
  final _controller = StreamController<Output>();

  @override
  Stream<Output> get stream => _controller.stream;
  void streamAdd(Output value) => _controller.sink.add(value);

  bool get isClosed {
    return _controller.isClosed;
  }

  @override
  void dispose() {
    _controller.close();
  }
}
