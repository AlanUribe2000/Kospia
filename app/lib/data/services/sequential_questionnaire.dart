import '../database/app_database.dart';

/// Configuración de una pregunta del cuestionario secuencial.
/// Cada pregunta mapea a un campo de la tabla Species.
class QuestionConfig {
  final String id;
  final String text;
  final String fieldName;
  final List<String> options;

  /// Parte de la planta requerida para mostrar esta pregunta.
  /// 'general' = se muestra siempre.
  final String requiredPart;

  const QuestionConfig({
    required this.id,
    required this.text,
    required this.fieldName,
    required this.options,
    required this.requiredPart,
  });
}

/// Motor de cuestionario secuencial.
/// Hace TODAS las preguntas relevantes según las partes fotografiadas.
/// Filtra candidatos progresivamente.
class SequentialQuestionnaire {
  final Set<String> _photoParts;

  List<Specy> _candidates;
  int _currentIndex = 0;
  final Map<String, String> _answers = {};
  final List<List<Specy>> _candidateHistory = [];
  late final List<QuestionConfig> _relevantQuestions;

  SequentialQuestionnaire({
    required List<Specy> allSpecies,
    required Set<String> photoParts,
  }) : _photoParts = photoParts,
       _candidates = List.from(allSpecies) {
    // Pre-filtrar: si subió fotos de espinas, la planta tiene espinas
    if (_photoParts.contains('espinas')) {
      _candidates = _candidates.where((sp) => sp.hasSpines).toList();
    }
    // Pre-filtrar: si subió fotos de fruto, la planta tiene fruto visible
    if (_photoParts.contains('fruto')) {
      _candidates = _candidates.where((sp) => sp.hasFruit).toList();
    }
    _relevantQuestions = _buildRelevantQuestions();
  }

  List<Specy> get candidates => _candidates;
  int get totalQuestions => _relevantQuestions.length;
  int get answeredCount => _currentIndex;
  bool get isFinished => _currentIndex >= _relevantQuestions.length;
  bool get canUndo => _currentIndex > 0;
  Map<String, String> get answers => Map.unmodifiable(_answers);

  /// Pregunta actual o null si terminó.
  QuestionConfig? get currentQuestion {
    if (isFinished) return null;
    return _relevantQuestions[_currentIndex];
  }

  /// Responde la pregunta actual y filtra candidatos.
  void answer(String value) {
    if (isFinished) return;

    final question = _relevantQuestions[_currentIndex];
    _answers[question.fieldName] = value;

    // Guardar estado previo para poder volver atrás
    _candidateHistory.add(List.from(_candidates));

    // Filtrar candidatos
    _candidates = _candidates.where((sp) {
      return _matchesField(sp, question.fieldName, value);
    }).toList();

    _currentIndex++;
  }

  /// Deshace la última respuesta y restaura candidatos previos.
  void undo() {
    if (!canUndo) return;

    _currentIndex--;
    final question = _relevantQuestions[_currentIndex];
    _answers.remove(question.fieldName);

    // Restaurar candidatos del estado previo
    _candidates = _candidateHistory.removeLast();
  }

  /// Construye la lista de preguntas relevantes según las partes fotografiadas.
  /// Si el usuario subió fotos de espinas, no pregunta "¿Tiene espinas?" (es obvio que sí).
  /// Si subió fotos de fruto, no pregunta "¿Se ven frutos?" (es obvio que sí).
  List<QuestionConfig> _buildRelevantQuestions() {
    return allQuestions.where((q) {
      if (q.requiredPart == 'general') return true;
      if (!_photoParts.contains(q.requiredPart)) return false;

      // Si tiene fotos de espinas, no preguntar "¿Tiene espinas?"
      if (q.id == 'q-espinas' && _photoParts.contains('espinas')) return false;
      // Si tiene fotos de fruto, no preguntar "¿Se ven frutos?"
      if (q.id == 'q-fruto-visible' && _photoParts.contains('fruto'))
        return false;

      return true;
    }).toList();
  }

  /// Compara el valor de un campo de una especie con la respuesta del usuario.
  bool _matchesField(Specy sp, String fieldName, String value) {
    final fieldValue = _getFieldValue(sp, fieldName).toLowerCase();
    final answer = value.toLowerCase();

    if (fieldValue.isEmpty) return true; // Si no hay dato, no filtrar

    // Para campos booleanos
    if (fieldName == 'hasSpines' ||
        fieldName == 'hasFruit' ||
        fieldName == 'leafHairy') {
      final boolValue = _getBoolField(sp, fieldName);
      return boolValue.toString() == answer;
    }

    // Para campos de texto: match parcial (el valor del campo contiene la respuesta)
    return fieldValue.contains(answer) || answer.contains(fieldValue);
  }

