import 'package:flutter/material.dart';
import 'package:regex_to_fa_mobile/utilities/painter.dart';
import 'algorithms/thompson_construction.dart';

class ThompsonConstructionPainter extends CustomPainter {
  final String postfixExpression;

  ThompsonConstructionPainter(this.postfixExpression);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint diagramPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    final Paint tablePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    const double radius = 30;
    const double lineLength = 60;

    final tree = thompsonConstruction(postfixExpression);
    final List<AutomatonState> renderedNodes = [];
    final List<Offset> renderedPositions = [];

    if (tree != null) {
      renderNode(canvas, diagramPaint, "ε", tree, null, 0, radius, lineLength, renderedNodes, renderedPositions);
      renderTable(canvas, tablePaint, tree, 20, 150);
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
    final double y = previousPosition.dy + offsetY * 1.1 * radius * 2;
    drawArrow(canvas, paint, previousPosition + Offset(radius * 2, 0), Offset(x + lineLength, y));

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

    // Draw the circular state
    canvas.drawCircle(Offset(x + lineLength + radius, y), radius, paint..style = PaintingStyle.fill..color = Colors.white);
    canvas.drawCircle(Offset(x + lineLength + radius, y), radius, paint..style = PaintingStyle.stroke..color = Colors.black);

    // Draw the text inside the circular state
    final TextPainter statePainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'monospace'),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    statePainter.paint(canvas, Offset(x + lineLength + statePainter.width, y - statePainter.height / 2));

    if (!renderedNodes.contains(node)) {
      renderedNodes.add(node);
      renderedPositions.add(Offset(x + lineLength, y));
    }

    for (var index = 0; index < node.transitions.length; ++index) {
      var transition = node.transitions[index];
      renderNode(canvas, paint, transition.label, transition.state, node, index.toDouble(), radius, lineLength, renderedNodes, renderedPositions);
    }
  }

  void renderTable(Canvas canvas, Paint paint, AutomatonState node, double startX, double startY) {
    // Assume getTransitionTable is defined and returns a List<List<String>>
    var table = getTransitionTable(node);
    double cellWidth = 100.0;
    double cellHeight = 30.0;

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
              fontFamily: 'monospace',
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