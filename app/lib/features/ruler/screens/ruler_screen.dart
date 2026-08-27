import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Pantalla de regla milimétrica a escala real, centrada en pantalla.
/// Usa el PPI físico real del dispositivo (vía DisplayMetrics en Android)
/// para renderizar medidas exactas que coinciden con una regla real.
class RulerScreen extends StatefulWidget {
  const RulerScreen({super.key});

  @override
  State<RulerScreen> createState() => _RulerScreenState();
}

class _RulerScreenState extends State<RulerScreen> {
  static const _channel = MethodChannel('com.kospia.app/display');

  double? _realYdpi;
  bool _dpiLoaded = false;
  double _calibrationFactor = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadRealDpi();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadRealDpi() async {
    try {
      final ydpi = await _channel.invokeMethod<double>('getYdpi');
      if (ydpi != null && ydpi > 0) {
        setState(() {
          _realYdpi = ydpi;
          _dpiLoaded = true;
        });
        return;
      }
    } catch (_) {}
    setState(() => _dpiLoaded = true);
  }

  double _getPxPerMm(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    double ppi;
    if (_realYdpi != null) {
      ppi = _realYdpi! / devicePixelRatio;
    } else {
      ppi = 160.0;
    }
    return ppi * _calibrationFactor / 25.4;
  }

  void _showCalibrationDialog() {
    double tempFactor = _calibrationFactor;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Calibrar regla'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Si la regla no coincide exactamente con una regla real, '
                    'ajustá el factor hasta que coincida.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${(tempFactor * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: tempFactor,
                    min: 0.85,
                    max: 1.15,
                    divisions: 60,
                    activeColor: AppColors.accentGreen,
                    onChanged: (v) {
                      setDialogState(() => tempFactor = v);
                    },
                  ),
                  const Text(
                    'Mové el slider hasta que 1 cm en pantalla '
                    'mida exactamente 1 cm real.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMedium),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => setDialogState(() => tempFactor = 1.0),
                  child: const Text('Resetear'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _calibrationFactor = tempFactor);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_dpiLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pxPerMm = _getPxPerMm(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: AppColors.accentGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Regla',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            tooltip: 'Calibrar',
            onPressed: _showCalibrationDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instrucciones
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surfaceLilac,
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Apoyá la hoja sobre la regla para medir. Tocá ',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.tune_rounded,
                        size: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const TextSpan(text: ' para calibrar si es necesario.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Regla centrada
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    painter: _CenteredRulerPainter(
                      pxPerMm: pxPerMm,
                      availableWidth: constraints.maxWidth,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Regla milimétrica centrada con marcas a ambos lados y franja blanca.
class _CenteredRulerPainter extends CustomPainter {
  final double pxPerMm;
  final double availableWidth;

  /// Ancho de la franja de la regla (en logical px).
  static const double _rulerWidth = 100.0;

  _CenteredRulerPainter({required this.pxPerMm, required this.availableWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final rulerLeft = centerX - _rulerWidth / 2;
    final rulerRight = centerX + _rulerWidth / 2;

    // --- Fondo blanco de la franja de regla ---
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTRB(rulerLeft, 0, rulerRight, size.height),
      bgPaint,
    );

    // --- Bordes de la franja ---
    final borderPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(rulerLeft, 0),
      Offset(rulerLeft, size.height),
      borderPaint,
    );
    canvas.drawLine(
      Offset(rulerRight, 0),
      Offset(rulerRight, size.height),
      borderPaint,
    );

    // --- Línea central (eje de referencia) ---
    final centerLinePaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      centerLinePaint,
    );

    // --- Marcas ---
    final markPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final thinPaint = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final totalMm = (size.height / pxPerMm).floor();

    // Longitudes de marcas (desde el borde hacia el centro)
    const double cmMark = 30.0;
    const double halfCmMark = 20.0;
    const double mmMark = 10.0;

    for (int mm = 0; mm <= totalMm; mm++) {
      final y = mm * pxPerMm;

      double markLen;
      Paint currentPaint;
      bool drawLabel = false;

      if (mm % 10 == 0) {
        markLen = cmMark;
        currentPaint = markPaint;
        drawLabel = mm > 0;
      } else if (mm % 5 == 0) {
        markLen = halfCmMark;
        currentPaint = markPaint;
      } else {
        markLen = mmMark;
        currentPaint = thinPaint;
      }

      // Marcas desde el borde izquierdo de la franja hacia adentro
      canvas.drawLine(
        Offset(rulerLeft, y),
        Offset(rulerLeft + markLen, y),
        currentPaint,
      );

      // Marcas desde el borde derecho de la franja hacia adentro
      canvas.drawLine(
        Offset(rulerRight, y),
        Offset(rulerRight - markLen, y),
        currentPaint,
      );

      // Números de cm
      if (drawLabel) {
        final cm = mm ~/ 10;
        final label = '$cm';

        // Número a la izquierda de la franja
        final leftTP = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        leftTP.layout();
        leftTP.paint(
          canvas,
          Offset(rulerLeft - leftTP.width - 6, y - leftTP.height / 2),
        );

        // Número a la derecha de la franja
        final rightTP = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        rightTP.layout();
        rightTP.paint(canvas, Offset(rulerRight + 6, y - rightTP.height / 2));

        // "cm" solo en el primer centímetro, a la derecha
        if (cm == 1) {
          final unitTP = TextPainter(
            text: const TextSpan(
              text: ' cm',
              style: TextStyle(color: Color(0xFF999999), fontSize: 10),
            ),
            textDirection: ui.TextDirection.ltr,
          );
          unitTP.layout();
          unitTP.paint(
            canvas,
            Offset(rulerRight + 6 + rightTP.width, y - unitTP.height / 2),
          );
        }
      }
    }

    // --- Marca de 0 en la parte superior ---
    final zeroTP = TextPainter(
      text: const TextSpan(
        text: '0',
        style: TextStyle(
          color: Color(0xFF333333),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    zeroTP.layout();
    zeroTP.paint(
      canvas,
      Offset(rulerLeft - zeroTP.width - 6, -zeroTP.height / 2 + 1),
    );
    zeroTP.paint(canvas, Offset(rulerRight + 6, -zeroTP.height / 2 + 1));
  }

  @override
  bool shouldRepaint(covariant _CenteredRulerPainter oldDelegate) {
    return oldDelegate.pxPerMm != pxPerMm ||
        oldDelegate.availableWidth != availableWidth;
  }
}
