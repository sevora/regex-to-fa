import 'package:flutter/material.dart';
import 'package:regex_to_fa_mobile/utilities/painter.dart';
import 'algorithms/thompson_construction.dart';

class ThompsonConstructionPainter extends CustomPainter {
  final String postfixExpression;

  ThompsonConstructionPainter(this.postfixExpression);
  int stateVisualIndex = 0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    const double radius = 30;
    const double lineLength = 60;

    final tree = thompsonConstruction(postfixExpression);
    final List<AutomatonState> renderedNodes = [];
    final List<Offset> renderedPositions = [];

    stateVisualIndex = 0;

    if (tree != null) {
      renderNode(canvas, paint, "s1", tree, null, 0, radius, lineLength, renderedNodes, renderedPositions);
    }
  }

  void renderNode(Canvas canvas, Paint paint, String? label, AutomatonState node, AutomatonState? previousNode, double offsetY, double radius, double lineLength,
      List<AutomatonState> renderedNodes, List<Offset> renderedPositions) {

    final int previousStateIndex = previousNode != null ? renderedNodes.indexOf(previousNode) : -1;
    final Offset previousPosition = previousStateIndex > -1 ? renderedPositions[previousStateIndex] : const Offset(0, 0);

    final int existIndex = renderedNodes.indexOf(node);

    if (existIndex > -1) {
      final Offset targetPosition = renderedPositions[existIndex];
      drawArrow(canvas, paint, previousPosition + Offset(radius * 2, 0), targetPosition);
      return;
    }

    final double x = previousPosition.dx + lineLength;
    final double y = previousPosition.dy + offsetY * radius * 2;
    drawArrow(canvas, paint, previousPosition + Offset(radius * 2, 0), Offset(x + lineLength, y));

    // Draw the label of the transition
    final TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: label ?? 'ε',
        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainter.paint(canvas, Offset(x + lineLength / 2 - 8, y - 20));

    // Draw the circular state
    canvas.drawCircle(Offset(x + lineLength + radius, y), radius, paint..style = PaintingStyle.fill..color = Colors.white);
    canvas.drawCircle(Offset(x + lineLength + radius, y), radius, paint..style = PaintingStyle.stroke..color = Colors.black);

    // Draw the text inside the circular state
    final TextPainter statePainter = TextPainter(
      text: TextSpan(
        text: 'q$stateVisualIndex',
        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    statePainter.paint(canvas, Offset(x + lineLength + radius / 2, y - statePainter.height / 2));

    stateVisualIndex++;

    if (!renderedNodes.contains(node)) {
      renderedNodes.add(node);
      renderedPositions.add(Offset(x + lineLength, y));
    }

    for (var index = 0; index < node.transitions.length; ++index) {
      var transition = node.transitions[index];
      renderNode(canvas, paint, transition.label, transition.state, node, index.toDouble(), radius, lineLength, renderedNodes, renderedPositions);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}