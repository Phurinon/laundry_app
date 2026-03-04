import 'dart:math';
import 'package:flutter/material.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';

/// A beautiful custom-painted illustration for washing machines and dryers.
class MachineIllustration extends StatelessWidget {
  final MachineType machineType;
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool showShadow;

  const MachineIllustration({
    super.key,
    required this.machineType,
    this.size = 56,
    this.primaryColor,
    this.secondaryColor,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWasher = machineType == MachineType.washer;
    final mainColor =
        primaryColor ?? (isWasher ? AppTheme.primary : AppTheme.accent);
    final subColor =
        secondaryColor ??
        (isWasher ? AppTheme.primaryLight : AppTheme.accentLight);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: isWasher
            ? _WasherPainter(
                mainColor: mainColor,
                subColor: subColor,
                showShadow: showShadow,
              )
            : _DryerPainter(
                mainColor: mainColor,
                subColor: subColor,
                showShadow: showShadow,
              ),
      ),
    );
  }
}

/// Painter for a front-loading washing machine
class _WasherPainter extends CustomPainter {
  final Color mainColor;
  final Color subColor;
  final bool showShadow;

  _WasherPainter({
    required this.mainColor,
    required this.subColor,
    required this.showShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Padding
    final pad = w * 0.08;
    final machineRect = Rect.fromLTWH(pad, pad, w - pad * 2, h - pad * 2);

    // ── Machine body (rounded rectangle) ──
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          subColor.withValues(alpha: 0.3),
        ],
      ).createShader(machineRect);

