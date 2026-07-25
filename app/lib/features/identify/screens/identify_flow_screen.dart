import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/identification_engine.dart';
import '../../catalog/screens/species_detail_screen.dart';
import '../../collection/screens/capture_observation_screen.dart';

/// Pantalla de identificación dinámica estilo Akinator con Kospi.
/// Selecciona la pregunta más discriminante en cada paso.
/// Termina cuando quedan ≤3 candidatos o no hay más preguntas útiles.
class IdentifyFlowScreen extends StatefulWidget {
  const IdentifyFlowScreen({super.key});

  @override
  State<IdentifyFlowScreen> createState() => _IdentifyFlowScreenState();
}

class _IdentifyFlowScreenState extends State<IdentifyFlowScreen> {
  IdentificationEngine? _engine;
  bool _loading = true;
  bool _started = false;
  bool _showingResult = false;

  // Estado actual
  Question? _currentQuestion;
  List<QuestionOption> _currentOptions = [];
  final List<MapEntry<String, String>> _answerHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = context.read<AppDatabase>();

    final allSpecies = await db.getAllSpecies();
    final allQuestions = await db.getAllQuestions();
    final optionsByQuestion = <String, List<QuestionOption>>{};
    for (final q in allQuestions) {
      optionsByQuestion[q.id] = await db.getOptionsForQuestion(q.id);
    }
    final allTraits = await db.getAllTraits();

    if (mounted) {
      setState(() {
        _engine = IdentificationEngine(
          allSpecies: allSpecies,
          allQuestions: allQuestions,
          optionsByQuestion: optionsByQuestion,
          allTraits: allTraits,
        );
        _loading = false;
      });
    }
  }

  void _startIdentification() {
    _engine!.reset();
    _answerHistory.clear();
    final nextQ = _engine!.getNextQuestion();
    setState(() {
      _started = true;
      _showingResult = false;
      _currentQuestion = nextQ;
      _currentOptions = nextQ != null
          ? _engine!.getRelevantOptions(nextQ.id)
          : [];
    });
  }

  void _selectOption(String questionId, String optionId) {
    _engine!.applyAnswer(questionId, optionId);
    _answerHistory.add(MapEntry(questionId, optionId));

    if (_engine!.isFinished) {
      setState(() => _showingResult = true);
      return;
    }

    final nextQ = _engine!.getNextQuestion();
    if (nextQ == null) {
      setState(() => _showingResult = true);
      return;
    }

    setState(() {
      _currentQuestion = nextQ;
      _currentOptions = _engine!.getRelevantOptions(nextQ.id);
    });
  }

  void _goBack() {
    if (_answerHistory.isEmpty) {
      _reset();
      return;
    }
    _answerHistory.removeLast();
    _engine!.replayAnswers(_answerHistory);

    final nextQ = _engine!.getNextQuestion();
    setState(() {
      _showingResult = false;
      _currentQuestion = nextQ;
      _currentOptions = nextQ != null
          ? _engine!.getRelevantOptions(nextQ.id)
          : [];
    });
  }

  void _confirmSpecies(Specy species) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CaptureObservationScreen(species: species),
      ),
    );
    _reset();
  }

  void _viewSpeciesDetail(Specy species) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SpeciesDetailScreen(species: species)),
    );
  }

  void _reset() {
    setState(() {
      _started = false;
      _showingResult = false;
      _currentQuestion = null;
      _currentOptions = [];
      _answerHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_started) {
      return _buildStartScreen();
    }

    if (_showingResult) {
      return _buildResultScreen();
    }

    return _buildQuestionScreen();
  }

  // --- START SCREEN ---
  Widget _buildStartScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Kospi/Kospi saludando.png',
              height: 160,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 48,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLilac,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLilac.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '¡Vamos a identificar una planta!\nTe haré unas pocas preguntas para descubrir qué especie estás viendo.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startIdentification,
                child: const Text('Comenzar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- QUESTION SCREEN ---
  Widget _buildQuestionScreen() {
    final question = _currentQuestion!;
    final candidateCount = _engine!.candidates.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/Kospi/Kospi pensando.png',
              height: 120,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 40,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Info: candidatos restantes
            Text(
              'Pregunta ${_answerHistory.length + 1} · $candidateCount especies posibles',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            // Speech bubble
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLilac,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLilac.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                question.questionText,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Options
            Expanded(
              child: ListView.separated(
                itemCount: _currentOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final option = _currentOptions[index];
                  return _OptionTile(
                    text: option.optionText,
                    onTap: () => _selectOption(question.id, option.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    _answerHistory.isNotEmpty ? 'Anterior' : 'Volver',
                    style: const TextStyle(color: AppColors.textMedium),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- RESULT SCREEN ---
  Widget _buildResultScreen() {
    final results = _engine!.candidates;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset(
              'assets/images/Kospi/Kospi tomandose las manos.png',
              height: 140,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLilac,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLilac.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                results.isEmpty
                    ? 'Hmm, no encontré una planta que coincida. ¡Intenta de nuevo!'
                    : results.length == 1
                    ? '¡Creo que es:'
                    : '¡Podría ser una de estas ${results.length} especies!',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            if (_answerHistory.isNotEmpty)
              Text(
                'Respondiste ${_answerHistory.length} preguntas',
                style: TextStyle(fontSize: 12, color: AppColors.textMedium),
              ),
            const SizedBox(height: 12),
            if (results.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 56,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sin coincidencias',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Intenta cambiar tus respuestas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final species = results[index];
                    return _SpeciesResultCard(
                      species: species,
                      onViewDetail: () => _viewSpeciesDetail(species),
                      onConfirm: () => _confirmSpecies(species),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _reset,
                child: const Text('Intentar de nuevo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- OPTION TILE ---
class _OptionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OptionTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLilac,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: AppColors.textDark),
          ),
        ),
      ),
    );
  }
}

// --- SPECIES RESULT CARD ---
class _SpeciesResultCard extends StatelessWidget {
  final Specy species;
  final VoidCallback onViewDetail;
  final VoidCallback onConfirm;

  const _SpeciesResultCard({
    required this.species,
    required this.onViewDetail,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onViewDetail,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_florist_rounded,
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.commonName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          species.scientificName,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                        if (species.family.isNotEmpty)
                          Text(
                            species.family,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textLight),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetail,
                    child: const Text('Ver detalle'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text('¡Es esta!'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
