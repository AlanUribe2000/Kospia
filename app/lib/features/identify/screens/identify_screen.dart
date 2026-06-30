import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/species_repository.dart';
import '../../catalog/screens/species_detail_screen.dart';

/// Pantalla de identificacion por preguntas guiadas.
class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  List<Question> _questions = [];
  Map<String, List<QuestionOption>> _optionsByQuestion = {};
  final Map<String, String> _selectedOptions = {}; // questionId -> optionId
  List<Specy> _results = [];
  bool _loading = true;
  bool _showResults = false;

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

  Future<void> _search() async {
    if (_selectedOptions.isEmpty) return;

    final repo = context.read<SpeciesRepository>();
    final results =
        await repo.findByTraits(_selectedOptions.values.toList());

    if (mounted) {
      setState(() {
        _results = results;
        _showResults = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedOptions.clear();
      _results.clear();
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Identificar Planta',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 4),
            Text('Responde las preguntas para encontrar la especie',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Expanded(
              child: _showResults ? _buildResults() : _buildQuestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestions() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: _questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final question = _questions[index];
              final options = _optionsByQuestion[question.id] ?? [];
              return _QuestionCard(
                question: question,
                options: options,
                selectedOptionId: _selectedOptions[question.id],
                onOptionSelected: (optionId) {
                  setState(() {
                    _selectedOptions[question.id] = optionId;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                child: const Text('Limpiar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _selectedOptions.isNotEmpty ? _search : null,
                child: const Text('Buscar Especie'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        if (_results.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 64, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text('No se encontraron coincidencias',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Intenta cambiar tus respuestas',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final species = _results[index];
                return _SpeciesResultCard(
                  species: species,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SpeciesDetailScreen(species: species),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _reset,
            child: const Text('Nueva busqueda'),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final List<QuestionOption> options;
  final String? selectedOptionId;
  final ValueChanged<String> onOptionSelected;

  const _QuestionCard({
    required this.question,
    required this.options,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.questionText,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final isSelected = opt.id == selectedOptionId;
                return ChoiceChip(
                  label: Text(opt.optionText),
                  selected: isSelected,
                  onSelected: (_) => onOptionSelected(opt.id),
                  selectedColor: AppColors.accentGreenLight,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesResultCard extends StatelessWidget {
  final Specy species;
  final VoidCallback onTap;

  const _SpeciesResultCard({
    required this.species,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accentGreenLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_florist_rounded,
              color: AppColors.accentGreen),
        ),
        title: Text(species.commonName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(species.scientificName,
            style: const TextStyle(fontStyle: FontStyle.italic)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
