import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Datos semilla de plantas patagonicas para la base de datos local.
class SeedData {
  SeedData._();

  // IDs fijos para referenciar en traits
  static const String speciesMutisia = 'sp-001';
  static const String speciesCalafate = 'sp-002';
  static const String speciesNotro = 'sp-003';
  static const String speciesNeneo = 'sp-004';
  static const String speciesCoiron = 'sp-005';
  static const String speciesMichay = 'sp-006';

  // Question IDs
  static const String qColor = 'q-001';
  static const String qHabitat = 'q-002';
  static const String qSize = 'q-003';
  static const String qLeafType = 'q-004';

  // Option IDs - Color
  static const String optColorRojo = 'opt-c-001';
  static const String optColorNaranja = 'opt-c-002';
  static const String optColorAmarillo = 'opt-c-003';
  static const String optColorVioleta = 'opt-c-004';
  static const String optColorBlanco = 'opt-c-005';

  // Option IDs - Habitat
  static const String optHabitatEstepa = 'opt-h-001';
  static const String optHabitatBosque = 'opt-h-002';
  static const String optHabitatRocoso = 'opt-h-003';

  // Option IDs - Size
  static const String optSizeRastrero = 'opt-s-001';
  static const String optSizeArbusto = 'opt-s-002';
  static const String optSizeArbol = 'opt-s-003';
  static const String optSizeHierba = 'opt-s-004';

  // Option IDs - Leaf
  static const String optLeafEspinas = 'opt-l-001';
  static const String optLeafAncha = 'opt-l-002';
  static const String optLeafAguja = 'opt-l-003';
  static const String optLeafPequena = 'opt-l-004';

  static List<SpeciesCompanion> get speciesEntries => [
    SpeciesCompanion(
      id: const Value('sp-001'),
      commonName: const Value('Mutisia'),
      scientificName: const Value('Mutisia decurrens'),
      description: const Value(
        'Enredadera con flores anaranjadas grandes. Trepa por arbustos y arboles.',
      ),
      family: const Value('Asteraceae'),
      habitat: const Value('Bosque y estepa'),
      flowerColor: const Value('naranja'),
    ),
    SpeciesCompanion(
      id: const Value('sp-002'),
      commonName: const Value('Calafate'),
      scientificName: const Value('Berberis microphylla'),
      description: const Value(
        'Arbusto espinoso con flores amarillas pequenas y frutos violetas comestibles.',
      ),
      family: const Value('Berberidaceae'),
      habitat: const Value('Estepa'),
      flowerColor: const Value('amarillo'),
    ),
    SpeciesCompanion(
      id: const Value('sp-003'),
      commonName: const Value('Notro'),
      scientificName: const Value('Embothrium coccineum'),
      description: const Value(
        'Arbol o arbusto grande con flores rojas tubulares agrupadas.',
      ),
      family: const Value('Proteaceae'),
      habitat: const Value('Bosque'),
      flowerColor: const Value('rojo'),
    ),
    SpeciesCompanion(
      id: const Value('sp-004'),
      commonName: const Value('Neneo'),
      scientificName: const Value('Mulinum spinosum'),
      description: const Value(
        'Arbusto en cojin con espinas rigidas y flores amarillas pequenas.',
      ),
      family: const Value('Apiaceae'),
      habitat: const Value('Estepa'),
      flowerColor: const Value('amarillo'),
    ),
    SpeciesCompanion(
      id: const Value('sp-005'),
      commonName: const Value('Coiron amargo'),
      scientificName: const Value('Pappostipa speciosa'),
      description: const Value(
        'Hierba perenne en mata densa. Dominante en la estepa patagonica.',
      ),
      family: const Value('Poaceae'),
      habitat: const Value('Estepa'),
      flowerColor: const Value('blanco'),
    ),
    SpeciesCompanion(
      id: const Value('sp-006'),
      commonName: const Value('Michay'),
      scientificName: const Value('Berberis darwinii'),
      description: const Value(
        'Arbusto espinoso con flores naranjas colgantes y frutos azul oscuro.',
      ),
      family: const Value('Berberidaceae'),
      habitat: const Value('Bosque'),
      flowerColor: const Value('naranja'),
    ),
  ];

  static List<QuestionsCompanion> get questionEntries => [
    const QuestionsCompanion(
      id: Value('q-001'),
      questionText: Value('De que color predominante es la flor?'),
      orderIndex: Value(1),
    ),
    const QuestionsCompanion(
      id: Value('q-002'),
      questionText: Value('En que tipo de ambiente la encontraste?'),
      orderIndex: Value(2),
    ),
    const QuestionsCompanion(
      id: Value('q-003'),
      questionText: Value('Que tipo de planta es?'),
      orderIndex: Value(3),
    ),
    const QuestionsCompanion(
      id: Value('q-004'),
      questionText: Value('Como son las hojas?'),
      orderIndex: Value(4),
    ),
  ];

