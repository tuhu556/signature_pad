import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:signature_pad/matrix_gesture_detector.dart';

typedef PointMoveCallback = void Function(Offset offset);

class OverlaySignature extends StatelessWidget {
  final Widget child;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final PointMoveCallback onDragUpdate;
  const OverlaySignature({
    super.key,
    required this.child,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return Listener(
      onPointerMove: (event) {
        onDragUpdate(event.localPosition);
      },
      child: MatrixGestureDetector(
        onMatrixUpdate: (matrix, translationDeltaMatrix, scaleDeltaMatrix,
            rotationDeltaMatrix) {
          notifier.value = matrix;
        },
        onScaleStart: () {
          onDragStart();
        },
        onScaleEnd: () {
          onDragEnd();
        },
        child: AnimatedBuilder(
          animation: notifier,
          child: child,
          builder: (context, child) {
            return Transform(
              transform: notifier.value,
              child: Align(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: DottedBorder(
                      color: Colors.black38,
                      strokeWidth: 1,
                      child: child ?? Container()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