    final bodyRRect = RRect.fromRectAndRadius(
      machineRect,
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Body border
    final borderPaint = Paint()
      ..color = mainColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawRRect(bodyRRect, borderPaint);

    // ── Control panel (top section) ──
    final panelRect = Rect.fromLTWH(
      pad + w * 0.06,
      pad + w * 0.06,
      w - pad * 2 - w * 0.12,
      h * 0.14,
    );
    final panelPaint = Paint()..color = mainColor.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, Radius.circular(w * 0.04)),
      panelPaint,
    );

    // Small buttons on panel
    final btnPaint = Paint()..color = mainColor.withValues(alpha: 0.5);
    final btnRadius = w * 0.025;
    // left button
    canvas.drawCircle(
      Offset(panelRect.left + panelRect.width * 0.2, panelRect.center.dy),
      btnRadius,
      btnPaint,
    );
    // middle button
    canvas.drawCircle(
      Offset(panelRect.left + panelRect.width * 0.45, panelRect.center.dy),
      btnRadius,
      btnPaint,
    );
    // knob (right side)
    final knobPaint = Paint()..color = mainColor.withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(panelRect.left + panelRect.width * 0.78, panelRect.center.dy),
      btnRadius * 1.5,
      knobPaint,
    );
    canvas.drawCircle(
      Offset(panelRect.left + panelRect.width * 0.78, panelRect.center.dy),
      btnRadius * 0.6,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );

    // ── Drum (circle window) ──
    final drumCenter = Offset(w * 0.5, h * 0.57);
    final drumRadius = w * 0.26;

    // Outer ring of the door
    final doorRingPaint = Paint()
      ..color = mainColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    canvas.drawCircle(drumCenter, drumRadius, doorRingPaint);

    // Glass (gradient fill)
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [
          mainColor.withValues(alpha: 0.08),
          mainColor.withValues(alpha: 0.25),
        ],
      ).createShader(Rect.fromCircle(center: drumCenter, radius: drumRadius));
    canvas.drawCircle(drumCenter, drumRadius - w * 0.02, glassPaint);

    // Water / swirl effect inside drum
    _drawWaterSwirl(canvas, drumCenter, drumRadius * 0.6, mainColor);

    // Bubbles
    _drawBubbles(canvas, drumCenter, drumRadius, mainColor);

    // Glass highlight (crescent)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: drumCenter, radius: drumRadius * 0.72),
      -pi * 0.7,
      pi * 0.5,
      false,
      highlightPaint,
    );

    // ── Feet ──
    final footPaint = Paint()..color = mainColor.withValues(alpha: 0.35);
    final footW = w * 0.06;
    final footH = h * 0.03;
    final footY = machineRect.bottom - footH * 0.5;
    // left foot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(machineRect.left + w * 0.14, footY),
          width: footW,
          height: footH,
        ),
        Radius.circular(footH * 0.4),
      ),
      footPaint,
    );
    // right foot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(machineRect.right - w * 0.14, footY),
          width: footW,
          height: footH,
        ),
        Radius.circular(footH * 0.4),
      ),
      footPaint,
    );
  }

  void _drawWaterSwirl(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final path = Path();
    // Wavy line through center
    final waveY = center.dy + radius * 0.15;
    path.moveTo(center.dx - radius, waveY);
    path.quadraticBezierTo(
      center.dx - radius * 0.4,
      waveY - radius * 0.35,
      center.dx,
      waveY,
    );
    path.quadraticBezierTo(
      center.dx + radius * 0.4,
      waveY + radius * 0.35,
      center.dx + radius,
      waveY,
    );
    path.lineTo(center.dx + radius, center.dy + radius);
    path.lineTo(center.dx - radius, center.dy + radius);
    path.close();

    final waterPaint = Paint()..color = color.withValues(alpha: 0.15);
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(path, waterPaint);
    canvas.restore();
  }

  void _drawBubbles(
    Canvas canvas,
    Offset center,
    double drumRadius,
    Color color,
  ) {
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final bubbleBorderPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bubbles = [
      Offset(center.dx - drumRadius * 0.25, center.dy - drumRadius * 0.15),
      Offset(center.dx + drumRadius * 0.2, center.dy - drumRadius * 0.3),
      Offset(center.dx + drumRadius * 0.35, center.dy + drumRadius * 0.05),
      Offset(center.dx - drumRadius * 0.1, center.dy + drumRadius * 0.25),
    ];
    final radii = [
      drumRadius * 0.08,
      drumRadius * 0.06,
      drumRadius * 0.05,
      drumRadius * 0.07,
    ];

    for (var i = 0; i < bubbles.length; i++) {
      canvas.drawCircle(bubbles[i], radii[i], bubblePaint);
      canvas.drawCircle(bubbles[i], radii[i], bubbleBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for a clothes dryer
class _DryerPainter extends CustomPainter {
  final Color mainColor;
  final Color subColor;
  final bool showShadow;

  _DryerPainter({
    required this.mainColor,
    required this.subColor,
    required this.showShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pad = w * 0.08;
    final machineRect = Rect.fromLTWH(pad, pad, w - pad * 2, h - pad * 2);

    // ── Machine body ──
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          subColor.withValues(alpha: 0.3),
        ],
      ).createShader(machineRect);

    final bodyRRect = RRect.fromRectAndRadius(
      machineRect,
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Body border
    final borderPaint = Paint()
      ..color = mainColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawRRect(bodyRRect, borderPaint);

    // ── Control panel (top section) ──
    final panelRect = Rect.fromLTWH(
      pad + w * 0.06,
      pad + w * 0.06,
      w - pad * 2 - w * 0.12,
      h * 0.14,
    );
    final panelPaint = Paint()..color = mainColor.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, Radius.circular(w * 0.04)),
      panelPaint,
    );

    // Temperature indicator lights
    final lightColors = [
      mainColor.withValues(alpha: 0.3),
      mainColor.withValues(alpha: 0.5),
      mainColor.withValues(alpha: 0.8),
    ];
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(
          panelRect.left + panelRect.width * (0.2 + i * 0.15),
          panelRect.center.dy,
        ),
        w * 0.02,
        Paint()..color = lightColors[i],
      );
    }

    // Digital display area
    final displayRect = Rect.fromLTWH(
      panelRect.left + panelRect.width * 0.65,
      panelRect.top + panelRect.height * 0.2,
      panelRect.width * 0.28,
      panelRect.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(displayRect, Radius.circular(w * 0.015)),
      Paint()..color = mainColor.withValues(alpha: 0.2),
    );

    // ── Drum (circle window) ──
    final drumCenter = Offset(w * 0.5, h * 0.57);
    final drumRadius = w * 0.26;

    // Outer ring
    final doorRingPaint = Paint()
      ..color = mainColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    canvas.drawCircle(drumCenter, drumRadius, doorRingPaint);

    // Glass fill
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [
          mainColor.withValues(alpha: 0.05),
          mainColor.withValues(alpha: 0.18),
        ],
      ).createShader(Rect.fromCircle(center: drumCenter, radius: drumRadius));
    canvas.drawCircle(drumCenter, drumRadius - w * 0.02, glassPaint);

    // ── Heat waves inside drum ──
    _drawHeatWaves(canvas, drumCenter, drumRadius * 0.55, mainColor);

    // ── Tumbling clothes dots ──
    _drawClothes(canvas, drumCenter, drumRadius * 0.5, mainColor);

    // Glass highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: drumCenter, radius: drumRadius * 0.72),
      -pi * 0.7,
      pi * 0.5,
      false,
      highlightPaint,
    );

    // Vent holes (bottom right of machine)
    final ventPaint = Paint()..color = mainColor.withValues(alpha: 0.2);
    for (var i = 0; i < 3; i++) {
      final ventY = machineRect.bottom - h * 0.08;
      final ventX = machineRect.right - w * 0.1 - i * w * 0.06;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(ventX, ventY),
            width: w * 0.025,
            height: h * 0.04,
          ),
          Radius.circular(w * 0.01),
        ),
        ventPaint,
      );
    }

    // ── Feet ──
    final footPaint = Paint()..color = mainColor.withValues(alpha: 0.35);
    final footW = w * 0.06;
    final footH = h * 0.03;
    final footY = machineRect.bottom - footH * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(machineRect.left + w * 0.14, footY),
          width: footW,
          height: footH,
        ),
        Radius.circular(footH * 0.4),
      ),
      footPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(machineRect.right - w * 0.14, footY),
          width: footW,
          height: footH,
        ),
        Radius.circular(footH * 0.4),
      ),
      footPaint,
    );
  }

  void _drawHeatWaves(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final wavePaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    // Three wavy lines representing heat
    for (var i = -1; i <= 1; i++) {
      final xOff = i * radius * 0.35;
      final path = Path();
      final startY = center.dy - radius * 0.5;
      path.moveTo(center.dx + xOff, startY);
      path.quadraticBezierTo(
        center.dx + xOff + radius * 0.15,
        startY + radius * 0.3,
        center.dx + xOff,
        startY + radius * 0.6,
      );
      path.quadraticBezierTo(
        center.dx + xOff - radius * 0.15,
        startY + radius * 0.9,
        center.dx + xOff,
        startY + radius * 1.2,
      );
      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawClothes(Canvas canvas, Offset center, double radius, Color color) {
    // Small fabric-like shapes
    final clothPaint = Paint()..color = color.withValues(alpha: 0.18);
    final positions = [
      Offset(center.dx - radius * 0.4, center.dy + radius * 0.3),
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.1, center.dy - radius * 0.4),
    ];
    final sizes = [radius * 0.18, radius * 0.14, radius * 0.16];

    for (var i = 0; i < positions.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: positions[i],
            width: sizes[i] * 2,
            height: sizes[i],
          ),
          Radius.circular(sizes[i] * 0.4),
        ),
        clothPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A category icon widget that shows a small machine with a label-like style
class MachineCategoryIcon extends StatelessWidget {
  final MachineType? machineType; // null = "all" or "available"
  final bool isAvailable;
  final double size;
  final Color? color;

  const MachineCategoryIcon({
    super.key,
    this.machineType,
    this.isAvailable = false,
    this.size = 36,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (machineType != null) {
      return MachineIllustration(
        machineType: machineType!,
        size: size,
        primaryColor: color,
        secondaryColor: color?.withValues(alpha: 0.3),
      );
    }

    // For "available" or "all" category, use styled icons
    if (isAvailable) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _AvailablePainter(color: color ?? AppTheme.success),
        ),
      );
    }

    // "All" category
    return Icon(
      Icons.grid_view_rounded,
      size: size,
      color: color ?? AppTheme.neutral400,
    );
  }
}

class _AvailablePainter extends CustomPainter {
  final Color color;

  _AvailablePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Circle background
    canvas.drawCircle(
      center,
      w * 0.38,
      Paint()..color = color.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      center,
      w * 0.38,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04,
    );

    // Checkmark
    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(w * 0.3, h * 0.5);
    path.lineTo(w * 0.45, h * 0.64);
    path.lineTo(w * 0.7, h * 0.36);
    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