  String _getFieldValue(Specy sp, String fieldName) {
    switch (fieldName) {
      case 'biologicalForm':
        return sp.biologicalForm;
      case 'approximateHeight':
        return sp.approximateHeight;
      case 'leafLength':
        return sp.leafLength;
      case 'leafShape':
        return sp.leafShape;
      case 'leafEdge':
        return sp.leafEdge;
      case 'leafTexture':
        return sp.leafTexture;
      case 'hasSpines':
        return sp.hasSpines.toString();
      case 'spineType':
        return sp.spineType;
      case 'flowerColor':
        return sp.flowerColor;
      case 'flowerGrouping':
        return sp.flowerGrouping;
      case 'petalCount':
        return sp.petalCount;
      case 'flowerSize':
        return sp.flowerSize;
      case 'hasFruit':
        return sp.hasFruit.toString();
      case 'fruitShape':
        return sp.fruitShape;
      case 'fruitColor':
        return sp.fruitColor;
      case 'fruitSize':
        return sp.fruitSize;
      default:
        return '';
    }
  }

  bool _getBoolField(Specy sp, String fieldName) {
    switch (fieldName) {
      case 'hasSpines':
        return sp.hasSpines;
      case 'hasFruit':
        return sp.hasFruit;
      default:
        return false;
    }
  }

  /// Todas las preguntas posibles del sistema, en orden.
  static const List<QuestionConfig> allQuestions = [
    // === SIEMPRE (general) ===
    QuestionConfig(
      id: 'q-forma-biologica',
      text: '¿Qué tipo de planta es?',
      fieldName: 'biologicalForm',
      requiredPart: 'general',
      options: [
        'arbusto',
        'hierba',
        'subarbusto',
        'subarbusto suculento',
        'hierba suculenta',
      ],
    ),
    QuestionConfig(
      id: 'q-altura',
      text: '¿Qué altura tiene aproximadamente?',
      fieldName: 'approximateHeight',
      requiredPart: 'general',
      options: ['muy baja', 'baja', 'media', 'alta'],
    ),
    // === HOJA ===
    QuestionConfig(
      id: 'q-long-hoja',
      text: '¿Qué tamaño tienen las hojas?',
      fieldName: 'leafLength',
      requiredPart: 'hoja',
      options: ['muy pequeña', 'pequeña', 'mediana', 'grande', 'muy grande'],
    ),
    QuestionConfig(
      id: 'q-forma-hoja',
      text: '¿Qué forma tienen las hojas?',
      fieldName: 'leafShape',
      requiredPart: 'hoja',
      options: [
        'elíptica',
        'lanceoladas',
        'lineares',
        'acicular',
        'triangulares/tripartidas',
        'obovada/espatulada',
        'compuesta',
        'oblanceolada',
      ],
    ),
    QuestionConfig(
      id: 'q-borde-hoja',
      text: '¿Cómo es el borde de las hojas?',
      fieldName: 'leafEdge',
      requiredPart: 'hoja',
      options: ['entero', 'aserrado', 'espinoso'],
    ),
    QuestionConfig(
      id: 'q-textura-hoja',
      text: '¿Qué textura tienen las hojas?',
      fieldName: 'leafTexture',
      requiredPart: 'hoja',
      options: ['coriácea', 'flexible', 'firme', 'blanda/carnosa', 'pegajosa'],
    ),
    QuestionConfig(
      id: 'q-hojas-espinosas',
      text: '¿Las hojas son espinosas?',
      fieldName: 'hasSpines',
      requiredPart: 'hoja',
      options: ['true', 'false'],
    ),
    // === ESPINAS ===
    QuestionConfig(
      id: 'q-espinas',
      text: '¿Tiene espinas?',
      fieldName: 'hasSpines',
      requiredPart: 'espinas',
      options: ['true', 'false'],
    ),
    QuestionConfig(
      id: 'q-tipo-espinas',
      text: '¿Qué tipo de espinas tiene?',
      fieldName: 'spineType',
      requiredPart: 'espinas',
      options: [
        'foliares/trífidas',
        'caulinares',
        'ramas_espinosas',
        'foliares/cortas',
      ],
    ),
    // === FLOR ===
    QuestionConfig(
      id: 'q-color-flor',
      text: '¿De qué color es la flor?',
      fieldName: 'flowerColor',
      requiredPart: 'flor',
      options: [
        'amarillo',
        'blanco',
        'rojizo',
        'violeta',
        'rosa',
        'naranja',
        'crema',
        'verde',
        'blanco/violáceo',
      ],
    ),
    QuestionConfig(
      id: 'q-agrupacion-flor',
      text: '¿Las flores están agrupadas o son individuales?',
      fieldName: 'flowerGrouping',
      requiredPart: 'flor',
      options: ['individual', 'inflorescencia', 'cono'],
    ),
    QuestionConfig(
      id: 'q-cant-petalos',
      text: '¿Cuántos pétalos tiene la flor?',
      fieldName: 'petalCount',
      requiredPart: 'flor',
      options: ['4', '5', '6', 'muchos', 'sin pétalos visibles'],
    ),
    QuestionConfig(
      id: 'q-long-flor',
      text: '¿Qué tamaño tiene la flor?',
      fieldName: 'flowerSize',
      requiredPart: 'flor',
      options: ['muy pequeña', 'pequeñas', 'mediana', 'grandes'],
    ),
    // === FRUTO ===
    QuestionConfig(
      id: 'q-fruto-visible',
      text: '¿Se ven frutos?',
      fieldName: 'hasFruit',
      requiredPart: 'fruto',
      options: ['true', 'false'],
    ),
    QuestionConfig(
      id: 'q-forma-fruto',
      text: '¿Qué forma tiene el fruto?',
      fieldName: 'fruitShape',
      requiredPart: 'fruto',
      options: [
        'esférico',
        'ovoide/alado',
        'globoso/trilobulado',
        'cilíndrico',
        'elipsoide/alado',
        'piloso',
      ],
    ),
    QuestionConfig(
      id: 'q-color-fruto',
      text: '¿De qué color es el fruto?',
      fieldName: 'fruitColor',
      requiredPart: 'fruto',
      options: [
        'azul oscuro',
        'rojizo',
        'verde',
        'rojizo-amarronado',
        'castaño-pardo',
        'blanco-grisáceo',
      ],
    ),
    QuestionConfig(
      id: 'q-tamano-fruto',
      text: '¿Qué tamaño tiene el fruto?',
      fieldName: 'fruitSize',
      requiredPart: 'fruto',
      options: ['muy pequeño', 'pequeño', 'mediano', 'grande'],
    ),
  ];

