import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef ViewEndEditingDelegate = void Function(bool);

class FocusDismiss extends StatelessWidget {
  const FocusDismiss({Key? key, required this.child, this.onEndEditing})
      : super(key: key);

  final Widget child;
  final ViewEndEditingDelegate? onEndEditing;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (e) {
        final rb = context.findRenderObject() as RenderBox;
        final result = BoxHitTestResult();
        rb.hitTest(result, position: e.position);

        final hitTargetIsEditable =
            result.path.any((entry) => entry.target is RenderEditable);

        bool focusFlg = true;
        if (!hitTargetIsEditable) {
          final currentFocus = FocusScope.of(context);
          focusFlg = false;
          currentFocus.unfocus();
        }
        onEndEditing?.call(focusFlg);
      },
      child: child,
    );
  }
}
