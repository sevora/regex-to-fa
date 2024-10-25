import 'package:flutter/material.dart';

import 'package:regex_to_fa_mobile/utilities/painter.dart';

class ThompsonConstructionRenderer extends StatelessWidget {
  final String postfixExpression;

  const ThompsonConstructionRenderer({super.key, required this.postfixExpression});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(1920, 1080), // Set desired canvas size
      painter: ThompsonConstructionPainter(postfixExpression),
    );
  }
}

class ThompsonConstructionPainter extends CustomPainter {
  final String postfixExpression;

  ThompsonConstructionPainter(this.postfixExpression);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const double lineLength = 90;
    const double radius = 50;

    // Generate the automaton tree from the postfix expression
    final tree = thompsonConstruction(postfixExpression);

    List<AutomatonState> renderedNodes = [];
    List<Offset> renderedPositions = [];
    int stateVisualIndex = 0;

    if (tree != null) {
      canvas.drawColor(Colors.white, BlendMode.src);
      render(canvas, paint, circlePaint, tree, null, lineLength, radius, renderedNodes, renderedPositions, stateVisualIndex);
    }
  }

  void render(Canvas canvas, Paint paint, Paint circlePaint, AutomatonState node, AutomatonState? previousState,
      double lineLength, double radius, List<AutomatonState> renderedNodes, List<Offset> renderedPositions, int stateVisualIndex) {
    
    // Iterate through transitions of the current node
    for (int index = 0; index < node.transitions.length; index++) {
      final AutomatonTransition transition = node.transitions[index];
      final String transitionLabel = transition[0]; // Get the transition label
      final AutomatonState targetState = transition[1]; // Get the target state

      final previousPosition = previousState != null
          ? renderedPositions[renderedNodes.indexOf(previousState)]
          : const Offset(0, 150);

      final existIndex = renderedNodes.indexOf(targetState);

      if (existIndex > -1) {
        final targetPosition = renderedPositions[existIndex];
        drawArrow(canvas, paint, previousPosition, targetPosition);
        continue;
      }

      final double x = previousPosition.dx + lineLength;
      final double y = previousPosition.dy + index * radius * 2;

      drawArrow(canvas, paint, previousPosition.translate(radius * 2, 0), Offset(x + lineLength, y));

      // Draw transition label
      final transitionText = transitionLabel.isEmpty ? "ε" : transitionLabel;
      _drawText(canvas, transitionText, x + lineLength / 2 - 16, y - 10, paint);

      // Draw state
      canvas.drawCircle(Offset(x + lineLength + radius, y), radius, circlePaint);
      canvas.drawCircle(Offset(x + lineLength + radius, y), radius, paint);

      _drawText(canvas, 'q$stateVisualIndex', x + lineLength + radius / 2, y, paint);

      if (!renderedNodes.contains(targetState)) {
        renderedNodes.add(targetState);
        renderedPositions.add(Offset(x + lineLength, y));
      }

      render(canvas, paint, circlePaint, targetState, node, lineLength, radius, renderedNodes, renderedPositions, stateVisualIndex);
      stateVisualIndex++;
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, Paint paint) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: paint.color, fontSize: 32)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Return true to redraw on every update
  }
}

// Placeholder for AutomatonState and thompsonConstruction
class AutomatonState {
  String? label;
  List<AutomatonTransition> transitions;

  AutomatonState({this.label, List<AutomatonTransition>? transitions})
      : transitions = transitions ?? [];
}

/// An AutomatonTransition is a tuple containing
/// a string and an AutomatonState.
typedef AutomatonTransition = List<dynamic>;

AutomatonState? thompsonConstruction(String postfixExpression) {
  // Implement the construction logic here
  return null; // Replace with actual logic
}
