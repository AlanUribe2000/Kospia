import '../database/app_database.dart';

enum TraitMatchStatus { unassessed, confirmed, incomplete, discarded }

class TraitSpeciesMatch {
  TraitSpeciesMatch({
    required this.species,
    required this.confirmedQuestions,
    required this.unknownQuestions,
    required Iterable<String> incompatibleQuestionIds,
  }) : incompatibleQuestionIds = List.unmodifiable(incompatibleQuestionIds);

  final Specy species;
  final int confirmedQuestions;
  final int unknownQuestions;
  final List<String> incompatibleQuestionIds;

  TraitMatchStatus get status {
    if (incompatibleQuestionIds.isNotEmpty) return TraitMatchStatus.discarded;
    if (unknownQuestions > 0) return TraitMatchStatus.incomplete;
    if (confirmedQuestions == 0) return TraitMatchStatus.unassessed;
    return TraitMatchStatus.confirmed;
  }
}

class SpeciesTraitsIdentificationResult {
  SpeciesTraitsIdentificationResult({
    required this.answeredQuestions,
    required Iterable<TraitSpeciesMatch> candidates,
    required Iterable<TraitSpeciesMatch> discarded,
  }) : candidates = List.unmodifiable(candidates),
       discarded = List.unmodifiable(discarded);

  final int answeredQuestions;
  final List<TraitSpeciesMatch> candidates;
  final List<TraitSpeciesMatch> discarded;

  TraitSpeciesMatch? get uniqueConfirmedMatch {
    if (answeredQuestions == 0 || candidates.length != 1) return null;
    final candidate = candidates.single;
    return candidate.status == TraitMatchStatus.confirmed ? candidate : null;
  }
}

class SpeciesTraitsIdentificationEngine {
  SpeciesTraitsIdentificationResult identify({
    required Iterable<Specy> species,
    required Iterable<SpeciesTrait> traits,
    required Map<String, Set<String>> answers,
  }) {
    final answered = <String, Set<String>>{};
    for (final entry in answers.entries) {
      if (entry.key.isEmpty || entry.value.any((option) => option.isEmpty)) {
        throw ArgumentError('Question and option IDs must not be empty.');
      }
      if (entry.value.isNotEmpty) answered[entry.key] = Set.of(entry.value);
    }

    final optionsBySpecies = <String, Map<String, Set<String>>>{};
    for (final trait in traits) {
      optionsBySpecies
          .putIfAbsent(trait.speciesId, () => {})
          .putIfAbsent(trait.questionId, () => {})
          .add(trait.optionId);
    }

    final candidates = <TraitSpeciesMatch>[];
    final discarded = <TraitSpeciesMatch>[];
    for (final plant in species.where((plant) => plant.isActive)) {
      var confirmed = 0;
      var unknown = 0;
      final incompatible = <String>[];
      for (final answer in answered.entries) {
        final available = optionsBySpecies[plant.id]?[answer.key];
        if (available == null || available.isEmpty) {
          unknown++;
        } else if (available.any(answer.value.contains)) {
          confirmed++;
        } else {
          incompatible.add(answer.key);
        }
      }
      final match = TraitSpeciesMatch(
        species: plant,
        confirmedQuestions: confirmed,
        unknownQuestions: unknown,
        incompatibleQuestionIds: incompatible,
      );
      if (incompatible.isEmpty) {
        candidates.add(match);
      } else {
        discarded.add(match);
      }
    }
    candidates.sort((left, right) {
      final confirmed = right.confirmedQuestions.compareTo(
        left.confirmedQuestions,
      );
      if (confirmed != 0) return confirmed;
      final unknown = left.unknownQuestions.compareTo(right.unknownQuestions);
      if (unknown != 0) return unknown;
      return left.species.id.compareTo(right.species.id);
    });
    discarded.sort(
      (left, right) => left.species.id.compareTo(right.species.id),
    );
    return SpeciesTraitsIdentificationResult(
      answeredQuestions: answered.length,
      candidates: candidates,
      discarded: discarded,
    );
  }
}
