import 'dart:math';
import 'package:flutter/material.dart';

/// Painter base que dibuja una hoja con una forma (path) determinada.
/// Los subclases definen el path específico.
abstract class LeafShapePainter extends CustomPainter {
  final Color color;

  LeafShapePainter({this.color = const Color(0xFF2D8C2D)});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  /// Dibuja el contorno de la hoja con relleno y borde.
  void drawLeaf(Canvas canvas, Size size, Path path) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Nervadura central
    _drawMidrib(canvas, size, path);
  }

  void _drawMidrib(Canvas canvas, Size size, Path path) {
    final midribPaint = Paint()
      ..color = const Color(0xFF1A6B1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final midPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.5,
        size.height * 0.15,
      );

    canvas.drawPath(midPath, midribPaint);
  }
}

// ============================================================
// LEAF SHAPE PAINTERS
// ============================================================

/// Hoja Lanceolada: forma estrecha, puntiaguda en ambos extremos
class LanceoladaPainter extends LeafShapePainter {
  LanceoladaPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.05) // Punta superior
      ..cubicTo(w * 0.7, h * 0.2, w * 0.72, h * 0.4, w * 0.68, h * 0.55)
      ..cubicTo(
        w * 0.64,
        h * 0.7,
        w * 0.58,
        h * 0.85,
        w * 0.5,
        h * 0.95,
      ) // Punta inferior
      ..cubicTo(w * 0.42, h * 0.85, w * 0.36, h * 0.7, w * 0.32, h * 0.55)
      ..cubicTo(w * 0.28, h * 0.4, w * 0.3, h * 0.2, w * 0.5, h * 0.05)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

/// Hoja Elíptica: ovalada con el ancho máximo en el centro
class ElipticaPainter extends LeafShapePainter {
  ElipticaPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.08) // Punta superior
      ..cubicTo(w * 0.78, h * 0.2, w * 0.82, h * 0.4, w * 0.78, h * 0.5)
      ..cubicTo(
        w * 0.74,
        h * 0.65,
        w * 0.65,
        h * 0.82,
        w * 0.5,
        h * 0.92,
      ) // Punta inferior
      ..cubicTo(w * 0.35, h * 0.82, w * 0.26, h * 0.65, w * 0.22, h * 0.5)
      ..cubicTo(w * 0.18, h * 0.4, w * 0.22, h * 0.2, w * 0.5, h * 0.08)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

/// Hoja Linear: muy estrecha y alargada
class LinearPainter extends LeafShapePainter {
  LinearPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.03)
      ..cubicTo(w * 0.58, h * 0.15, w * 0.6, h * 0.3, w * 0.58, h * 0.5)
      ..cubicTo(w * 0.57, h * 0.7, w * 0.55, h * 0.85, w * 0.5, h * 0.97)
      ..cubicTo(w * 0.45, h * 0.85, w * 0.43, h * 0.7, w * 0.42, h * 0.5)
      ..cubicTo(w * 0.4, h * 0.3, w * 0.42, h * 0.15, w * 0.5, h * 0.03)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

/// Hoja Acicular: como aguja de pino, muy estrecha
class AcicularPainter extends LeafShapePainter {
  AcicularPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..cubicTo(w * 0.55, h * 0.2, w * 0.56, h * 0.5, w * 0.54, h * 0.75)
      ..cubicTo(w * 0.53, h * 0.88, w * 0.51, h * 0.95, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.49, h * 0.95, w * 0.47, h * 0.88, w * 0.46, h * 0.75)
      ..cubicTo(w * 0.44, h * 0.5, w * 0.45, h * 0.2, w * 0.5, h * 0.02)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

/// Hoja Triangular/Tripartida: con 3 puntas
class TriangularPainter extends LeafShapePainter {
  TriangularPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.05) // Punta superior central
      ..lineTo(w * 0.82, h * 0.35) // Punta derecha
      ..cubicTo(w * 0.78, h * 0.45, w * 0.72, h * 0.55, w * 0.65, h * 0.6)
      ..lineTo(w * 0.6, h * 0.65)
      ..cubicTo(
        w * 0.58,
        h * 0.78,
        w * 0.55,
        h * 0.88,
        w * 0.5,
        h * 0.95,
      ) // Base
      ..cubicTo(w * 0.45, h * 0.88, w * 0.42, h * 0.78, w * 0.4, h * 0.65)
      ..lineTo(w * 0.35, h * 0.6)
      ..cubicTo(
        w * 0.28,
        h * 0.55,
        w * 0.22,
        h * 0.45,
        w * 0.18,
        h * 0.35,
      ) // Punta izquierda
      ..lineTo(w * 0.5, h * 0.05)
      ..close();

    drawLeaf(canvas, size, path);
  }

  @override
  void _drawMidrib(Canvas canvas, Size size, Path path) {
    final paint = Paint()
      ..color = const Color(0xFF1A6B1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Central
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.95)
        ..lineTo(size.width * 0.5, size.height * 0.15),
      paint,
    );
    // Lateral izquierdo
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.45)
        ..lineTo(size.width * 0.25, size.height * 0.35),
      paint,
    );
    // Lateral derecho
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.45)
        ..lineTo(size.width * 0.75, size.height * 0.35),
      paint,
    );
  }
}

