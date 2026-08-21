import 'package:flutter/material.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';

class FKLogo extends StatelessWidget {
  final double size;
  
  const FKLogo({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background Glow
          Center(
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          
          // Main Logo Shape
          CustomPaint(
            size: Size(size, size),
            painter: _LogoPainter(color: AppColors.primary),
          ),
          
          // Glass Shine
          Positioned(
            top: size * 0.1,
            left: size * 0.1,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Gradient for premium feel
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color, color.withAlpha(200)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    paint.shader = gradient;

    // Draw stylized bag shape
    final bagPath = Path()
      ..moveTo(w * 0.2, h * 0.3)
      ..lineTo(w * 0.8, h * 0.3)
      ..lineTo(w * 0.85, h * 0.8)
      ..quadraticBezierTo(w * 0.85, h * 0.9, w * 0.75, h * 0.9)
      ..lineTo(w * 0.25, h * 0.9)
      ..quadraticBezierTo(w * 0.15, h * 0.9, w * 0.15, h * 0.8)
      ..close();

    final handlePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.3), radius: w * 0.15));

    final handleClip = Path()
      ..addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.3), radius: w * 0.1));

    final actualHandle = Path.combine(PathOperation.difference, handlePath, handleClip);
    
    canvas.drawPath(bagPath, paint);
    canvas.drawPath(actualHandle, paint);

    // Draw "FK" text or monogram inside
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'FK',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.25,
          fontWeight: FontWeight.bold,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w * 0.5 - textPainter.width * 0.5, h * 0.5 - textPainter.height * 0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
