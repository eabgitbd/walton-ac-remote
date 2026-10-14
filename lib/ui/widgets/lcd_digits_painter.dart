import 'package:flutter/material.dart';

class LcdDigitsPainter extends CustomPainter {
  final int value;
  final bool isPowerOn;
  final Color activeColor;
  final Color ghostColor;

  LcdDigitsPainter({
    required this.value,
    required this.isPowerOn,
    this.activeColor = const Color(0xFF142113),
    this.ghostColor = const Color(0x28142113),
  });

  // 7-segment bitmask: A, B, C, D, E, F, G
  // Bit 0: Top (A)
  // Bit 1: Top-Right (B)
  // Bit 2: Bottom-Right (C)
  // Bit 3: Bottom (D)
  // Bit 4: Bottom-Left (E)
  // Bit 5: Top-Left (F)
  // Bit 6: Middle (G)
  static const List<int> digitPatterns = [
    0x3F, // 0: A B C D E F
    0x06, // 1: B C
    0x5B, // 2: A B D E G
    0x4F, // 3: A B C D G
    0x66, // 4: B C F G
    0x6D, // 5: A C D F G
    0x7D, // 6: A C D E F G
    0x07, // 7: A B C
    0x7F, // 8: A B C D E F G
    0x6F, // 9: A B C D F G
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final digitWidth = size.width * 0.38;
    final digitHeight = size.height;
    final gap = size.width * 0.08;

    final d1 = (value ~/ 10).clamp(0, 9);
    final d2 = (value % 10).clamp(0, 9);

    // Draw first digit
    _drawDigit(canvas, Offset(0, 0), digitWidth, digitHeight, d1);

    // Draw second digit
    _drawDigit(canvas, Offset(digitWidth + gap, 0), digitWidth, digitHeight, d2);

    // Draw °C
    _drawCelsiusSymbol(canvas, Offset(size.width * 0.86, size.height * 0.1), size.height * 0.8);
  }

  void _drawDigit(Canvas canvas, Offset offset, double w, double h, int digit) {
    final pattern = isPowerOn ? digitPatterns[digit] : 0;
    final thickness = w * 0.18;
    final h2 = h / 2;

    // Segment A (Top)
    _drawHorizontalSegment(canvas, offset.dx + thickness * 0.8, offset.dy, w - thickness * 1.6, thickness, (pattern & 0x01) != 0);

    // Segment B (Top-Right)
    _drawVerticalSegment(canvas, offset.dx + w - thickness, offset.dy + thickness * 0.8, thickness, h2 - thickness * 1.2, (pattern & 0x02) != 0);

    // Segment C (Bottom-Right)
    _drawVerticalSegment(canvas, offset.dx + w - thickness, offset.dy + h2 + thickness * 0.4, thickness, h2 - thickness * 1.2, (pattern & 0x04) != 0);

    // Segment D (Bottom)
    _drawHorizontalSegment(canvas, offset.dx + thickness * 0.8, offset.dy + h - thickness, w - thickness * 1.6, thickness, (pattern & 0x08) != 0);

    // Segment E (Bottom-Left)
    _drawVerticalSegment(canvas, offset.dx, offset.dy + h2 + thickness * 0.4, thickness, h2 - thickness * 1.2, (pattern & 0x10) != 0);

    // Segment F (Top-Left)
    _drawVerticalSegment(canvas, offset.dx, offset.dy + thickness * 0.8, thickness, h2 - thickness * 1.2, (pattern & 0x20) != 0);

    // Segment G (Middle)
    _drawHorizontalSegment(canvas, offset.dx + thickness * 0.8, offset.dy + h2 - thickness * 0.5, w - thickness * 1.6, thickness, (pattern & 0x40) != 0);
  }

  void _drawHorizontalSegment(Canvas canvas, double x, double y, double length, double t, bool lit) {
    final paint = Paint()
      ..color = lit ? activeColor : ghostColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(x, y + t / 2)
      ..lineTo(x + t / 2, y)
      ..lineTo(x + length - t / 2, y)
      ..lineTo(x + length, y + t / 2)
      ..lineTo(x + length - t / 2, y + t)
      ..lineTo(x + t / 2, y + t)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawVerticalSegment(Canvas canvas, double x, double y, double t, double length, bool lit) {
    final paint = Paint()
      ..color = lit ? activeColor : ghostColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(x + t / 2, y)
      ..lineTo(x + t, y + t / 2)
      ..lineTo(x + t, y + length - t / 2)
      ..lineTo(x + t / 2, y + length)
      ..lineTo(x, y + length - t / 2)
      ..lineTo(x, y + t / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawCelsiusSymbol(Canvas canvas, Offset offset, double h) {
    final activePaint = Paint()
      ..color = isPowerOn ? activeColor : ghostColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Degree circle
    canvas.drawCircle(Offset(offset.dx + 4, offset.dy + 8), 4.5, activePaint);

    // Letter C
    final cPaint = Paint()
      ..color = isPowerOn ? activeColor : ghostColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 4.0;

    final cPath = Path()
      ..moveTo(offset.dx + 26, offset.dy + 18)
      ..lineTo(offset.dx + 8, offset.dy + 18)
      ..lineTo(offset.dx + 8, offset.dy + h * 0.65)
      ..lineTo(offset.dx + 26, offset.dy + h * 0.65);

    canvas.drawPath(cPath, cPaint);
  }

  @override
  bool shouldRepaint(covariant LcdDigitsPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.isPowerOn != isPowerOn ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.ghostColor != ghostColor;
  }
}