/// Hoja Obovada/Espatulada: ancha en la punta, angosta en la base
class ObovadaPainter extends LeafShapePainter {
  ObovadaPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.06) // Punta superior (ancha)
      ..cubicTo(w * 0.8, h * 0.12, w * 0.85, h * 0.3, w * 0.8, h * 0.45)
      ..cubicTo(w * 0.75, h * 0.6, w * 0.65, h * 0.75, w * 0.55, h * 0.88)
      ..cubicTo(
        w * 0.52,
        h * 0.92,
        w * 0.5,
        h * 0.95,
        w * 0.5,
        h * 0.95,
      ) // Base estrecha
      ..cubicTo(w * 0.5, h * 0.95, w * 0.48, h * 0.92, w * 0.45, h * 0.88)
      ..cubicTo(w * 0.35, h * 0.75, w * 0.25, h * 0.6, w * 0.2, h * 0.45)
      ..cubicTo(w * 0.15, h * 0.3, w * 0.2, h * 0.12, w * 0.5, h * 0.06)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

/// Hoja Compuesta: múltiples folíolos
class CompuestaPainter extends LeafShapePainter {
  CompuestaPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Tallo central
    final stemPaint = Paint()
      ..color = const Color(0xFF1A6B1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.95)
        ..lineTo(w * 0.5, h * 0.1),
      stemPaint,
    );

    // Folíolos (pares opuestos + uno terminal)
    final leaflets = [
      // Terminal
      Offset(w * 0.5, h * 0.08),
      // Par 1
      Offset(w * 0.35, h * 0.25),
      Offset(w * 0.65, h * 0.25),
      // Par 2
      Offset(w * 0.32, h * 0.45),
      Offset(w * 0.68, h * 0.45),
      // Par 3
      Offset(w * 0.35, h * 0.65),
      Offset(w * 0.65, h * 0.65),
    ];

    for (final center in leaflets) {
      final leafletPath = Path();
      final lw = w * 0.14;
      final lh = h * 0.12;

      leafletPath.addOval(
        Rect.fromCenter(center: center, width: lw, height: lh),
      );

      canvas.drawPath(leafletPath, fillPaint);
      canvas.drawPath(leafletPath, strokePaint);
    }
  }
}

