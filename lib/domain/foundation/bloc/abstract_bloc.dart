abstract class AbstractBloc<Output> {
  Stream<Output> get stream;
  void dispose();
}
