import 'dart:math';

import '../database/app_database.dart';

/// Motor de identificación dinámico.
/// Selecciona la pregunta más discriminante en cada paso,
/// reduciendo candidatos lo más rápido posible.
class IdentificationEngine {
  final List<Specy> _allSpecies;
  final List<Question> _allQuestions;
  final Map<String, List<QuestionOption>> _optionsByQuestion;
  final List<SpeciesTrait> _allTraits;

  List<Specy> _candidates;
  final Set<String> _askedQuestionIds = {};

  IdentificationEngine({
    required List<Specy> allSpecies,
    required List<Question> allQuestions,
    required Map<String, List<QuestionOption>> optionsByQuestion,
    required List<SpeciesTrait> allTraits,
  }) : _allSpecies = allSpecies,
       _allQuestions = allQuestions,
       _optionsByQuestion = optionsByQuestion,
       _allTraits = allTraits,
       _candidates = List.from(allSpecies);

  /// Candidatos actuales.
  List<Specy> get candidates => _candidates;

  /// Número de preguntas ya hechas.
  int get questionsAsked => _askedQuestionIds.length;

  /// ¿Ya se llegó a un resultado (≤ 3 candidatos o no quedan preguntas)?
  bool get isFinished =>
      _candidates.length <= 3 ||
      _askedQuestionIds.length >= _allQuestions.length;

  /// Selecciona la mejor pregunta siguiente.
  /// Usa un score basado en cuánto reduce cada pregunta el grupo de candidatos.
  /// Devuelve null si ya no hay preguntas útiles.
  Question? getNextQuestion() {
    if (isFinished) return null;

    final candidateIds = _candidates.map((s) => s.id).toSet();
    Question? bestQuestion;
    double bestScore = -1;

    for (final question in _allQuestions) {
      if (_askedQuestionIds.contains(question.id)) continue;

      final options = _optionsByQuestion[question.id] ?? [];
      if (options.isEmpty) continue;

      // Calcular cómo distribuye esta pregunta a los candidatos
      final score = _calculateQuestionScore(question.id, options, candidateIds);

      if (score > bestScore) {
        bestScore = score;
        bestQuestion = question;
      }
    }

    return bestQuestion;
  }

  /// Calcula el score de una pregunta: cuánta información aporta.
  /// Usa "balance de partición": la pregunta ideal divide los candidatos
  /// en grupos lo más parejos posible (mayor entropía).
  double _calculateQuestionScore(
    String questionId,
    List<QuestionOption> options,
    Set<String> candidateIds,
  ) {
    final distribution = <String, int>{};
    int matched = 0;

    for (final option in options) {
      int count = 0;
      for (final trait in _allTraits) {
        if (trait.questionId == questionId &&
            trait.optionId == option.id &&
            candidateIds.contains(trait.speciesId)) {
          count++;
        }
      }
      if (count > 0) {
        distribution[option.id] = count;
        matched += count;
      }
    }

    if (distribution.isEmpty || distribution.length <= 1) return 0;

    // Entropía de Shannon normalizada
    double entropy = 0;
    for (final count in distribution.values) {
      if (count > 0) {
        final p = count / matched;
        entropy -= p * log(p) / ln2;
      }
    }

    // Normalizar por log2(número de opciones con candidatos)
    final maxEntropy = log(distribution.length) / ln2;
    return maxEntropy > 0 ? entropy / maxEntropy : 0;
  }

  /// Obtiene las opciones disponibles para una pregunta,
  /// filtrando solo las que tienen candidatos asociados.
  List<QuestionOption> getRelevantOptions(String questionId) {
    final options = _optionsByQuestion[questionId] ?? [];
    final candidateIds = _candidates.map((s) => s.id).toSet();

    return options.where((option) {
      return _allTraits.any(
        (trait) =>
            trait.questionId == questionId &&
            trait.optionId == option.id &&
            candidateIds.contains(trait.speciesId),
      );
    }).toList();
  }

  /// Aplica la respuesta del usuario: filtra candidatos que tengan
  /// el trait seleccionado para la pregunta dada.
  void applyAnswer(String questionId, String optionId) {
    _askedQuestionIds.add(questionId);

    // Encontrar especies que tienen este trait
    final matchingSpeciesIds = _allTraits
        .where((t) => t.questionId == questionId && t.optionId == optionId)
        .map((t) => t.speciesId)
        .toSet();

    _candidates = _candidates
        .where((s) => matchingSpeciesIds.contains(s.id))
        .toList();
  }

  /// Deshace la última respuesta (para poder volver atrás).
  /// Requiere re-calcular los candidatos desde cero.
  void reset() {
    _candidates = List.from(_allSpecies);
    _askedQuestionIds.clear();
  }

  /// Recalcula candidatos desde un historial de respuestas.
  void replayAnswers(List<MapEntry<String, String>> answers) {
    reset();
    for (final entry in answers) {
      applyAnswer(entry.key, entry.value);
    }
  }
}
