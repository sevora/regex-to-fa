import 'package:flutter/material.dart';
import 'package:regex_to_fa_mobile/utilities/painter.dart';
import 'algorithms/thompson_construction.dart';

/// This is a Thompson Construction Painter.
/// It includes the transition diagram and transition table
/// upon applying Thompson's construction.
class ThompsonConstructionPainter extends CustomPainter {
  final String postfixExpression;

  ThompsonConstructionPainter(this.postfixExpression);

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 30;
    const double lineLength = 60;

    final tree = thompsonConstruction(postfixExpression);
    final List<AutomatonState> renderedNodes = [];
    final List<Offset> renderedPositions = [];

    if (tree != null) {
      renderNode(canvas, "ε", tree, null, 0, radius, lineLength, renderedNodes, renderedPositions);
      renderTable(canvas, tree, 20, 150);
    }
  }

  /// This is used to render the nodes individually and draw arrows connecting
  /// them that is why this demands the previous node.
  /// @param label the label of the transition
  /// @param node the root or current node
  /// @param previousNode the previous node
  /// @param offsetY the offsetY used for layouting
  /// @returns
  void renderNode(Canvas canvas, String? label, AutomatonState node, AutomatonState? previousNode, double offsetY, double radius, double lineLength,
      List<AutomatonState> renderedNodes, List<Offset> renderedPositions) {

    final int previousStateIndex = previousNode != null ? renderedNodes.indexOf(previousNode) : -1;
    final Offset previousPosition = previousStateIndex > -1 ? renderedPositions[previousStateIndex] : const Offset(0, 0);

    final int existIndex = renderedNodes.indexOf(node);

    final Paint arrowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    if (existIndex > -1) {
      final Offset targetPosition = renderedPositions[existIndex];

      // the assumption is that when the direction is backwards,
      // the arrow should be curved
      if (targetPosition.dx < previousPosition.dx) {
        final Offset topOrigin = previousPosition + Offset(radius, -radius);
        final Offset topTarget = targetPosition + Offset(radius, -radius);
        final Offset midPoint = (topOrigin + topTarget) / 2;
        final Offset topMidPoint = Offset(
            midPoint.dx,
            midPoint.dy - (topOrigin.dx - topTarget.dx).abs() * 0.05
        );
        drawArrowCurved(canvas, arrowPaint, topOrigin, topTarget, topMidPoint);
      } else {
        drawArrow(canvas, arrowPaint, previousPosition + Offset(radius * 2, 0), targetPosition);
      }

      return;
    }

    final double x = previousPosition.dx + lineLength;
    final double y = previousPosition.dy + offsetY * 1.1 * radius * 2;
    drawArrow(canvas, arrowPaint, previousPosition + Offset(radius * 2, 0), Offset(x + lineLength, y));

    // Draw the label of the transition
    final TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: label ?? 'ε',
        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'monospace'),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainter.paint(canvas, Offset(x + lineLength/2 - labelPainter.width, y - 20));

    final Paint circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    circlePaint.strokeWidth = 1;

    // Draw the circular state
    canvas.drawCircle(Offset(x + lineLength + radius, y), radius, circlePaint..style = PaintingStyle.stroke..color = Colors.black);

    if (node.transitions.isEmpty) {
      // Draw the circular state
      canvas.drawCircle(Offset(x + lineLength + radius, y), radius * 0.8, circlePaint..style = PaintingStyle.stroke..color = Colors.black);
    }

    // Draw the text inside the circular state
    final TextPainter statePainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'monospace'),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();

    statePainter.paint(canvas, Offset(x + lineLength + radius - statePainter.width / 2, y - statePainter.height / 2));

    if (!renderedNodes.contains(node)) {
      renderedNodes.add(node);
      renderedPositions.add(Offset(x + lineLength, y));
    }

    for (var index = 0; index < node.transitions.length; ++index) {
      var transition = node.transitions[index];
      renderNode(canvas, transition.label, transition.state, node, index.toDouble(), radius, lineLength, renderedNodes, renderedPositions);
    }
  }

  /// This renders the table for the given tree.
  /// @param node the root node
  /// @param startX the starting x-coordinate
  /// @param startY the starting y-coordinate
  void renderTable(Canvas canvas, AutomatonState node, double startX, double startY) {
    // Assume getTransitionTable is defined and returns a List<List<String>>
    var table = getTransitionTable(node);
    double cellWidth = 100.0;
    double cellHeight = 30.0;

    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    for (int y = 0; y < table.length; ++y) {
      List<String> row = table[y];
      for (int x = 0; x < row.length; ++x) {
        String value = row[x];

        // Draw the cell border
        canvas.drawRect(
          Rect.fromLTWH(
            startX + x * cellWidth,
            startY + y * cellHeight,
            cellWidth,
            cellHeight,
          ),
          paint..color = const Color(0xFF000000),
        );

        // Draw the text inside the cell
        final textPainter = TextPainter(
          text: TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'monospace'
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            startX + x * cellWidth + (cellWidth - textPainter.width) / 2,
            startY + y * cellHeight + (cellHeight - textPainter.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}