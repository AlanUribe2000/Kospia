import 'package:flutter_test/flutter_test.dart';
import 'package:kospia/data/database/app_database.dart';
import 'package:kospia/data/services/sequential_questionnaire.dart';
import 'package:kospia/data/services/species_traits_identification_engine.dart';

Specy plant(String id, {bool active = true, String biologicalForm = ''}) =>
    Specy(
      id: id,
      commonName: id,
      scientificName: id,
      description: '',
      imageUrl: '',
      family: '',
      habitat: '',
      flowerColor: '',
      biologicalForm: biologicalForm,
      approximateHeight: '',
      leafLength: '',
      leafShape: '',
      leafEdge: '',
      leafTexture: '',
      hasSpines: false,
      spineType: '',
      flowerGrouping: '',
      petalCount: '',
      flowerSize: '',
      hasFruit: false,
      fruitShape: '',
      fruitColor: '',
      fruitSize: '',
      observations: '',
      isActive: active,
      syncStatus: 'synced',
      createdAt: DateTime.utc(2026),
    );

SpeciesTrait trait(String id, String species, String question, String option) =>
    SpeciesTrait(
      id: id,
      speciesId: species,
      questionId: question,
      optionId: option,
    );

void main() {
  test('exact IDs distinguish confirmed, incompatible and missing traits', () {
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: [plant('confirmed'), plant('rejected'), plant('unknown')],
      traits: [
        trait('1', 'confirmed', 'q-001', 'opt-fb-01'),
        trait('2', 'rejected', 'q-001', 'opt-fb-02'),
      ],
      answers: {
        'q-001': {'opt-fb-01'},
      },
    );
    expect(result.answeredQuestions, 1);
    expect(result.candidates.map((item) => item.species.id), [
      'confirmed',
      'unknown',
    ]);
    expect(result.candidates.first.status, TraitMatchStatus.confirmed);
    expect(result.candidates.last.status, TraitMatchStatus.incomplete);
    expect(result.discarded.single.incompatibleQuestionIds, ['q-001']);
    expect(result.uniqueConfirmedMatch, isNull);
  });

  test('OR within a question and AND between questions', () {
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: [plant('both'), plant('one'), plant('wrong')],
      traits: [
        trait('1', 'both', 'q-008', 'opt-len-01'),
        trait('2', 'both', 'q-008', 'opt-len-02'),
        trait('3', 'both', 'q-003', 'opt-es-01'),
        trait('4', 'one', 'q-008', 'opt-len-02'),
        trait('5', 'wrong', 'q-003', 'opt-es-02'),
      ],
      answers: {
        'q-008': {'opt-len-02', 'opt-len-03'},
        'q-003': {'opt-es-01'},
      },
    );
    expect(result.answeredQuestions, 2);
    expect(result.candidates.map((item) => item.species.id), ['both', 'one']);
    expect(result.candidates.first.confirmedQuestions, 2);
    expect(result.candidates.first.unknownQuestions, 0);
    expect(result.candidates.last.confirmedQuestions, 1);
    expect(result.candidates.last.unknownQuestions, 1);
    expect(result.discarded.single.species.id, 'wrong');
    expect(result.discarded.single.incompatibleQuestionIds, ['q-003']);
  });

  test('incompatible options take precedence over missing data', () {
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: [plant('a')],
      traits: [trait('1', 'a', 'q-001', 'opt-1')],
      answers: {
        'q-001': {'opt-2'},
        'q-002': {'opt-3'},
      },
    );
    expect(result.candidates, isEmpty);
    expect(result.discarded.single.status, TraitMatchStatus.discarded);
    expect(result.discarded.single.unknownQuestions, 1);
    expect(result.discarded.single.incompatibleQuestionIds, ['q-001']);
  });

  test('empty answer set means no sabe and does not count', () {
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: [plant('a')],
      traits: [trait('1', 'a', 'q-001', 'opt-1')],
      answers: {'q-001': <String>{}},
    );
    expect(result.answeredQuestions, 0);
    expect(result.candidates.single.confirmedQuestions, 0);
    expect(result.candidates.single.status, TraitMatchStatus.unassessed);
    expect(result.uniqueConfirmedMatch, isNull);
  });

  test(
    'no sabe is ignored alongside answers and all conflicts are reported',
    () {
      final result = SpeciesTraitsIdentificationEngine().identify(
        species: [plant('a')],
        traits: [
          trait('1', 'a', 'q-001', 'opt-1'),
          trait('2', 'a', 'q-002', 'opt-2'),
          trait('3', 'a', 'q-003', 'opt-3'),
        ],
        answers: {
          'q-001': {'other-1'},
          'q-002': <String>{},
          'q-003': {'other-3'},
        },
      );
      expect(result.answeredQuestions, 2);
      expect(result.discarded.single.incompatibleQuestionIds, [
        'q-001',
        'q-003',
      ]);
      expect(result.discarded.single.unknownQuestions, 0);
    },
  );

  test('inactive species are excluded from candidates and discards', () {
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: [plant('active'), plant('inactive', active: false)],
      traits: [trait('1', 'inactive', 'q-001', 'opt-1')],
      answers: {
        'q-001': {'opt-1'},
      },
    );
    expect(result.candidates.map((item) => item.species.id), ['active']);
    expect(result.discarded, isEmpty);
  });

  test('unique result must have evidence for every answered question', () {
    final engine = SpeciesTraitsIdentificationEngine();
    final confirmed = engine.identify(
      species: [plant('a')],
      traits: [trait('1', 'a', 'q-001', 'opt-1')],
      answers: {
        'q-001': {'opt-1'},
      },
    );
    expect(confirmed.uniqueConfirmedMatch?.species.id, 'a');

    final missing = engine.identify(
      species: [plant('a')],
      traits: [],
      answers: {
        'q-001': {'opt-1'},
      },
    );
    expect(missing.candidates.single.unknownQuestions, 1);
    expect(missing.uniqueConfirmedMatch, isNull);

    final partial = engine.identify(
      species: [plant('a')],
      traits: [trait('1', 'a', 'q-001', 'opt-1')],
      answers: {
        'q-001': {'opt-1'},
        'q-002': {'opt-2'},
      },
    );
    expect(partial.candidates.single.confirmedQuestions, 1);
    expect(partial.uniqueConfirmedMatch, isNull);
  });

  test('empty datasets and no matching candidates are supported', () {
    final engine = SpeciesTraitsIdentificationEngine();
    final empty = engine.identify(species: [], traits: [], answers: {});
    expect(empty.candidates, isEmpty);
    expect(empty.discarded, isEmpty);
    expect(empty.uniqueConfirmedMatch, isNull);
    final none = engine.identify(
      species: [plant('a')],
      traits: [trait('1', 'a', 'q-001', 'opt-1')],
      answers: {
        'q-001': {'opt-2'},
      },
    );
    expect(none.candidates, isEmpty);
    expect(none.discarded.single.species.id, 'a');
  });

  test('IDs are exact and scoped to their question', () {
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: [plant('a')],
      traits: [trait('1', 'a', 'q-001', 'opt-01')],
      answers: {
        'q-001': {'opt-1'},
        'q-002': {'opt-01'},
      },
    );
    expect(result.discarded.single.incompatibleQuestionIds, ['q-001']);
    expect(result.discarded.single.unknownQuestions, 1);
  });

  test('empty identifiers are rejected instead of inventing an answer', () {
    final engine = SpeciesTraitsIdentificationEngine();
    expect(
      () => engine.identify(
        species: [],
        traits: [],
        answers: {
          '': {'opt-1'},
        },
      ),
      throwsArgumentError,
    );
    expect(
      () => engine.identify(
        species: [],
        traits: [],
        answers: {
          'q-001': {''},
        },
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate inputs and exposes immutable result lists', () {
    final species = [plant('a'), plant('b')];
    final traits = [trait('1', 'a', 'q-001', 'opt-1')];
    final answers = <String, Set<String>>{
      'q-001': {'opt-1'},
    };
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: species,
      traits: traits,
      answers: answers,
    );
    expect(species.map((item) => item.id), ['a', 'b']);
    expect(traits.single.optionId, 'opt-1');
    expect(answers, {
      'q-001': {'opt-1'},
    });
    expect(() => result.candidates.clear(), throwsUnsupportedError);
    answers['q-001']!.add('opt-2');
    expect(result.candidates.first.confirmedQuestions, 1);
  });

  test('offline identification works using only supplied local rows', () {
    final result = SpeciesTraitsIdentificationEngine().identify(
      species: [plant('sp-001')],
      traits: [trait('st-001', 'sp-001', 'q-001', 'opt-fb-01')],
      answers: {
        'q-001': {'opt-fb-01'},
      },
    );
    expect(result.uniqueConfirmedMatch?.species.id, 'sp-001');
  });

  test(
    'comparison with existing substring filter uses explicit fixture values',
    () {
      final species = [
        plant('arbusto', biologicalForm: 'arbusto'),
        plant('subarbusto', biologicalForm: 'subarbusto'),
      ];
      final previous = SequentialQuestionnaire(
        allSpecies: species,
        photoParts: {},
        questions: [
          const QuestionConfig(
            id: 'q-001',
            text: 'Tipo',
            fieldName: 'biologicalForm',
            requiredPart: 'general',
            options: ['arbusto'],
          ),
        ],
      );
      previous.answer('arbusto');
      final alternative = SpeciesTraitsIdentificationEngine().identify(
        species: species,
        traits: [
          trait('1', 'arbusto', 'q-001', 'opt-fb-01'),
          trait('2', 'subarbusto', 'q-001', 'opt-fb-03'),
        ],
        answers: {
          'q-001': {'opt-fb-01'},
        },
      );
      final previousIds = previous.candidates.map((item) => item.id).toSet();
      final alternativeIds = alternative.candidates
          .map((item) => item.species.id)
          .toSet();
      expect(previousIds, {'arbusto', 'subarbusto'});
      expect(alternativeIds, {'arbusto'});
      expect(previousIds.difference(alternativeIds), {'subarbusto'});
    },
  );
}