  /// Labels amigables para las opciones booleanas.
  static String friendlyOption(String fieldName, String value) {
    if (fieldName == 'hasSpines' || fieldName == 'hasFruit') {
      if (value == 'true') return 'Sí';
      if (value == 'false') return 'No';
    }
    if (fieldName == 'approximateHeight') {
      switch (value) {
        case 'muy baja':
          return 'Muy baja (< 30 cm)';
        case 'baja':
          return 'Baja (30–60 cm)';
        case 'media':
          return 'Media (60 cm – 1 m)';
        case 'alta':
          return 'Alta (> 1 m)';
      }
    }
    if (fieldName == 'leafLength') {
      switch (value) {
        case 'muy pequeña':
          return 'Muy pequeña (≤ 1 cm)';
        case 'pequeña':
          return 'Pequeña (1–3 cm)';
        case 'mediana':
          return 'Mediana (3–6 cm)';
        case 'grande':
          return 'Grande (6–10 cm)';
        case 'muy grande':
          return 'Muy grande (≥ 10 cm)';
      }
    }
    if (fieldName == 'flowerSize') {
      switch (value) {
        case 'muy pequeña':
          return 'Muy pequeña (≤ 5 mm)';
        case 'pequeñas':
          return 'Pequeña (5–10 mm)';
        case 'mediana':
          return 'Mediana (10–15 mm)';
        case 'grandes':
          return 'Grande (> 15 mm)';
      }
    }
    if (fieldName == 'fruitSize') {
      switch (value) {
        case 'muy pequeño':
          return 'Muy pequeño (≤ 5 mm)';
        case 'pequeño':
          return 'Pequeño (5–10 mm)';
        case 'mediano':
          return 'Mediano (10–15 mm)';
        case 'grande':
          return 'Grande (> 15 mm)';
      }
    }
    // Capitalize first letter
    if (value.isNotEmpty) {
      return value[0].toUpperCase() + value.substring(1);
    }
    return value;
  }
}
