import 'package:flutter/material.dart';

class Arrow extends StatelessWidget {
  const Arrow({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _ArrowPainter(
        color: Color(0xFF16A34A),
      ),
      size: Size(39, 26),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // This following code is generated from SVG by:
    // https://fluttershapemaker.com.

    final path = Path()
      ..moveTo(size.width * 0.6833268, size.height * 0.1401889)
      ..cubicTo(
        size.width * 0.7205854,
        size.height * 0.1010057,
        size.width * 0.8177707,
        size.height * 0.02548514,
        size.width * 0.9084341,
        size.height * 0.03687036,
      )
      ..moveTo(size.width * 0.9754829, size.height * 0.3726321)
      ..cubicTo(
        size.width * 0.9769780,
        size.height * 0.3050479,
        size.width * 0.9658463,
        size.height * 0.1435043,
        size.width * 0.9093415,
        size.height * 0.03801393,
      )
      ..moveTo(size.width * 0.02439024, size.height * 0.9642857)
      ..cubicTo(
        size.width * 0.2805171,
        size.height * 0.8569429,
        size.width * 0.6689756,
        size.height * 0.7012036,
        size.width * 0.8980683,
        size.height * 0.05715500,
      );

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
