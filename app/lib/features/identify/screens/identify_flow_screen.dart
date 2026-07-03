import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/species_repository.dart';
import '../../collection/screens/capture_observation_screen.dart';

/// Pantalla de identificación paso a paso.
/// Muestra una pregunta a la vez con indicador de progreso.
/// Al final muestra el resultado en un bottom sheet.
class IdentifyFlowScreen extends StatefulWidget {
  const IdentifyFlowScreen({super.key});

  @override
  State<IdentifyFlowScreen> createState() => _IdentifyFlowScreenState();
}

class _IdentifyFlowScreenState extends State<IdentifyFlowScreen> {
  List<Question> _questions = [];
  Map<String, List<QuestionOption>> _optionsByQuestion = {};
  final List<String> _selectedOptionIds = [];
  int _currentStep = 0;
  bool _loading = true;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final db = context.read<AppDatabase>();
    final questions = await db.getAllQuestions();
    final optionsByQuestion = <String, List<QuestionOption>>{};

    for (final q in questions) {
      optionsByQuestion[q.id] = await db.getOptionsForQuestion(q.id);
    }

    if (mounted) {
      setState(() {
        _questions = questions;
        _optionsByQuestion = optionsByQuestion;
        _loading = false;
      });
    }
  }

  void _startIdentification() {
    setState(() {
      _started = true;
      _currentStep = 0;
      _selectedOptionIds.clear();
    });
  }

  void _selectOption(String optionId) {
    setState(() {
      _selectedOptionIds.add(optionId);
    });

    if (_currentStep < _questions.length - 1) {
      // Next question
      setState(() => _currentStep++);
    } else {
      // All questions answered - show result
      _showResult();
    }
  }

  Future<void> _showResult() async {
    final repo = context.read<SpeciesRepository>();
    final results = await repo.findByTraits(_selectedOptionIds);

    if (!mounted) return;

    final Specy? selectedSpecies = await showModalBottomSheet<Specy?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResultBottomSheet(
        results: results,
      ),
    );

    if (selectedSpecies != null && mounted) {
      // User confirmed species -> go to capture screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CaptureObservationScreen(species: selectedSpecies),
        ),
      );
    }

    // Reset flow
    setState(() {
      _started = false;
      _currentStep = 0;
      _selectedOptionIds.clear();
    });
  }

  void _cancel() {
    setState(() {
      _started = false;
      _currentStep = 0;
      _selectedOptionIds.clear();
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

    return _buildQuestionScreen();
  }

  Widget _buildStartScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded,
                  size: 48, color: AppColors.accentGreen),
            ),
            const SizedBox(height: 24),
            Text(
              'Identificar Planta',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Responde ${_questions.length} preguntas sobre la planta que estas viendo y te ayudamos a identificarla',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
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

  Widget _buildQuestionScreen() {
    final question = _questions[_currentStep];
    final options = _optionsByQuestion[question.id] ?? [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Progress indicator
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            // Question number
            Text(
              'PREGUNTA ${_currentStep + 1} DE ${_questions.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            // Question text
            Text(
              '¿${question.questionText}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Options list
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _OptionTile(
                    text: option.optionText,
                    onTap: () => _selectOption(option.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            TextButton(
              onPressed: _cancel,
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textMedium)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_questions.length, (index) {
        Color color;
        if (index < _currentStep) {
          color = AppColors.accentGreen;
        } else if (index == _currentStep) {
          color = AppColors.accentOrange;
        } else {
          color = AppColors.surfaceLilac;
        }
        return Container(
          width: 24,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

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
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet que muestra el resultado de la identificación.
class _ResultBottomSheet extends StatelessWidget {
  final List<Specy> results;

  const _ResultBottomSheet({required this.results});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundLilac,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (results.isEmpty) _buildNoResult(context),
                  if (results.length == 1) _buildSingleResult(context, results.first),
                  if (results.length > 1) _buildMultipleResults(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResult(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.help_outline_rounded,
              size: 40, color: AppColors.error),
        ),
        const SizedBox(height: 16),
        const Text(
          'No encontramos coincidencias',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Intenta responder de nuevo con otras opciones',
          style: TextStyle(color: AppColors.textMedium),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Volver al inicio'),
        ),
      ],
    );
  }

  Widget _buildSingleResult(BuildContext context, Specy species) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentOrange, width: 3),
          ),
          child: const Icon(Icons.local_florist_rounded,
              size: 40, color: AppColors.accentOrange),
        ),
        const SizedBox(height: 16),
        Text(
          '¡CREO QUE ES...!',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accentOrange,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          species.commonName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          species.scientificName,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            species.description,
            style: const TextStyle(color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(species),
            child: const Text('¡Desbloquear esta planta!'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Volver al inicio',
              style: TextStyle(color: AppColors.textMedium)),
        ),
      ],
    );
  }

  Widget _buildMultipleResults(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Encontramos varias opciones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Selecciona la que crees que es',
          style: TextStyle(color: AppColors.textMedium),
        ),
        const SizedBox(height: 20),
        ...results.map((species) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(species),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreenLight
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_florist_rounded,
                              color: AppColors.accentGreen),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(species.commonName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(species.scientificName,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: AppColors.textMedium)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textLight),
                      ],
                    ),
                  ),
                ),
              ),
            )),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Volver al inicio',
              style: TextStyle(color: AppColors.textMedium)),
        ),
      ],
    );
  }
}
