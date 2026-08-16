import 'package:flutter/material.dart';

import 'characteristic_painters.dart';

/// Widget que renderiza la ilustración correspondiente a una opción
/// de pregunta del cuestionario, basándose en el fieldName y el valor.
class OptionIllustration extends StatelessWidget {
  final String fieldName;
  final String optionValue;
  final double size;

  const OptionIllustration({
    super.key,
    required this.fieldName,
    required this.optionValue,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final painter = _getPainter();
    if (painter != null) {
      return CustomPaint(size: Size(size, size), painter: painter);
    }

    // Fallback: ícono con color contextual
    final iconData = _getFallbackIcon();
    final iconColor = _getFallbackColor();
    return Icon(iconData, size: size * 0.55, color: iconColor);
  }

  CustomPainter? _getPainter() {
    switch (fieldName) {
      case 'leafShape':
        return _leafShapePainter();
      case 'leafEdge':
        return _leafEdgePainter();
      case 'leafLength':
        return _leafSizePainter();
      case 'leafTexture':
        return _leafTexturePainter();
      case 'biologicalForm':
        return _biologicalFormPainter();
      case 'approximateHeight':
        return _heightPainter();
      case 'flowerColor':
        return _flowerColorPainter();
      case 'flowerSize':
        return _flowerSizePainter();
      case 'flowerGrouping':
        return _flowerGroupingPainter();
      case 'petalCount':
        return _petalCountPainter();
      case 'spineType':
        return _spineTypePainter();
      case 'fruitShape':
        return _fruitShapePainter();
      case 'fruitColor':
        return _fruitColorPainter();
      case 'fruitSize':
        return _fruitSizePainter();
      case 'hasSpines':
      case 'hasFruit':
        return null; // Usa fallback de ícono check/cancel
      default:
        return null;
    }
  }

  // ============ LEAF SHAPE ============

  CustomPainter? _leafShapePainter() {
    switch (optionValue) {
      case 'lanceoladas':
        return LanceoladaPainter();
      case 'elíptica':
        return ElipticaPainter();
      case 'lineares':
        return LinearPainter();
      case 'acicular':
        return AcicularPainter();
      case 'triangulares/tripartidas':
        return TriangularPainter();
      case 'obovada/espatulada':
        return ObovadaPainter();
      case 'compuesta':
        return CompuestaPainter();
      case 'oblanceolada':
        return OblanceoladaPainter();
      default:
        return null;
    }
  }

  // ============ LEAF EDGE ============

  CustomPainter? _leafEdgePainter() {
    switch (optionValue) {
      case 'entero':
        return BordeEnteroPainter();
      case 'aserrado':
        return BordeAserradoPainter();
      case 'espinoso':
        return BordeEspinosoPainter();
      default:
        return null;
    }
  }

  // ============ LEAF SIZE ============

  CustomPainter? _leafSizePainter() {
    int level;
    switch (optionValue) {
      case 'muy pequeña':
        level = 0;
        break;
      case 'pequeña':
        level = 1;
        break;
      case 'mediana':
        level = 2;
        break;
      case 'grande':
        level = 3;
        break;
      case 'muy grande':
        level = 4;
        break;
      default:
        return null;
    }
    return LeafSizePainter(level: level);
  }

  // ============ LEAF TEXTURE ============

  CustomPainter? _leafTexturePainter() {
    switch (optionValue) {
      case 'coriácea':
        return TexturaCoriaceaPainter();
      case 'flexible':
        return TexturaFlexiblePainter();
      case 'firme':
        return TexturaFirmePainter();
      case 'blanda/carnosa':
        return TexturaCarnosaPainter();
      case 'pegajosa':
        return TexturaPegajosaPainter();
      default:
        return null;
    }
  }

  // ============ BIOLOGICAL FORM ============

  CustomPainter? _biologicalFormPainter() {
    switch (optionValue) {
      case 'arbusto':
        return ArbustoPainter();
      case 'hierba':
        return HierbaPainter();
      case 'subarbusto':
        return SubarbustoPainter();
      case 'subarbusto suculento':
        return SuculentaPainter(color: const Color(0xFF2D8C2D));
      case 'hierba suculenta':
        return SuculentaPainter(color: const Color(0xFF66BB6A));
      default:
        return null;
    }
  }

  // ============ HEIGHT ============

  CustomPainter? _heightPainter() {
    int level;
    switch (optionValue) {
      case 'muy baja':
        level = 0;
        break;
      case 'baja':
        level = 1;
        break;
      case 'media':
        level = 2;
        break;
      case 'alta':
        level = 3;
        break;
      default:
        return null;
    }
    return HeightPainter(level: level);
  }

  // ============ FLOWER COLOR ============

  CustomPainter? _flowerColorPainter() {
    final colorMap = <String, Color>{
      'amarillo': const Color(0xFFFFEB3B),
      'blanco': const Color(0xFFF5F5F5),
      'rojizo': const Color(0xFFE53935),
      'violeta': const Color(0xFF7B1FA2),
      'rosa': const Color(0xFFF48FB1),
      'naranja': const Color(0xFFFF9800),
      'crema': const Color(0xFFFFF8E1),
      'verde': const Color(0xFF4CAF50),
      'blanco/violáceo': const Color(0xFFCE93D8),
    };

    final petalColor = colorMap[optionValue];
    if (petalColor != null) {
      return FlowerColorPainter(petalColor: petalColor);
    }
    return null;
  }

  // ============ FLOWER SIZE ============

  CustomPainter? _flowerSizePainter() {
    int level;
    switch (optionValue) {
      case 'muy pequeña':
        level = 0;
        break;
      case 'pequeñas':
        level = 1;
        break;
      case 'mediana':
        level = 2;
        break;
      case 'grandes':
        level = 3;
        break;
      default:
        return null;
    }
    return FlowerSizePainter(level: level);
  }

  // ============ FLOWER GROUPING ============

  CustomPainter? _flowerGroupingPainter() {
    switch (optionValue) {
      case 'individual':
        return FlowerIndividualPainter();
      case 'inflorescencia':
        return FlowerInflorescenciaPainter();
      case 'cono':
        return FlowerConoPainter();
      default:
        return null;
    }
  }

  // ============ PETAL COUNT ============

  CustomPainter? _petalCountPainter() {
    switch (optionValue) {
      case '4':
        return PetalCountPainter(petalCount: 4);
      case '5':
        return PetalCountPainter(petalCount: 5);
      case '6':
        return PetalCountPainter(petalCount: 6);
      case 'muchos':
        return PetalCountPainter(petalCount: 10);
      case 'sin pétalos visibles':
        return PetalCountPainter(petalCount: 0);
      default:
        return null;
    }
  }

  // ============ SPINE TYPE ============

  CustomPainter? _spineTypePainter() {
    switch (optionValue) {
      case 'foliares/trífidas':
        return SpineFoliaresTrifidas();
      case 'caulinares':
        return SpineCaulinares();
      case 'ramas_espinosas':
        return SpineRamasEspinosas();
      case 'foliares/cortas':
        return SpineFoliaresCortas();
      default:
        return null;
    }
  }

  // ============ FRUIT SHAPE ============

  CustomPainter? _fruitShapePainter() {
    switch (optionValue) {
      case 'esférico':
        return FruitEsfericoPainter();
      case 'ovoide/alado':
        return FruitOvoidePainter();
      case 'globoso/trilobulado':
        return FruitGlobosoPainter();
      case 'cilíndrico':
        return FruitCilindricoPainter();
      case 'elipsoide/alado':
        return FruitElipsoidePainter();
      case 'piloso':
        return FruitPilosoPainter();
      default:
        return null;
    }
  }

  // ============ FRUIT COLOR ============

  CustomPainter? _fruitColorPainter() {
    final colorMap = <String, Color>{
      'azul oscuro': const Color(0xFF1A237E),
      'rojizo': const Color(0xFFD32F2F),
      'verde': const Color(0xFF4CAF50),
      'rojizo-amarronado': const Color(0xFFA1543D),
      'castaño-pardo': const Color(0xFF795548),
      'blanco-grisáceo': const Color(0xFFBDBDBD),
    };

    final fruitColor = colorMap[optionValue];
    if (fruitColor != null) {
      return FruitColorPainter(fruitColor: fruitColor);
    }
    return null;
  }

  // ============ FRUIT SIZE ============

  CustomPainter? _fruitSizePainter() {
    int level;
    switch (optionValue) {
      case 'muy pequeño':
        level = 0;
        break;
      case 'pequeño':
        level = 1;
        break;
      case 'mediano':
        level = 2;
        break;
      case 'grande':
        level = 3;
        break;
      default:
        return null;
    }
    return FruitSizePainter(level: level);
  }

  // ============ FALLBACKS ============

  IconData _getFallbackIcon() {
    switch (fieldName) {
      case 'hasSpines':
        return optionValue == 'true'
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;
      case 'hasFruit':
        return optionValue == 'true'
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  Color _getFallbackColor() {
    if (fieldName == 'hasSpines' || fieldName == 'hasFruit') {
      return optionValue == 'true'
          ? const Color(0xFF4CAF50)
          : const Color(0xFFE53935);
    }
    return const Color(0xFF2D8C2D);
  }

  /// Indica si este fieldName tiene ilustraciones visuales dedicadas.
  static bool hasVisualIllustration(String fieldName) {
    return const [
      'leafShape',
      'leafEdge',
      'leafLength',
      'leafTexture',
      'biologicalForm',
      'approximateHeight',
      'flowerColor',
      'flowerSize',
      'flowerGrouping',
      'petalCount',
      'spineType',
      'fruitShape',
      'fruitColor',
      'fruitSize',
      'hasSpines',
      'hasFruit',
    ].contains(fieldName);
  }
}