  static List<QuestionOptionsCompanion> get optionEntries => [
    // Color options
    const QuestionOptionsCompanion(
      id: Value('opt-c-001'),
      questionId: Value('q-001'),
      optionText: Value('Rojo / Escarlata'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-c-002'),
      questionId: Value('q-001'),
      optionText: Value('Naranja'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-c-003'),
      questionId: Value('q-001'),
      optionText: Value('Amarillo'),
      orderIndex: Value(3),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-c-004'),
      questionId: Value('q-001'),
      optionText: Value('Rosa / Violeta'),
      orderIndex: Value(4),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-c-005'),
      questionId: Value('q-001'),
      optionText: Value('Blanco'),
      orderIndex: Value(5),
    ),
    // Habitat options
    const QuestionOptionsCompanion(
      id: Value('opt-h-001'),
      questionId: Value('q-002'),
      optionText: Value('Estepa abierta'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-h-002'),
      questionId: Value('q-002'),
      optionText: Value('Bosque'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-h-003'),
      questionId: Value('q-002'),
      optionText: Value('Terreno rocoso'),
      orderIndex: Value(3),
    ),
    // Size options
    const QuestionOptionsCompanion(
      id: Value('opt-s-001'),
      questionId: Value('q-003'),
      optionText: Value('Rastrera / Enredadera'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-s-002'),
      questionId: Value('q-003'),
      optionText: Value('Arbusto'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-s-003'),
      questionId: Value('q-003'),
      optionText: Value('Arbol'),
      orderIndex: Value(3),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-s-004'),
      questionId: Value('q-003'),
      optionText: Value('Hierba / Pasto'),
      orderIndex: Value(4),
    ),
    // Leaf options
    const QuestionOptionsCompanion(
      id: Value('opt-l-001'),
      questionId: Value('q-004'),
      optionText: Value('Con espinas'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-l-002'),
      questionId: Value('q-004'),
      optionText: Value('Hojas anchas'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-l-003'),
      questionId: Value('q-004'),
      optionText: Value('Hojas tipo aguja'),
      orderIndex: Value(3),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-l-004'),
      questionId: Value('q-004'),
      optionText: Value('Hojas muy pequenas'),
      orderIndex: Value(4),
    ),
  ];

  static List<SpeciesTraitsCompanion> get traitEntries => [
    // Mutisia: naranja, bosque, enredadera, hojas anchas
    const SpeciesTraitsCompanion(
      id: Value('st-001'),
      speciesId: Value('sp-001'),
      questionId: Value('q-001'),
      optionId: Value('opt-c-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-002'),
      speciesId: Value('sp-001'),
      questionId: Value('q-002'),
      optionId: Value('opt-h-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-003'),
      speciesId: Value('sp-001'),
      questionId: Value('q-003'),
      optionId: Value('opt-s-001'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-004'),
      speciesId: Value('sp-001'),
      questionId: Value('q-004'),
      optionId: Value('opt-l-002'),
    ),
    // Calafate: amarillo, estepa, arbusto, espinas
    const SpeciesTraitsCompanion(
      id: Value('st-005'),
      speciesId: Value('sp-002'),
      questionId: Value('q-001'),
      optionId: Value('opt-c-003'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-006'),
      speciesId: Value('sp-002'),
      questionId: Value('q-002'),
      optionId: Value('opt-h-001'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-007'),
      speciesId: Value('sp-002'),
      questionId: Value('q-003'),
      optionId: Value('opt-s-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-008'),
      speciesId: Value('sp-002'),
      questionId: Value('q-004'),
      optionId: Value('opt-l-001'),
    ),
    // Notro: rojo, bosque, arbol, hojas anchas
    const SpeciesTraitsCompanion(
      id: Value('st-009'),
      speciesId: Value('sp-003'),
      questionId: Value('q-001'),
      optionId: Value('opt-c-001'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-010'),
      speciesId: Value('sp-003'),
      questionId: Value('q-002'),
      optionId: Value('opt-h-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-011'),
      speciesId: Value('sp-003'),
      questionId: Value('q-003'),
      optionId: Value('opt-s-003'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-012'),
      speciesId: Value('sp-003'),
      questionId: Value('q-004'),
      optionId: Value('opt-l-002'),
    ),
    // Neneo: amarillo, estepa, arbusto, aguja
    const SpeciesTraitsCompanion(
      id: Value('st-013'),
      speciesId: Value('sp-004'),
      questionId: Value('q-001'),
      optionId: Value('opt-c-003'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-014'),
      speciesId: Value('sp-004'),
      questionId: Value('q-002'),
      optionId: Value('opt-h-001'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-015'),
      speciesId: Value('sp-004'),
      questionId: Value('q-003'),
      optionId: Value('opt-s-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-016'),
      speciesId: Value('sp-004'),
      questionId: Value('q-004'),
      optionId: Value('opt-l-003'),
    ),
    // Coiron: blanco, estepa, hierba, aguja
    const SpeciesTraitsCompanion(
      id: Value('st-017'),
      speciesId: Value('sp-005'),
      questionId: Value('q-001'),
      optionId: Value('opt-c-005'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-018'),
      speciesId: Value('sp-005'),
      questionId: Value('q-002'),
      optionId: Value('opt-h-001'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-019'),
      speciesId: Value('sp-005'),
      questionId: Value('q-003'),
      optionId: Value('opt-s-004'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-020'),
      speciesId: Value('sp-005'),
      questionId: Value('q-004'),
      optionId: Value('opt-l-003'),
    ),
    // Michay: naranja, bosque, arbusto, espinas
    const SpeciesTraitsCompanion(
      id: Value('st-021'),
      speciesId: Value('sp-006'),
      questionId: Value('q-001'),
      optionId: Value('opt-c-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-022'),
      speciesId: Value('sp-006'),
      questionId: Value('q-002'),
      optionId: Value('opt-h-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-023'),
      speciesId: Value('sp-006'),
      questionId: Value('q-003'),
      optionId: Value('opt-s-002'),
    ),
    const SpeciesTraitsCompanion(
      id: Value('st-024'),
      speciesId: Value('sp-006'),
      questionId: Value('q-004'),
      optionId: Value('opt-l-001'),
    ),
  ];
}