/// Hoja Oblanceolada: como lanceolada pero más ancha hacia la punta
class OblanceoladaPainter extends LeafShapePainter {
  OblanceoladaPainter({super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.05) // Punta superior (más ancha)
      ..cubicTo(w * 0.75, h * 0.12, w * 0.78, h * 0.3, w * 0.72, h * 0.45)
      ..cubicTo(w * 0.66, h * 0.6, w * 0.6, h * 0.75, w * 0.55, h * 0.85)
      ..cubicTo(w * 0.52, h * 0.9, w * 0.5, h * 0.95, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.5, h * 0.95, w * 0.48, h * 0.9, w * 0.45, h * 0.85)
      ..cubicTo(w * 0.4, h * 0.75, w * 0.34, h * 0.6, w * 0.28, h * 0.45)
      ..cubicTo(w * 0.22, h * 0.3, w * 0.25, h * 0.12, w * 0.5, h * 0.05)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

// ============================================================
// LEAF EDGE PAINTERS
// ============================================================

/// Borde Entero: liso, sin denticiones
class BordeEnteroPainter extends CustomPainter {
  final Color color;

  BordeEnteroPainter({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Perfil lateral de una hoja con borde liso (vista como silueta de montaña suave)
    final path = Path()
      ..moveTo(0, h * 0.85)
      ..cubicTo(w * 0.1, h * 0.7, w * 0.2, h * 0.4, w * 0.35, h * 0.25)
      ..cubicTo(w * 0.45, h * 0.15, w * 0.55, h * 0.15, w * 0.65, h * 0.25)
      ..cubicTo(w * 0.8, h * 0.4, w * 0.9, h * 0.7, w, h * 0.85)
      ..lineTo(0, h * 0.85)
      ..close();

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Borde Aserrado: con dientes como sierra
class BordeAserradoPainter extends CustomPainter {
  final Color color;

  BordeAserradoPainter({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Silueta de hoja con borde aserrado (dientes de sierra en el borde superior)
    final path = Path()..moveTo(0, h * 0.85);

    // Subida con dientes
    final teethCount = 8;
    final segmentW = w / teethCount;
    for (int i = 0; i < teethCount; i++) {
      final x0 = i * segmentW;
      final x1 = x0 + segmentW * 0.6;
      final x2 = x0 + segmentW;

      // Altura base sigue una curva
      final t = (x0 + segmentW / 2) / w;
      final baseH = h * 0.85 - (h * 0.6) * sin(t * pi);
      final toothH = baseH - h * 0.06;

      path.lineTo(x1, toothH);
      path.lineTo(x2, baseH);
    }

    path.lineTo(w, h * 0.85);
    path.lineTo(0, h * 0.85);
    path.close();

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Borde Espinoso: con espinas pronunciadas
class BordeEspinosoPainter extends CustomPainter {
  final Color color;

  BordeEspinosoPainter({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Silueta con espinas pronunciadas e irregulares
    final path = Path()..moveTo(0, h * 0.85);

    final spines = 6;
    final segmentW = w / spines;
    for (int i = 0; i < spines; i++) {
      final x0 = i * segmentW;
      final xMid = x0 + segmentW * 0.4;
      final x2 = x0 + segmentW;

      final t = (x0 + segmentW / 2) / w;
      final baseH = h * 0.85 - (h * 0.5) * sin(t * pi);
      final spineH = baseH - h * 0.12;

      path.lineTo(xMid, spineH);
      path.lineTo(xMid + segmentW * 0.1, baseH + h * 0.02);
      path.lineTo(x2, baseH);
    }

    path.lineTo(w, h * 0.85);
    path.lineTo(0, h * 0.85);
    path.close();

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// BIOLOGICAL FORM PAINTERS
// ============================================================

/// Arbusto
class ArbustoPainter extends CustomPainter {
  final Color color;

  ArbustoPainter({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = const Color(0xFF1F6B1F)
      ..style = PaintingStyle.fill;

    // Masa central del arbusto (forma redondeada baja, sin tronco)
    final mainPath = Path()
      ..moveTo(w * 0.1, h * 0.85)
      ..cubicTo(w * 0.05, h * 0.6, w * 0.15, h * 0.35, w * 0.3, h * 0.25)
      ..cubicTo(w * 0.4, h * 0.18, w * 0.6, h * 0.18, w * 0.7, h * 0.25)
      ..cubicTo(w * 0.85, h * 0.35, w * 0.95, h * 0.6, w * 0.9, h * 0.85)
      ..close();

    canvas.drawPath(mainPath, fillPaint);

    // Lóbulo superior izquierdo (volumen)
    final lobLeft = Path()
      ..moveTo(w * 0.15, h * 0.7)
      ..cubicTo(w * 0.1, h * 0.45, w * 0.2, h * 0.28, w * 0.35, h * 0.22)
      ..cubicTo(w * 0.45, h * 0.3, w * 0.35, h * 0.5, w * 0.3, h * 0.7)
      ..close();

    canvas.drawPath(lobLeft, darkPaint);

    // Lóbulo superior derecho (volumen)
    final lobRight = Path()
      ..moveTo(w * 0.85, h * 0.7)
      ..cubicTo(w * 0.9, h * 0.45, w * 0.8, h * 0.28, w * 0.65, h * 0.22)
      ..cubicTo(w * 0.55, h * 0.3, w * 0.65, h * 0.5, w * 0.7, h * 0.7)
      ..close();

    canvas.drawPath(lobRight, darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hierba
class HierbaPainter extends CustomPainter {
  final Color color;

  HierbaPainter({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Varias hojas desde la base
    final leaves = [
      [0.5, 0.95, 0.35, 0.15, -0.1],
      [0.5, 0.95, 0.5, 0.08, 0.0],
      [0.5, 0.95, 0.65, 0.15, 0.1],
      [0.5, 0.95, 0.28, 0.35, -0.15],
      [0.5, 0.95, 0.72, 0.35, 0.15],
    ];

    for (final leaf in leaves) {
      final baseX = w * leaf[0];
      final baseY = h * leaf[1];
      final tipX = w * leaf[2];
      final tipY = h * leaf[3];
      final offset = w * leaf[4];

      final path = Path()
        ..moveTo(baseX, baseY)
        ..quadraticBezierTo(tipX + offset, (baseY + tipY) / 2, tipX, tipY)
        ..quadraticBezierTo(
          tipX - offset + w * 0.05,
          (baseY + tipY) / 2,
          baseX,
          baseY,
        )
        ..close();

      canvas.drawPath(path, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subarbusto
class SubarbustoPainter extends CustomPainter {
  final Color color;

  SubarbustoPainter({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final trunkPaint = Paint()
      ..color = const Color(0xFF6B4226)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Tronquito corto leñoso
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.95)
        ..lineTo(w * 0.5, h * 0.7),
      trunkPaint,
    );

    // Copa baja y redondeada
    final crownPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.5),
          width: w * 0.75,
          height: h * 0.55,
        ),
      );

    canvas.drawPath(crownPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Suculenta
class SuculentaPainter extends CustomPainter {
  final Color color;

  SuculentaPainter({this.color = const Color(0xFF4CAF50)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Hojas gruesas y carnosas en roseta
    final petals = 5;
    final cx = w * 0.5;
    final cy = h * 0.5;

    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * pi / petals) - pi / 2;
      final tipX = cx + cos(angle) * w * 0.35;
      final tipY = cy + sin(angle) * h * 0.35;

      final path = Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(
          cx + cos(angle - 0.3) * w * 0.2,
          cy + sin(angle - 0.3) * h * 0.2,
          tipX,
          tipY,
        )
        ..quadraticBezierTo(
          cx + cos(angle + 0.3) * w * 0.2,
          cy + sin(angle + 0.3) * h * 0.2,
          cx,
          cy,
        )
        ..close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// LEAF TEXTURE PAINTERS
// ============================================================

/// Coriácea (rígida, gruesa)
class TexturaCoriaceaPainter extends LeafShapePainter {
  TexturaCoriaceaPainter({super.color = const Color(0xFF1B5E20)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hoja gruesa y rígida - color más oscuro
    final path = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..cubicTo(w * 0.75, h * 0.18, w * 0.8, h * 0.4, w * 0.75, h * 0.55)
      ..cubicTo(w * 0.7, h * 0.7, w * 0.6, h * 0.85, w * 0.5, h * 0.92)
      ..cubicTo(w * 0.4, h * 0.85, w * 0.3, h * 0.7, w * 0.25, h * 0.55)
      ..cubicTo(w * 0.2, h * 0.4, w * 0.25, h * 0.18, w * 0.5, h * 0.08)
      ..close();

    drawLeaf(canvas, size, path);

    // Líneas que sugieren rigidez
    final linePaint = Paint()
      ..color = const Color(0xFF0D3B0D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (double y = 0.3; y < 0.8; y += 0.12) {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.35, h * y)
          ..lineTo(w * 0.65, h * y),
        linePaint,
      );
    }
  }
}

/// Flexible
class TexturaFlexiblePainter extends LeafShapePainter {
  TexturaFlexiblePainter({super.color = const Color(0xFF4CAF50)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hoja con curva que sugiere flexibilidad
    final path = Path()
      ..moveTo(w * 0.45, h * 0.08)
      ..cubicTo(w * 0.7, h * 0.15, w * 0.8, h * 0.35, w * 0.75, h * 0.5)
      ..cubicTo(w * 0.7, h * 0.65, w * 0.55, h * 0.8, w * 0.45, h * 0.92)
      ..cubicTo(w * 0.38, h * 0.8, w * 0.3, h * 0.65, w * 0.28, h * 0.5)
      ..cubicTo(w * 0.25, h * 0.35, w * 0.3, h * 0.15, w * 0.45, h * 0.08)
      ..close();

    // Rotar levemente para sugerir flexibilidad
    canvas.save();
    canvas.translate(w * 0.05, 0);
    drawLeaf(canvas, size, path);
    canvas.restore();
  }
}

/// Blanda/Carnosa
class TexturaCarnosaPainter extends LeafShapePainter {
  TexturaCarnosaPainter({super.color = const Color(0xFF66BB6A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hoja gordita y redondeada
    final path = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.82, h * 0.15, w * 0.88, h * 0.4, w * 0.82, h * 0.55)
      ..cubicTo(w * 0.76, h * 0.7, w * 0.62, h * 0.85, w * 0.5, h * 0.92)
      ..cubicTo(w * 0.38, h * 0.85, w * 0.24, h * 0.7, w * 0.18, h * 0.55)
      ..cubicTo(w * 0.12, h * 0.4, w * 0.18, h * 0.15, w * 0.5, h * 0.1)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

// ============================================================
// HEIGHT PAINTERS
// ============================================================

/// Escala de altura con marcador
class HeightPainter extends CustomPainter {
  final int level; // 0=muy baja, 1=baja, 2=media, 3=alta
  final Color color;

  HeightPainter({required this.level, this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Barra de fondo
    final barWidth = w * 0.25;
    final barLeft = (w - barWidth) / 2;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barLeft, h * 0.1, barWidth, h * 0.8),
      const Radius.circular(4),
    );
    canvas.drawRRect(barRect, bgPaint);

    // Barra rellena según nivel
    final fillHeight = h * 0.8 * ((level + 1) / 4);
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        barLeft,
        h * 0.1 + h * 0.8 - fillHeight,
        barWidth,
        fillHeight,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(fillRect, fillPaint);

    // Planta icónica
    final plantPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final plantH = h * 0.3 * ((level + 1) / 4) + h * 0.1;
    final plantX = w * 0.72;
    final plantBase = h * 0.85;

    canvas.drawPath(
      Path()
        ..moveTo(plantX, plantBase)
        ..lineTo(plantX, plantBase - plantH),
      plantPaint,
    );

    // Hojitas
    if (plantH > h * 0.1) {
      canvas.drawPath(
        Path()
          ..moveTo(plantX, plantBase - plantH * 0.5)
          ..quadraticBezierTo(
            plantX + w * 0.08,
            plantBase - plantH * 0.6,
            plantX + w * 0.05,
            plantBase - plantH * 0.7,
          ),
        plantPaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(plantX, plantBase - plantH * 0.5)
          ..quadraticBezierTo(
            plantX - w * 0.08,
            plantBase - plantH * 0.6,
            plantX - w * 0.05,
            plantBase - plantH * 0.7,
          ),
        plantPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// FLOWER PAINTERS
// ============================================================

/// Flor con color determinado
class FlowerColorPainter extends CustomPainter {
  final Color petalColor;

  FlowerColorPainter({required this.petalColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.45;

    final petalPaint = Paint()
      ..color = petalColor
      ..style = PaintingStyle.fill;

    final centerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    // 5 pétalos
    final petalCount = 5;
    final petalRadius = w * 0.2;
    final distance = w * 0.18;

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * pi / petalCount) - pi / 2;
      final px = cx + cos(angle) * distance;
      final py = cy + sin(angle) * distance;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(px, py),
          width: petalRadius,
          height: petalRadius * 1.3,
        ),
        petalPaint,
      );
    }

    // Centro
    canvas.drawCircle(Offset(cx, cy), w * 0.08, centerPaint);

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF2D8C2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + w * 0.22)
        ..lineTo(cx, h * 0.95),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// GENERIC ICON PAINTER (fallback)
// ============================================================

/// Para opciones que no tienen un painter específico, dibuja un ícono genérico
class GenericOptionPainter extends CustomPainter {
  final IconData icon;
  final Color color;

  GenericOptionPainter({
    required this.icon,
    this.color = const Color(0xFF2D8C2D),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // El ícono se dibuja con TextPainter usando la fuente de Material Icons
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.5,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// LEAF SIZE PAINTERS (tamaño progresivo)
// ============================================================

/// Hoja de tamaño progresivo para representar opciones de longitud de hoja.
class LeafSizePainter extends CustomPainter {
  final int
  level; // 0=muy pequeña, 1=pequeña, 2=mediana, 3=grande, 4=muy grande
  final Color color;

  LeafSizePainter({required this.level, this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Escalar la hoja según el nivel (0.3 a 0.9 del espacio disponible)
    final scale = 0.3 + (level / 4.0) * 0.6;
    final leafW = w * 0.4 * scale;
    final leafH = h * 0.7 * scale;
    final cx = w * 0.5;
    final cy = h * 0.5;

    final path = Path()
      ..moveTo(cx, cy - leafH / 2)
      ..cubicTo(
        cx + leafW * 0.8,
        cy - leafH * 0.3,
        cx + leafW * 0.8,
        cy + leafH * 0.3,
        cx,
        cy + leafH / 2,
      )
      ..cubicTo(
        cx - leafW * 0.8,
        cy + leafH * 0.3,
        cx - leafW * 0.8,
        cy - leafH * 0.3,
        cx,
        cy - leafH / 2,
      )
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Nervadura central
    final midPaint = Paint()
      ..color = const Color(0xFF1A6B1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx, cy - leafH / 2 + leafH * 0.1),
      Offset(cx, cy + leafH / 2 - leafH * 0.1),
      midPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// FRUIT COLOR PAINTERS
// ============================================================

/// Fruto con color determinado (círculo redondeado con un tallito)
class FruitColorPainter extends CustomPainter {
  final Color fruitColor;

  FruitColorPainter({required this.fruitColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;

    final fillPaint = Paint()
      ..color = fruitColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Fruto (esférico)
    final radius = w * 0.28;
    canvas.drawCircle(Offset(cx, cy), radius, fillPaint);

    // Brillo
    canvas.drawCircle(
      Offset(cx - radius * 0.3, cy - radius * 0.3),
      radius * 0.2,
      highlightPaint,
    );

    // Tallito
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - radius)
        ..cubicTo(
          cx + 2,
          cy - radius - h * 0.08,
          cx + 4,
          cy - radius - h * 0.1,
          cx + 3,
          cy - radius - h * 0.12,
        ),
      stemPaint,
    );

    // Hojita en el tallo
    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final leafPath = Path()
      ..moveTo(cx + 1, cy - radius - h * 0.06)
      ..quadraticBezierTo(
        cx + w * 0.1,
        cy - radius - h * 0.1,
        cx + w * 0.08,
        cy - radius - h * 0.04,
      )
      ..quadraticBezierTo(
        cx + w * 0.05,
        cy - radius - h * 0.02,
        cx + 1,
        cy - radius - h * 0.06,
      )
      ..close();

    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// FRUIT SHAPE PAINTERS
// ============================================================

/// Fruto esférico
class FruitEsfericoPainter extends CustomPainter {
  final Color color;
  FruitEsfericoPainter({this.color = const Color(0xFF8BC34A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), w * 0.3, paint);
    canvas.drawCircle(Offset(cx - w * 0.1, cy - h * 0.08), w * 0.08, highlight);

    _drawStem(canvas, cx, cy - w * 0.3, w, h);
  }

  void _drawStem(Canvas canvas, double cx, double top, double w, double h) {
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, top), Offset(cx, top - h * 0.08), stemPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fruto ovoide/alado
class FruitOvoidePainter extends CustomPainter {
  final Color color;
  FruitOvoidePainter({this.color = const Color(0xFF8BC34A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Forma ovoide (más ancho arriba)
    final path = Path()
      ..moveTo(cx, cy - h * 0.32)
      ..cubicTo(
        cx + w * 0.28,
        cy - h * 0.25,
        cx + w * 0.25,
        cy + h * 0.1,
        cx + w * 0.15,
        cy + h * 0.28,
      )
      ..cubicTo(
        cx + w * 0.08,
        cy + h * 0.35,
        cx - w * 0.08,
        cy + h * 0.35,
        cx - w * 0.15,
        cy + h * 0.28,
      )
      ..cubicTo(
        cx - w * 0.25,
        cy + h * 0.1,
        cx - w * 0.28,
        cy - h * 0.25,
        cx,
        cy - h * 0.32,
      )
      ..close();
    canvas.drawPath(path, paint);

    // Alas laterales
    final wingPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Ala derecha
    final wingR = Path()
      ..moveTo(cx + w * 0.12, cy - h * 0.1)
      ..cubicTo(
        cx + w * 0.35,
        cy - h * 0.2,
        cx + w * 0.4,
        cy - h * 0.35,
        cx + w * 0.3,
        cy - h * 0.38,
      )
      ..cubicTo(
        cx + w * 0.2,
        cy - h * 0.35,
        cx + w * 0.15,
        cy - h * 0.2,
        cx + w * 0.12,
        cy - h * 0.1,
      )
      ..close();
    canvas.drawPath(wingR, wingPaint);

    // Ala izquierda
    final wingL = Path()
      ..moveTo(cx - w * 0.12, cy - h * 0.1)
      ..cubicTo(
        cx - w * 0.35,
        cy - h * 0.2,
        cx - w * 0.4,
        cy - h * 0.35,
        cx - w * 0.3,
        cy - h * 0.38,
      )
      ..cubicTo(
        cx - w * 0.2,
        cy - h * 0.35,
        cx - w * 0.15,
        cy - h * 0.2,
        cx - w * 0.12,
        cy - h * 0.1,
      )
      ..close();
    canvas.drawPath(wingL, wingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fruto globoso/trilobulado
class FruitGlobosoPainter extends CustomPainter {
  final Color color;
  FruitGlobosoPainter({this.color = const Color(0xFF8BC34A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.55;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final r = w * 0.22;

    // 3 lóbulos
    canvas.drawCircle(Offset(cx, cy - r * 0.5), r, paint);
    canvas.drawCircle(Offset(cx - r * 0.7, cy + r * 0.4), r * 0.9, paint);
    canvas.drawCircle(Offset(cx + r * 0.7, cy + r * 0.4), r * 0.9, paint);

    // Líneas de separación
    canvas.drawLine(
      Offset(cx, cy - r * 0.3),
      Offset(cx - r * 0.3, cy + r * 0.5),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx, cy - r * 0.3),
      Offset(cx + r * 0.3, cy + r * 0.5),
      linePaint,
    );

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy - r * 1.4),
      Offset(cx, cy - r * 1.7),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fruto cilíndrico
class FruitCilindricoPainter extends CustomPainter {
  final Color color;
  FruitCilindricoPainter({this.color = const Color(0xFF8BC34A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Cuerpo cilíndrico (rectángulo redondeado alargado)
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, h * 0.5),
        width: w * 0.25,
        height: h * 0.6,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, strokePaint);

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, h * 0.2), Offset(cx, h * 0.12), stemPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fruto elipsoide/alado
class FruitElipsoidePainter extends CustomPainter {
  final Color color;
  FruitElipsoidePainter({this.color = const Color(0xFF8BC34A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Elipse principal
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.35, height: h * 0.5),
      paint,
    );

    // Alas (más delgadas que ovoide)
    final wingPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final wingR = Path()
      ..moveTo(cx + w * 0.15, cy)
      ..cubicTo(
        cx + w * 0.35,
        cy - h * 0.1,
        cx + w * 0.4,
        cy - h * 0.25,
        cx + w * 0.32,
        cy - h * 0.3,
      )
      ..cubicTo(
        cx + w * 0.25,
        cy - h * 0.25,
        cx + w * 0.2,
        cy - h * 0.1,
        cx + w * 0.15,
        cy,
      )
      ..close();
    canvas.drawPath(wingR, wingPaint);

    final wingL = Path()
      ..moveTo(cx - w * 0.15, cy)
      ..cubicTo(
        cx - w * 0.35,
        cy - h * 0.1,
        cx - w * 0.4,
        cy - h * 0.25,
        cx - w * 0.32,
        cy - h * 0.3,
      )
      ..cubicTo(
        cx - w * 0.25,
        cy - h * 0.25,
        cx - w * 0.2,
        cy - h * 0.1,
        cx - w * 0.15,
        cy,
      )
      ..close();
    canvas.drawPath(wingL, wingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fruto piloso (con pelos)
class FruitPilosoPainter extends CustomPainter {
  final Color color;
  FruitPilosoPainter({this.color = const Color(0xFF8BC34A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Fruto base ovalado
    final r = w * 0.22;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2.2),
      paint,
    );

    // Pelos/fibras
    final hairPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final hairCount = 12;
    for (int i = 0; i < hairCount; i++) {
      final angle = (i * 2 * pi / hairCount) - pi / 2;
      final startX = cx + cos(angle) * r;
      final startY = cy + sin(angle) * r * 1.1;
      final endX = cx + cos(angle) * (r + w * 0.1);
      final endY = cy + sin(angle) * (r * 1.1 + h * 0.08);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), hairPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// FRUIT SIZE PAINTERS
// ============================================================

/// Fruto de tamaño progresivo
class FruitSizePainter extends CustomPainter {
  final int level; // 0=muy pequeño, 1=pequeño, 2=mediano, 3=grande
  final Color color;

  FruitSizePainter({required this.level, this.color = const Color(0xFF8BC34A)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.55;

    final scale = 0.35 + (level / 3.0) * 0.55;
    final radius = w * 0.3 * scale;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), radius, paint);
    canvas.drawCircle(
      Offset(cx - radius * 0.3, cy - radius * 0.3),
      radius * 0.2,
      highlight,
    );

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy - radius),
      Offset(cx, cy - radius - h * 0.08),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// FLOWER SIZE PAINTERS
// ============================================================

/// Flor de tamaño progresivo
class FlowerSizePainter extends CustomPainter {
  final int level; // 0=muy pequeña, 1=pequeña, 2=mediana, 3=grande
  final Color color;

  FlowerSizePainter({
    required this.level,
    this.color = const Color(0xFFF48FB1),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.45;

    final scale = 0.35 + (level / 3.0) * 0.55;

    final petalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final centerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    final petalCount = 5;
    final petalRadius = w * 0.15 * scale;
    final distance = w * 0.14 * scale;

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * pi / petalCount) - pi / 2;
      final px = cx + cos(angle) * distance;
      final py = cy + sin(angle) * distance;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(px, py),
          width: petalRadius,
          height: petalRadius * 1.3,
        ),
        petalPaint,
      );
    }

    canvas.drawCircle(Offset(cx, cy), w * 0.06 * scale, centerPaint);

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF2D8C2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy + distance + petalRadius * 0.5),
      Offset(cx, h * 0.92),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// FLOWER GROUPING PAINTERS
// ============================================================

/// Flor individual
class FlowerIndividualPainter extends CustomPainter {
  final Color color;
  FlowerIndividualPainter({this.color = const Color(0xFFF48FB1)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.4;

    _drawSingleFlower(canvas, cx, cy, w * 0.3, color);

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF2D8C2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + w * 0.18), Offset(cx, h * 0.92), stemPaint);
  }

  void _drawSingleFlower(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color petalColor,
  ) {
    final petalPaint = Paint()
      ..color = petalColor
      ..style = PaintingStyle.fill;
    final centerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final px = cx + cos(angle) * r * 0.5;
      final py = cy + sin(angle) * r * 0.5;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(px, py),
          width: r * 0.5,
          height: r * 0.65,
        ),
        petalPaint,
      );
    }
    canvas.drawCircle(Offset(cx, cy), r * 0.2, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Inflorescencia (varias flores agrupadas)
class FlowerInflorescenciaPainter extends CustomPainter {
  final Color color;
  FlowerInflorescenciaPainter({this.color = const Color(0xFFF48FB1)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final petalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final centerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    // Tallo principal
    final stemPaint = Paint()
      ..color = const Color(0xFF2D8C2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, h * 0.5), Offset(cx, h * 0.92), stemPaint);

    // Ramitas con flores
    final flowers = [
      Offset(cx, h * 0.2),
      Offset(cx - w * 0.18, h * 0.32),
      Offset(cx + w * 0.18, h * 0.32),
      Offset(cx - w * 0.1, h * 0.45),
      Offset(cx + w * 0.1, h * 0.45),
    ];

    for (final pos in flowers) {
      // Ramita
      canvas.drawLine(Offset(cx, pos.dy + h * 0.05), pos, stemPaint);

      // Mini flor
      final r = w * 0.06;
      for (int i = 0; i < 4; i++) {
        final angle = (i * 2 * pi / 4) - pi / 4;
        canvas.drawCircle(
          Offset(pos.dx + cos(angle) * r, pos.dy + sin(angle) * r),
          r * 0.6,
          petalPaint,
        );
      }
      canvas.drawCircle(pos, r * 0.35, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cono (como piñas de coníferas)
class FlowerConoPainter extends CustomPainter {
  final Color color;
  FlowerConoPainter({this.color = const Color(0xFF8D6E63)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // Forma cónica
    final conePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final scalePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path()
      ..moveTo(cx, h * 0.12)
      ..cubicTo(
        cx + w * 0.25,
        h * 0.25,
        cx + w * 0.2,
        h * 0.6,
        cx + w * 0.12,
        h * 0.75,
      )
      ..cubicTo(
        cx + w * 0.06,
        h * 0.8,
        cx - w * 0.06,
        h * 0.8,
        cx - w * 0.12,
        h * 0.75,
      )
      ..cubicTo(cx - w * 0.2, h * 0.6, cx - w * 0.25, h * 0.25, cx, h * 0.12)
      ..close();

    canvas.drawPath(path, conePaint);

    // Escamas del cono
    for (double y = 0.25; y < 0.75; y += 0.1) {
      final rowW = w * 0.12 * (1 - (y - 0.5).abs());
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, h * y),
          width: rowW * 2,
          height: h * 0.06,
        ),
        0,
        pi,
        false,
        scalePaint,
      );
    }

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, h * 0.8), Offset(cx, h * 0.92), stemPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// PETAL COUNT PAINTERS
// ============================================================

/// Flor con N pétalos visibles
class PetalCountPainter extends CustomPainter {
  final int petalCount;
  final Color color;

  PetalCountPainter({
    required this.petalCount,
    this.color = const Color(0xFFF48FB1),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.45;

    final petalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final centerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    if (petalCount == 0) {
      // Sin pétalos visibles: solo centro
      canvas.drawCircle(Offset(cx, cy), w * 0.15, centerPaint);
      // Sépalos verdes
      final sepalPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < 5; i++) {
        final angle = (i * 2 * pi / 5) - pi / 2;
        final px = cx + cos(angle) * w * 0.18;
        final py = cy + sin(angle) * w * 0.18;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(px, py),
            width: w * 0.08,
            height: w * 0.14,
          ),
          sepalPaint,
        );
      }
      return;
    }

    final count = petalCount > 8 ? 10 : petalCount; // "muchos" = 10
    final petalRadius = w * (count <= 5 ? 0.16 : 0.12);
    final distance = w * (count <= 5 ? 0.16 : 0.2);

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) - pi / 2;
      final px = cx + cos(angle) * distance;
      final py = cy + sin(angle) * distance;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(px, py),
          width: petalRadius * 0.8,
          height: petalRadius * 1.2,
        ),
        petalPaint,
      );
    }

    canvas.drawCircle(Offset(cx, cy), w * 0.08, centerPaint);

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF2D8C2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy + distance + petalRadius),
      Offset(cx, h * 0.92),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// SPINE TYPE PAINTERS
// ============================================================

/// Espinas foliares/trífidas (3 puntas desde la hoja)
class SpineFoliaresTrifidas extends CustomPainter {
  final Color color;
  SpineFoliaresTrifidas({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final spinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Tallo
    canvas.drawLine(Offset(cx, h * 0.9), Offset(cx, h * 0.15), spinePaint);

    // Nodos con 3 espinas
    final nodes = [h * 0.35, h * 0.55, h * 0.75];
    for (final ny in nodes) {
      canvas.drawCircle(Offset(cx, ny), 2.5, nodePaint);

      // Central arriba
      canvas.drawLine(Offset(cx, ny), Offset(cx, ny - h * 0.08), spinePaint);
      // Izquierda
      canvas.drawLine(
        Offset(cx, ny),
        Offset(cx - w * 0.12, ny - h * 0.05),
        spinePaint,
      );
      // Derecha
      canvas.drawLine(
        Offset(cx, ny),
        Offset(cx + w * 0.12, ny - h * 0.05),
        spinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Espinas caulinares (desde el tallo)
class SpineCaulinares extends CustomPainter {
  final Color color;
  SpineCaulinares({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final stemPaint = Paint()
      ..color = const Color(0xFF6B4226)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final spinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Tallo grueso (leñoso)
    canvas.drawLine(Offset(cx, h * 0.9), Offset(cx, h * 0.1), stemPaint);

    // Espinas alternas saliendo del tallo
    final spines = [
      (h * 0.25, true),
      (h * 0.35, false),
      (h * 0.45, true),
      (h * 0.55, false),
      (h * 0.65, true),
      (h * 0.75, false),
    ];

    for (final (sy, isLeft) in spines) {
      final dir = isLeft ? -1.0 : 1.0;
      canvas.drawLine(
        Offset(cx, sy),
        Offset(cx + dir * w * 0.2, sy - h * 0.04),
        spinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ramas espinosas
class SpineRamasEspinosas extends CustomPainter {
  final Color color;
  SpineRamasEspinosas({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final branchPaint = Paint()
      ..color = const Color(0xFF6B4226)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final spinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Tallo principal
    canvas.drawLine(Offset(cx, h * 0.9), Offset(cx, h * 0.15), branchPaint);

    // Ramas laterales que terminan en punta (espinosas)
    final branches = [
      (Offset(cx, h * 0.3), Offset(cx + w * 0.3, h * 0.2)),
      (Offset(cx, h * 0.4), Offset(cx - w * 0.25, h * 0.3)),
      (Offset(cx, h * 0.55), Offset(cx + w * 0.28, h * 0.45)),
      (Offset(cx, h * 0.65), Offset(cx - w * 0.22, h * 0.58)),
    ];

    for (final (start, end) in branches) {
      canvas.drawLine(start, end, branchPaint);
      // Punta de espina
      final dx = (end.dx - start.dx).sign * w * 0.06;
      final dy = (end.dy - start.dy).sign * h * 0.03;
      canvas.drawLine(
        end,
        Offset(end.dx + dx, end.dy + dy - h * 0.02),
        spinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Espinas foliares/cortas
class SpineFoliaresCortas extends CustomPainter {
  final Color color;
  SpineFoliaresCortas({this.color = const Color(0xFF2D8C2D)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final spinePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Hoja con espinas cortas en los bordes
    final leafPath = Path()
      ..moveTo(cx, h * 0.1)
      ..cubicTo(cx + w * 0.3, h * 0.2, cx + w * 0.3, h * 0.6, cx, h * 0.85)
      ..cubicTo(cx - w * 0.3, h * 0.6, cx - w * 0.3, h * 0.2, cx, h * 0.1)
      ..close();
    canvas.drawPath(leafPath, leafPaint);

    // Espinas cortas en los bordes
    final spinePoints = [
      (cx + w * 0.25, h * 0.3),
      (cx + w * 0.28, h * 0.45),
      (cx + w * 0.22, h * 0.6),
      (cx + w * 0.15, h * 0.72),
      (cx - w * 0.25, h * 0.3),
      (cx - w * 0.28, h * 0.45),
      (cx - w * 0.22, h * 0.6),
      (cx - w * 0.15, h * 0.72),
    ];

    for (final (sx, sy) in spinePoints) {
      final dir = sx > cx ? 1.0 : -1.0;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + dir * w * 0.05, sy - h * 0.02),
        spinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// ADDITIONAL TEXTURE PAINTERS
// ============================================================

/// Textura Firme
class TexturaFirmePainter extends LeafShapePainter {
  TexturaFirmePainter({super.color = const Color(0xFF388E3C)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hoja con forma definida y rígida (bordes rectos)
    final path = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.72, h * 0.25)
      ..lineTo(w * 0.75, h * 0.5)
      ..lineTo(w * 0.65, h * 0.75)
      ..lineTo(w * 0.5, h * 0.92)
      ..lineTo(w * 0.35, h * 0.75)
      ..lineTo(w * 0.25, h * 0.5)
      ..lineTo(w * 0.28, h * 0.25)
      ..close();

    drawLeaf(canvas, size, path);
  }
}

/// Textura Pegajosa
class TexturaPegajosaPainter extends LeafShapePainter {
  TexturaPegajosaPainter({super.color = const Color(0xFF7CB342)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Hoja con forma elíptica
    final path = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.75, h * 0.18, w * 0.78, h * 0.4, w * 0.72, h * 0.55)
      ..cubicTo(w * 0.66, h * 0.7, w * 0.58, h * 0.85, w * 0.5, h * 0.92)
      ..cubicTo(w * 0.42, h * 0.85, w * 0.34, h * 0.7, w * 0.28, h * 0.55)
      ..cubicTo(w * 0.22, h * 0.4, w * 0.25, h * 0.18, w * 0.5, h * 0.1)
      ..close();

    drawLeaf(canvas, size, path);

    // Gotitas que sugieren pegajosidad
    final dropPaint = Paint()
      ..color = const Color(0xFFCDDC39).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final drops = [
      Offset(w * 0.4, h * 0.35),
      Offset(w * 0.6, h * 0.45),
      Offset(w * 0.45, h * 0.6),
      Offset(w * 0.55, h * 0.7),
      Offset(w * 0.38, h * 0.5),
    ];

    for (final drop in drops) {
      canvas.drawCircle(drop, w * 0.025, dropPaint);
    }
  }
}
