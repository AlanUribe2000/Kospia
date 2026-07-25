import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Datos semilla de 79 plantas patagónicas para la base de datos local.
/// Sistema de identificación dinámico basado en traits discriminantes.
class SeedData {
  SeedData._();

  // --- Question IDs ---
  static const String qFormaBiologica = 'q-001';
  static const String qColorFlor = 'q-002';
  static const String qEspinas = 'q-003';
  static const String qAgrupacionFlor = 'q-004';
  static const String qAltura = 'q-005';
  static const String qFrutoVisible = 'q-006';
  static const String qFormaHoja = 'q-007';

  // --- Option IDs - Forma biológica ---
  static const String optArbusto = 'opt-fb-01';
  static const String optHierba = 'opt-fb-02';
  static const String optSubarbusto = 'opt-fb-03';
  static const String optSubarbustoSuculento = 'opt-fb-04';
  static const String optHierbaSuculenta = 'opt-fb-05';

  // --- Option IDs - Color flor ---
  static const String optFlorAmarillo = 'opt-cf-01';
  static const String optFlorBlanco = 'opt-cf-02';
  static const String optFlorRojizo = 'opt-cf-03';
  static const String optFlorVioleta = 'opt-cf-04';
  static const String optFlorRosa = 'opt-cf-05';
  static const String optFlorNaranja = 'opt-cf-06';
  static const String optFlorCrema = 'opt-cf-07';
  static const String optFlorVerde = 'opt-cf-08';

  // --- Option IDs - Espinas ---
  static const String optConEspinas = 'opt-es-01';
  static const String optSinEspinas = 'opt-es-02';

  // --- Option IDs - Agrupación flor ---
  static const String optIndividual = 'opt-ag-01';
  static const String optInflorescencia = 'opt-ag-02';
  static const String optCono = 'opt-ag-03';

  // --- Option IDs - Altura ---
  static const String optMuyBaja = 'opt-al-01';
  static const String optBaja = 'opt-al-02';
  static const String optMedia = 'opt-al-03';
  static const String optAlta = 'opt-al-04';

  // --- Option IDs - Fruto visible ---
  static const String optFrutoSi = 'opt-fr-01';
  static const String optFrutoNo = 'opt-fr-02';

  // --- Option IDs - Forma hoja ---
  static const String optHojaLinear = 'opt-fh-01';
  static const String optHojaEliptica = 'opt-fh-02';
  static const String optHojaCompuesta = 'opt-fh-03';
  static const String optHojaLanceolada = 'opt-fh-04';
  static const String optHojaEspatulada = 'opt-fh-05';
  static const String optHojaAcicular = 'opt-fh-06';
  static const String optHojaOtras = 'opt-fh-07';

  // ============================
  // QUESTIONS
  // ============================
  static List<QuestionsCompanion> get questionEntries => [
    const QuestionsCompanion(
      id: Value('q-001'),
      questionText: Value('¿Qué tipo de planta es?'),
      orderIndex: Value(1),
    ),
    const QuestionsCompanion(
      id: Value('q-002'),
      questionText: Value('¿De qué color es la flor?'),
      orderIndex: Value(2),
    ),
    const QuestionsCompanion(
      id: Value('q-003'),
      questionText: Value('¿Tiene espinas?'),
      orderIndex: Value(3),
    ),
    const QuestionsCompanion(
      id: Value('q-004'),
      questionText: Value('¿Las flores están agrupadas o son individuales?'),
      orderIndex: Value(4),
    ),
    const QuestionsCompanion(
      id: Value('q-005'),
      questionText: Value('¿Qué altura tiene aproximadamente?'),
      orderIndex: Value(5),
    ),
    const QuestionsCompanion(
      id: Value('q-006'),
      questionText: Value('¿Se ven frutos?'),
      orderIndex: Value(6),
    ),
    const QuestionsCompanion(
      id: Value('q-007'),
      questionText: Value('¿Cómo son las hojas?'),
      orderIndex: Value(7),
    ),
  ];

  // ============================
  // OPTIONS
  // ============================
  static List<QuestionOptionsCompanion> get optionEntries => [
    // Forma biológica
    const QuestionOptionsCompanion(
      id: Value('opt-fb-01'),
      questionId: Value('q-001'),
      optionText: Value('Arbusto'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fb-02'),
      questionId: Value('q-001'),
      optionText: Value('Hierba'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fb-03'),
      questionId: Value('q-001'),
      optionText: Value('Subarbusto'),
      orderIndex: Value(3),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fb-04'),
      questionId: Value('q-001'),
      optionText: Value('Subarbusto suculento'),
      orderIndex: Value(4),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fb-05'),
      questionId: Value('q-001'),
      optionText: Value('Hierba suculenta'),
      orderIndex: Value(5),
    ),
    // Color flor
    const QuestionOptionsCompanion(
      id: Value('opt-cf-01'),
      questionId: Value('q-002'),
      optionText: Value('Amarillo'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-cf-02'),
      questionId: Value('q-002'),
      optionText: Value('Blanco'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-cf-03'),
      questionId: Value('q-002'),
      optionText: Value('Rojo / Rojizo'),
      orderIndex: Value(3),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-cf-04'),
      questionId: Value('q-002'),
      optionText: Value('Violeta'),
      orderIndex: Value(4),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-cf-05'),
      questionId: Value('q-002'),
      optionText: Value('Rosa'),
      orderIndex: Value(5),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-cf-06'),
      questionId: Value('q-002'),
      optionText: Value('Naranja'),
      orderIndex: Value(6),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-cf-07'),
      questionId: Value('q-002'),
      optionText: Value('Crema'),
      orderIndex: Value(7),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-cf-08'),
      questionId: Value('q-002'),
      optionText: Value('Verde'),
      orderIndex: Value(8),
    ),
    // Espinas
    const QuestionOptionsCompanion(
      id: Value('opt-es-01'),
      questionId: Value('q-003'),
      optionText: Value('Sí, tiene espinas'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-es-02'),
      questionId: Value('q-003'),
      optionText: Value('No tiene espinas'),
      orderIndex: Value(2),
    ),
    // Agrupación
    const QuestionOptionsCompanion(
      id: Value('opt-ag-01'),
      questionId: Value('q-004'),
      optionText: Value('Flores individuales'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-ag-02'),
      questionId: Value('q-004'),
      optionText: Value('Inflorescencia (agrupadas)'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-ag-03'),
      questionId: Value('q-004'),
      optionText: Value('Cono'),
      orderIndex: Value(3),
    ),
    // Altura
    const QuestionOptionsCompanion(
      id: Value('opt-al-01'),
      questionId: Value('q-005'),
      optionText: Value('Muy baja (< 30 cm)'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-al-02'),
      questionId: Value('q-005'),
      optionText: Value('Baja (30–60 cm)'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-al-03'),
      questionId: Value('q-005'),
      optionText: Value('Media (60 cm – 1 m)'),
      orderIndex: Value(3),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-al-04'),
      questionId: Value('q-005'),
      optionText: Value('Alta (más de 1 m)'),
      orderIndex: Value(4),
    ),
    // Fruto
    const QuestionOptionsCompanion(
      id: Value('opt-fr-01'),
      questionId: Value('q-006'),
      optionText: Value('Sí, se ven frutos'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fr-02'),
      questionId: Value('q-006'),
      optionText: Value('No se ven frutos'),
      orderIndex: Value(2),
    ),
    // Forma hoja
    const QuestionOptionsCompanion(
      id: Value('opt-fh-01'),
      questionId: Value('q-007'),
      optionText: Value('Lineares / alargadas'),
      orderIndex: Value(1),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fh-02'),
      questionId: Value('q-007'),
      optionText: Value('Elípticas / ovaladas'),
      orderIndex: Value(2),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fh-03'),
      questionId: Value('q-007'),
      optionText: Value('Compuestas / divididas'),
      orderIndex: Value(3),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fh-04'),
      questionId: Value('q-007'),
      optionText: Value('Lanceoladas'),
      orderIndex: Value(4),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fh-05'),
      questionId: Value('q-007'),
      optionText: Value('Espatuladas / redondeadas'),
      orderIndex: Value(5),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fh-06'),
      questionId: Value('q-007'),
      optionText: Value('Aciculares / tipo aguja'),
      orderIndex: Value(6),
    ),
    const QuestionOptionsCompanion(
      id: Value('opt-fh-07'),
      questionId: Value('q-007'),
      optionText: Value('Otras / sin hojas típicas'),
      orderIndex: Value(7),
    ),
  ];

  // ============================
  // SPECIES (79 plantas)
  // ============================
  static List<SpeciesCompanion> get speciesEntries => [
    _sp(
      'sp-001',
      'Calafate',
      'Berberis microphylla',
      'Berberidaceae',
      'Arbusto espinoso con flores amarillas y frutos azul oscuro comestibles.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'elíptica',
      leafEdge: 'espinoso',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'foliares/trífidas',
      flowerGrouping: 'individual',
      petalCount: '6',
      flowerSize: 'mediana',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'azul oscuro',
      fruitSize: 'pequeño',
      observations: 'comestible',
    ),
    _sp(
      'sp-002',
      'Neneo',
      'Azorella prolifera',
      'Apiaceae',
      'Arbusto con hojas triangulares tripartidas y flores amarillas.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'mediana',
      leafShape: 'triangulares/tripartidas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'ovoide/alado',
      fruitColor: 'rojizo',
      fruitSize: 'muy pequeño',
      observations: 'aroma fuerte',
    ),
    _sp(
      'sp-003',
      'Duraznillo',
      'Colliguaja integerrima',
      'Euphorbiaceae',
      'Arbusto con inflorescencias rojizas y látex.',
      'rojizo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'grande',
      leafShape: 'lanceoladas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'globoso/trilobulado',
      fruitColor: 'rojizo-amarronado',
      fruitSize: 'mediano',
      observations: 'látex',
    ),
    _sp(
      'sp-004',
      'Malaspina',
      'Retanilla patagonica',
      'Rhamnaceae',
      'Arbusto espinoso ramoso con flores blanco/crema y fruto verde.',
      'blanco/crema',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'firme',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: '4',
      flowerSize: 'pequeñas',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'verde',
      fruitSize: 'pequeño',
      observations: 'ramoso',
    ),
    _sp(
      'sp-005',
      'Lechetrés',
      'Euphorbia portulacoides',
      'Euphorbiaceae',
      'Hierba baja con inflorescencias verdes y látex.',
      'verde',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'globoso/trilobulado',
      fruitColor: 'verde-rojizo',
      fruitSize: 'muy pequeño',
      observations: 'látex',
    ),
    _sp(
      'sp-006',
      'Quilembay',
      'Chiquiraga avellanedae',
      'Asteraceae',
      'Arbusto espinoso con inflorescencias amarillo/naranja grandes.',
      'amarillo/naranja',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña/mediana',
      leafShape: 'lanceoladas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'foliares/cortas',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'piloso',
      fruitColor: 'blanco-grisáceo',
      fruitSize: 'mediano',
      observations: '',
    ),
    _sp(
      'sp-007',
      'Uña de gato',
      'Chuquiraga aurea',
      'Asteraceae',
      'Arbusto bajo con hojas aciculares y flores amarillas.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'pequeña',
      leafShape: 'acicular',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'piloso',
      fruitColor: 'blanco-grisáceo',
      fruitSize: 'mediano',
      observations: '',
    ),
    _sp(
      'sp-008',
      'Verbena',
      'Mulguraea ligustrina',
      'Vebenaceae',
      'Arbusto aromático con flores crema individuales.',
      'crema',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'elíptica/oblonga',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cilíndrico',
      fruitColor: 'castaño-pardo',
      fruitSize: 'pequeño',
      observations: 'aromática',
    ),
    _sp(
      'sp-009',
      'Botón de oro',
      'Grindelia chiloensis',
      'Asteraceae',
      'Subarbusto resinoso con inflorescencias amarillas grandes.',
      'amarillo',
      biologicalForm: 'subarbusto',
      approximateHeight: 'media',
      leafLength: 'grande',
      leafShape: 'oblanceolada',
      leafEdge: 'aserrado',
      leafTexture: 'pegajosa',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: false,
      fruitShape: 'elipsoide/alado',
      fruitColor: 'castaño-pardo',
      fruitSize: 'mediano',
      observations: 'resinosa',
    ),
    _sp(
      'sp-010',
      'Yao-yín',
      'Lycium chilense',
      'Solanaceae',
      'Arbusto con flores blanco/violáceo y frutos rojos comestibles.',
      'blanco/violáceo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'blanda/carnosa',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'muy pequeña/pequeña',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'rojizo',
      fruitSize: 'pequeño',
      observations: 'comestible',
    ),
    _sp(
      'sp-011',
      'Molle',
      'Schinus johnstonii',
      'Anacardiaceae',
      'Arbusto con ramas espinosas, flores amarillas y fruto azul oscuro.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'muy pequeña',
      leafShape: 'obovada/espatulada',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'ramas espinosas',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'globoso',
      fruitColor: 'azul oscuro',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-012',
      'Falso tomillo',
      'Frankenia patagonica',
      'Frankeniaceae',
      'Arbusto bajo halofítico con flores blanco/violáceo.',
      'blanco/violáceo',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'muy pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'muy pequeña',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'halofítica',
    ),
    _sp(
      'sp-013',
      'Zampa',
      'Atriplex lampa',
      'Amaranthaceae',
      'Subarbusto halofítico forrajero con flores amarillo/rojiza.',
      'amarillo/rojiza',
      biologicalForm: 'subarbusto',
      approximateHeight: 'alta',
      leafLength: 'mediana',
      leafShape: 'triangulares',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'utrículo',
      fruitColor: 'grisáceo',
      fruitSize: 'muy pequeño',
      observations: 'halofítica/forrajera',
    ),
    _sp(
      'sp-014',
      'Tomillo rosa',
      'Pleurophora patagonica',
      'Lythraceaae',
      'Arbusto bajo con flores rosas individuales.',
      'rosa',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'muy pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '6',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-015',
      'Violeta de campo',
      'Astragalus cruckshanskii',
      'Fabacae',
      'Hierba con flores violetas y fruto tipo legumbre.',
      'violeta',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'mediana',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-016',
      'Cerastio',
      'Cerastium arvense',
      'Caryophyllaceae',
      'Hierba baja con flores blancas de 5 pétalos.',
      'blanco',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'lanceoladas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-017',
      'Zapato de reina',
      'Calceolaria polyrhiza',
      'Calceolariaceae',
      'Hierba baja con flores amarillas bilabiadas.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'espatulada',
      leafEdge: 'crenado',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '2',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-018',
      'Pata de perdiz',
      'Hoffmannseggia trifoliata',
      'Fabacae',
      'Hierba baja con flores naranja/rojizo y fruto legumbre.',
      'naranja/rojizo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-019',
      'Mata fuego',
      'Anarthrophyllum desiderata',
      'Fabacae',
      'Subarbusto espinoso con flores rojizas.',
      'rojizo',
      biologicalForm: 'subarbusto',
      approximateHeight: 'media',
      leafLength: 'pequeña',
      leafShape: 'trifoliadas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'espinoso',
    ),
    _sp(
      'sp-020',
      'Marancel',
      'Olsynium junceum',
      'Iridaceae',
      'Hierba bulbosa con hojas lineares y flores blancas de 6 pétalos.',
      'blanco',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '6',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'bulbosa',
    ),
    _sp(
      'sp-021',
      'Yuyo moro',
      'Senecio filaginoides',
      'Asteraceae',
      'Arbusto aromático con inflorescencias amarillas y hojas lineares.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'mediana',
      leafShape: 'lineares/filiformes',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'aromática',
    ),
    _sp(
      'sp-022',
      'Coirón duro',
      'Pappostipa speciosa',
      'Poaceae',
      'Hierba perenne forrajera dominante en estepa patagónica.',
      'verde/violáceo',
      biologicalForm: 'hierba',
      approximateHeight: 'media',
      leafLength: 'muy grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'rígida',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cariopse',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'forrajera',
    ),
    _sp(
      'sp-023',
      'Coirón llama',
      'Pappostipa humilis',
      'Poaceae',
      'Hierba forrajera baja de la estepa.',
      'verde/violáceo',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cariopse',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'forrajera',
    ),
    _sp(
      'sp-024',
      'Coirón poa',
      'Poa ligularis',
      'Poaceae',
      'Hierba forrajera de hojas lineares flexibles.',
      'verde/violáceo',
      biologicalForm: 'hierba',
      approximateHeight: 'media',
      leafLength: 'grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cariopse',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'forrajera',
    ),
    _sp(
      'sp-025',
      'Coirón pluma',
      'Pappostipa neaei',
      'Poaceae',
      'Hierba con arista plumosa característica.',
      'verde/púrpura-rojizo',
      biologicalForm: 'hierba',
      approximateHeight: 'media',
      leafLength: 'muy grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cariopse',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'arista plumosa',
    ),
    _sp(
      'sp-026',
      'Tomillo de campo',
      'Troncosoa seriphioides',
      'Vebenaceae',
      'Arbusto bajo aromático con flores blancas pequeñas.',
      'blanco',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'muy pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'esquizocarpo',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'aromática',
    ),
    _sp(
      'sp-027',
      'Mata laguna',
      'Lycium ameghinoi',
      'Solanaceae',
      'Arbusto con espinas caulinares y frutos rojizos esféricos.',
      'blanco/violáceo',
      biologicalForm: 'arbusto',
      approximateHeight: 'media',
      leafLength: 'pequeña',
      leafShape: 'espatulada',
      leafEdge: 'entero',
      leafTexture: 'blanda/carnosa',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'rojizo',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-028',
      'Solupe grueso',
      'Ephedra ochreata',
      'Ephedraceae',
      'Arbusto áfilo articulado con conos y frutos rojizos.',
      'amarillo/verdoso',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'muy pequeña',
      leafShape: 'escamiformes',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'cono',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'pequeñas',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'rojizo',
      fruitSize: 'pequeño',
      observations: 'áfilo/articulado',
    ),
    _sp(
      'sp-029',
      'Barba de chivo',
      'Prosopidastrum globosum',
      'Fabacae',
      'Arbusto espinoso con flores amarillas y legumbre.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'compuestas/bipinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: 'muchos',
      flowerSize: 'pequeñas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'espinoso',
    ),
    _sp(
      'sp-030',
      'Vidriera',
      'Suaeda divaricata',
      'Amaranthaceae',
      'Arbusto halofítico suculento con hojas cilíndricas.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'lineares/cilíndricas',
      leafEdge: 'entero',
      leafTexture: 'carnosa',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'muy pequeña',
      hasFruit: false,
      fruitShape: 'utrículo',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'halofítica/suculenta',
    ),
    _sp(
      'sp-031',
      'Jazmín de campo',
      'Menodora robusta',
      'Oleaceae',
      'Subarbusto con flores amarillas de 5 pétalos.',
      'amarillo',
      biologicalForm: 'subarbusto',
      approximateHeight: 'baja',
      leafLength: 'pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-032',
      'Algarrobillo patagónico',
      'Neltuma denudans',
      'Fabacae',
      'Arbusto espinoso con flores amarillas y legumbre.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'muy pequeña',
      leafShape: 'compuestas/bipinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: 'muchos',
      flowerSize: 'pequeñas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'espinoso',
    ),
    _sp(
      'sp-033',
      'Cactus patagónico',
      'Austrocactus bertinii',
      'Cactaceae',
      'Subarbusto suculento con flores rosas grandes y espinas areolares.',
      'rosa',
      biologicalForm: 'subarbusto suculento',
      approximateHeight: 'baja',
      leafLength: 'sin hojas',
      leafShape: 'sin hojas típicas',
      leafEdge: 'sin hojas',
      leafTexture: 'carnosa',
      hasSpines: true,
      spineType: 'areolares',
      flowerGrouping: 'individual',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'verde-rojizo',
      fruitSize: 'mediano',
      observations: 'suculenta',
    ),
    _sp(
      'sp-034',
      'Tuna',
      'Maihueniopsis darwinii',
      'Cactaceae',
      'Subarbusto suculento con cladodios aplanados y flores naranjas.',
      'naranja',
      biologicalForm: 'subarbusto suculento',
      approximateHeight: 'muy baja',
      leafLength: 'sin hojas',
      leafShape: 'cladodios/aplanados',
      leafEdge: 'sin hojas',
      leafTexture: 'carnosa',
      hasSpines: true,
      spineType: 'areolares',
      flowerGrouping: 'individual',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'verde-rojizo',
      fruitSize: 'mediano',
      observations: 'suculenta',
    ),
    _sp(
      'sp-035',
      'Chupasangre',
      'Maihuenia patagonica',
      'Cactaceae',
      'Subarbusto suculento en cojín con flores blanco/rosado.',
      'blanco/rosado',
      biologicalForm: 'subarbusto suculento',
      approximateHeight: 'muy baja',
      leafLength: 'muy pequeña',
      leafShape: 'cilíndrica',
      leafEdge: 'sin hojas',
      leafTexture: 'carnosa',
      hasSpines: true,
      spineType: 'areolares',
      flowerGrouping: 'individual',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'verde',
      fruitSize: 'mediano',
      observations: 'suculenta/cojín',
    ),
    _sp(
      'sp-036',
      'Clavel de campo',
      'Mutisia retrorsa',
      'Asteraceae',
      'Subarbusto trepador con inflorescencias naranjas grandes.',
      'naranja',
      biologicalForm: 'subarbusto',
      approximateHeight: 'media',
      leafLength: 'grande',
      leafShape: 'lanceoladas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'mediano',
      observations: 'trepadora',
    ),
    _sp(
      'sp-037',
      'Mamuel choique',
      'Adesmia volckmannii',
      'Fabacae',
      'Arbusto espinoso con flores amarillas y legumbre.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'espinoso',
    ),
    _sp(
      'sp-038',
      'Adesmia candida',
      'Adesmia candida',
      'Fabacae',
      'Subarbusto con flores amarillas y legumbre.',
      'amarillo',
      biologicalForm: 'subarbusto',
      approximateHeight: 'baja',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-039',
      'Mata guanaco',
      'Nardophyllum bryoides',
      'Asteraceae',
      'Arbusto resinoso con inflorescencias amarillas.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'media',
      leafLength: 'muy pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'resinosa',
    ),
    _sp(
      'sp-040',
      'Tolilla',
      'Fabiana patagonica',
      'Solanaceae',
      'Arbusto aromático con hojas escamiformes y flores crema.',
      'crema',
      biologicalForm: 'arbusto',
      approximateHeight: 'media',
      leafLength: 'muy pequeña',
      leafShape: 'escamiformes',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'aromática',
    ),
    _sp(
      'sp-041',
      'Junelia',
      'Junellia tridactylites',
      'Vebenaceae',
      'Arbusto bajo con hojas tripartidas y flores blanco/violáceo.',
      'blanco/violáceo',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'muy pequeña',
      leafShape: 'tripartidas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'esquizocarpo',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-042',
      'Neneo rosa',
      'Junellia tonini',
      'Vebenaceae',
      'Arbusto bajo espinoso en cojín con flores blanco/violáceo.',
      'blanco/violáceo',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'muy pequeña',
      leafShape: 'elíptica',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'esquizocarpo',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'cojín espinoso',
    ),
    _sp(
      'sp-043',
      'Manca perro',
      'Nassauvia ulicina',
      'Asteraceae',
      'Arbusto bajo con hojas aciculares espinosas e inflorescencias blancas.',
      'blanco',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'muy pequeña',
      leafShape: 'acicular',
      leafEdge: 'espinoso',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'foliares',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-044',
      'Molle colorado',
      'Schinus marchandii',
      'Anacardiaceae',
      'Arbusto con ramas espinosas, flores amarillas y fruto rojizo.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'pequeña',
      leafShape: 'obovada',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'ramas espinosas',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'globoso',
      fruitColor: 'rojizo',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-045',
      'Chilca',
      'Baccharis darwinii',
      'Asteraceae',
      'Subarbusto dioico con inflorescencias crema muy pequeñas.',
      'crema',
      biologicalForm: 'subarbusto',
      approximateHeight: 'media',
      leafLength: 'pequeña',
      leafShape: 'espatulada',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'muy pequeña',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'blanco',
      fruitSize: 'muy pequeño',
      observations: 'dioica',
    ),
    _sp(
      'sp-046',
      'Caulia',
      'Tetraglochin alatum',
      'Rosaceae',
      'Arbusto bajo con espinas foliares y flores rojas.',
      'rojo',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'muy pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'foliares',
      flowerGrouping: 'individual',
      petalCount: '4',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'aquenio/alado',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-047',
      'Yerba de la perdiz',
      'Tetraglochin caespitosa',
      'Rosaceae',
      'Arbusto en cojín con espinas foliares y flores rojas.',
      'rojo',
      biologicalForm: 'arbusto',
      approximateHeight: 'muy baja',
      leafLength: 'muy pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'foliares',
      flowerGrouping: 'individual',
      petalCount: '4',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'aquenio/alado',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'cojín',
    ),
    _sp(
      'sp-048',
      'Yareta',
      'Brachyclados caespitosus',
      'Asteraceae',
      'Arbusto en cojín con inflorescencias amarillas.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'muy baja',
      leafLength: 'muy pequeña',
      leafShape: 'espatulada',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'cojín',
    ),
    _sp(
      'sp-049',
      'Cadillo',
      'Acaena poeppigiana',
      'Rosaceae',
      'Hierba rastrera con espinas tipo glochidia y flores rojas.',
      'rojo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'aserrado',
      leafTexture: 'flexible',
      hasSpines: true,
      spineType: 'foliares/glochidia',
      flowerGrouping: 'inflorescencia',
      petalCount: '4',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'aquenio/espinoso',
      fruitColor: 'rojizo',
      fruitSize: 'pequeño',
      observations: 'dispersión zoócora',
    ),
    _sp(
      'sp-050',
      'Abrojo',
      'Acaena splendens',
      'Rosaceae',
      'Hierba con hojas plateadas, espinas glochidia y flores rojas.',
      'rojo',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'mediana',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'aserrado',
      leafTexture: 'flexible',
      hasSpines: true,
      spineType: 'foliares/glochidia',
      flowerGrouping: 'inflorescencia',
      petalCount: '4',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'aquenio/espinoso',
      fruitColor: 'rojizo',
      fruitSize: 'pequeño',
      observations: 'hojas plateadas',
    ),
    _sp(
      'sp-051',
      'Abrojo cojín',
      'Acaena caespitosa',
      'Rosaceae',
      'Hierba en cojín con espinas glochidia y flores rojas.',
      'rojo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'aserrado',
      leafTexture: 'flexible',
      hasSpines: true,
      spineType: 'foliares/glochidia',
      flowerGrouping: 'inflorescencia',
      petalCount: '4',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'aquenio/espinoso',
      fruitColor: 'rojizo',
      fruitSize: 'pequeño',
      observations: 'cojín',
    ),
    _sp(
      'sp-052',
      'Ameginoa',
      'Ameghinoa patagonica',
      'Asteraceae',
      'Arbusto bajo endémico con inflorescencias amarillas grandes.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'mediana',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'mediano',
      observations: 'endémica',
    ),
    _sp(
      'sp-053',
      'Hierba salada',
      'Salicornia neei',
      'Amaranthaceae',
      'Arbusto halofítico suculento sin hojas típicas.',
      'rojizo',
      biologicalForm: 'arbusto',
      approximateHeight: 'baja',
      leafLength: 'sin hojas',
      leafShape: 'escamiformes/suculentas',
      leafEdge: 'sin hojas',
      leafTexture: 'carnosa',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'muy pequeña',
      hasFruit: false,
      fruitShape: 'utrículo',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'halofítica/suculenta',
    ),
    _sp(
      'sp-054',
      'Zampa sagitada',
      'Atriplex sagittifolia',
      'Amaranthaceae',
      'Arbusto halofítico con hojas sagitadas.',
      'amarillo/rojiza',
      biologicalForm: 'arbusto',
      approximateHeight: 'alta',
      leafLength: 'mediana',
      leafShape: 'sagitadas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'muy pequeña',
      hasFruit: true,
      fruitShape: 'utrículo',
      fruitColor: 'grisáceo',
      fruitSize: 'muy pequeño',
      observations: 'halofítica',
    ),
    _sp(
      'sp-055',
      'Macachín',
      'Arjona tuberosa',
      'Schoepfiaceae',
      'Hierba parásita con raíz comestible y flores blancas.',
      'blanco',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'drupa',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'parásita/raíz comestible',
    ),
    _sp(
      'sp-056',
      'Llantén',
      'Plantago patagonica',
      'Plantaginaceae',
      'Hierba baja con hojas lineares y flores blancas diminutas.',
      'blanco',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '4',
      flowerSize: 'muy pequeña',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-057',
      'Don Diego de noche',
      'Oenothera odorata',
      'Onagraceae',
      'Hierba con flores amarillas grandes aromáticas nocturnas.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'grande',
      leafShape: 'lanceoladas',
      leafEdge: 'dentado',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '4',
      flowerSize: 'grandes',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'mediano',
      observations: 'aromática nocturna',
    ),
    _sp(
      'sp-058',
      'Sibara',
      'Sibara tehuelches',
      'Brassicaceae',
      'Subarbusto bajo con flores crema de 4 pétalos.',
      'crema',
      biologicalForm: 'subarbusto',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '4',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'silicua',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-059',
      'Cebadilla patagónica',
      'Bromus setifolius',
      'Poaceae',
      'Hierba forrajera con inflorescencia verde/violáceo.',
      'verde/violáceo',
      biologicalForm: 'hierba',
      approximateHeight: 'media',
      leafLength: 'grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cariopse',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'forrajera',
    ),
    _sp(
      'sp-060',
      'Flechilla',
      'Nassella tenuis',
      'Poaceae',
      'Hierba forrajera con inflorescencia blanco/violáceo.',
      'blanco/violáceo',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'sin pétalos visibles',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cariopse',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'forrajera',
    ),
    _sp(
      'sp-061',
      'Estrellita de campo',
      'Tristagma patagonicum',
      'Amaryllidaceae',
      'Hierba bulbosa con flores blancas de 6 pétalos.',
      'blanco',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '6',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'bulbosa',
    ),
    _sp(
      'sp-062',
      'Cebollín',
      'Tristagma nivale',
      'Amaryllidaceae',
      'Hierba bulbosa con flores verdes de 6 pétalos.',
      'verde',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '6',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'bulbosa',
    ),
    _sp(
      'sp-063',
      'Pterocactus',
      'Pterocactus hickenii',
      'Cactaceae',
      'Hierba suculenta con raíz tuberosa y flores naranjas.',
      'naranja',
      biologicalForm: 'hierba suculenta',
      approximateHeight: 'muy baja',
      leafLength: 'sin hojas',
      leafShape: 'sin hojas típicas',
      leafEdge: 'sin hojas',
      leafTexture: 'carnosa',
      hasSpines: true,
      spineType: 'areolares',
      flowerGrouping: 'individual',
      petalCount: 'muchos',
      flowerSize: 'grandes',
      hasFruit: true,
      fruitShape: 'esférico',
      fruitColor: 'verde',
      fruitSize: 'mediano',
      observations: 'suculenta/raíz tuberosa',
    ),
    _sp(
      'sp-064',
      'Boopis',
      'Xiphodesma anthemoides',
      'Calyceraceae',
      'Hierba baja con flores blancas de 5 pétalos.',
      'blanco',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'lineares/pinnatífidas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'aquenio',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-065',
      'Azucena de campo',
      'Zephyranthes gilliesiana',
      'Amaryllidaceae',
      'Hierba bulbosa con flores amarillo/naranja de 6 pétalos.',
      'amarillo/naranja',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'grande',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '6',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'bulbosa',
    ),
    _sp(
      'sp-066',
      'Monjita',
      'Pinnasa bergii',
      'Loasaceae',
      'Hierba con pelos urticantes y flores amarillas.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'lobuladas',
      leafEdge: 'dentado',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'pelos urticantes',
    ),
    _sp(
      'sp-067',
      'Flor de la cuncuna',
      'Phacelia secunda',
      'Hydrophyllaceae',
      'Hierba con flores blanco/violeta y hojas compuestas.',
      'blanco/violeta',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'mediana',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'dentado',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-068',
      'Perezia',
      'Perezia recurvata',
      'Asteraceae',
      'Hierba con roseta basal espinosa e inflorescencias crema.',
      'crema',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'grande',
      leafShape: 'roseta/oblanceolada',
      leafEdge: 'espinoso',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'foliares',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-069',
      'Camisonia',
      'Camissonia dentata',
      'Onagraceae',
      'Hierba baja con flores amarillas de 4 pétalos.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'lanceoladas',
      leafEdge: 'dentado',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '4',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-070',
      'Rueda chica',
      'Microsteris gracilis',
      'Polemoniaceae',
      'Hierba anual diminuta con flores violetas.',
      'violeta',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'lineares',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'muy pequeña',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'anual',
    ),
    _sp(
      'sp-071',
      'Ortiga de campo',
      'Amsinckia calycina',
      'Boraginaceae',
      'Hierba con flores amarillas pequeñas.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'mediana',
      leafShape: 'lanceoladas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'núcula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: '',
    ),
    _sp(
      'sp-072',
      'Adesmia villosa',
      'Adesmia villosa',
      'Fabacae',
      'Hierba con pelos y flores amarillas, fruto legumbre.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-073',
      'Yramea',
      'Adesmia corymbosa',
      'Fabacae',
      'Hierba con flores amarillas y fruto legumbre.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-074',
      'Cuerno de cabra',
      'Adesmia salamancensis',
      'Fabacae',
      'Arbusto espinoso con flores amarillas y legumbre.',
      'amarillo',
      biologicalForm: 'arbusto',
      approximateHeight: 'media',
      leafLength: 'pequeña',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: true,
      spineType: 'caulinares',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: true,
      fruitShape: 'legumbre',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'espinoso',
    ),
    _sp(
      'sp-075',
      'Guaycurú',
      'Limonium brasiliense',
      'Plumbaginaceae',
      'Hierba halofítica con roseta y flores blancas.',
      'blanco',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'grande',
      leafShape: 'espatulada/roseta',
      leafEdge: 'entero',
      leafTexture: 'coriácea',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'muy pequeño',
      observations: 'halofítica',
    ),
    _sp(
      'sp-076',
      'Campana de convento',
      'Gilia crassifolia',
      'Polemoniaceae',
      'Hierba baja con flores violetas medianas.',
      'violeta',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'cápsula',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: '',
    ),
    _sp(
      'sp-077',
      'Duseniela',
      'Duseniella patagonica',
      'Asteraceae',
      'Hierba endémica con roseta e inflorescencias amarillas.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'grande',
      leafShape: 'roseta/oblanceolada',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'inflorescencia',
      petalCount: 'muchos',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'aquenio/piloso',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'endémica',
    ),
    _sp(
      'sp-078',
      'Alfilerillo',
      'Erodium cicutarium',
      'Geraniaceae',
      'Hierba introducida con flores violetas y hojas compuestas.',
      'violeta',
      biologicalForm: 'hierba',
      approximateHeight: 'muy baja',
      leafLength: 'mediana',
      leafShape: 'compuestas/pinnadas',
      leafEdge: 'dentado',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'pequeñas',
      hasFruit: false,
      fruitShape: 'esquizocarpo',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'introducida',
    ),
    _sp(
      'sp-079',
      'Magallana',
      'Tropaeolum porifolium',
      'Tropaeolaceae',
      'Hierba trepadora tuberosa con flores amarillas.',
      'amarillo',
      biologicalForm: 'hierba',
      approximateHeight: 'baja',
      leafLength: 'grande',
      leafShape: 'redondeada/peltada',
      leafEdge: 'entero',
      leafTexture: 'flexible',
      hasSpines: false,
      spineType: '',
      flowerGrouping: 'individual',
      petalCount: '5',
      flowerSize: 'medianas',
      hasFruit: false,
      fruitShape: 'esquizocarpo',
      fruitColor: 'castaño',
      fruitSize: 'pequeño',
      observations: 'trepadora/tuberosa',
    ),
  ];

  static SpeciesCompanion _sp(
    String id,
    String common,
    String scientific,
    String family,
    String desc,
    String color, {
    String biologicalForm = '',
    String approximateHeight = '',
    String leafLength = '',
    String leafShape = '',
    String leafEdge = '',
    String leafTexture = '',
    bool hasSpines = false,
    String spineType = '',
    String flowerGrouping = '',
    String petalCount = '',
    String flowerSize = '',
    bool hasFruit = false,
    String fruitShape = '',
    String fruitColor = '',
    String fruitSize = '',
    String observations = '',
  }) {
    return SpeciesCompanion(
      id: Value(id),
      commonName: Value(common),
      scientificName: Value(scientific),
      family: Value(family),
      description: Value(desc),
      flowerColor: Value(color),
      biologicalForm: Value(biologicalForm),
      approximateHeight: Value(approximateHeight),
      leafLength: Value(leafLength),
      leafShape: Value(leafShape),
      leafEdge: Value(leafEdge),
      leafTexture: Value(leafTexture),
      hasSpines: Value(hasSpines),
      spineType: Value(spineType),
      flowerGrouping: Value(flowerGrouping),
      petalCount: Value(petalCount),
      flowerSize: Value(flowerSize),
      hasFruit: Value(hasFruit),
      fruitShape: Value(fruitShape),
      fruitColor: Value(fruitColor),
      fruitSize: Value(fruitSize),
      observations: Value(observations),
    );
  }

  // ============================
  // SPECIES TRAITS (mapeo especie → opción)
  // ============================
  static List<SpeciesTraitsCompanion> get traitEntries {
    final traits = <SpeciesTraitsCompanion>[];
    int counter = 0;

    void addTrait(String speciesId, String questionId, String optionId) {
      counter++;
      traits.add(
        SpeciesTraitsCompanion(
          id: Value('st-${counter.toString().padLeft(4, '0')}'),
          speciesId: Value(speciesId),
          questionId: Value(questionId),
          optionId: Value(optionId),
        ),
      );
    }

    // sp-001 Calafate: arbusto, amarillo, espinas, individual, alta, fruto sí, elíptica
    addTrait('sp-001', qFormaBiologica, optArbusto);
    addTrait('sp-001', qColorFlor, optFlorAmarillo);
    addTrait('sp-001', qEspinas, optConEspinas);
    addTrait('sp-001', qAgrupacionFlor, optIndividual);
    addTrait('sp-001', qAltura, optAlta);
    addTrait('sp-001', qFrutoVisible, optFrutoSi);
    addTrait('sp-001', qFormaHoja, optHojaEliptica);

    // sp-002 Neneo: arbusto, amarillo, sin espinas, individual, alta, fruto sí, otras
    addTrait('sp-002', qFormaBiologica, optArbusto);
    addTrait('sp-002', qColorFlor, optFlorAmarillo);
    addTrait('sp-002', qEspinas, optSinEspinas);
    addTrait('sp-002', qAgrupacionFlor, optIndividual);
    addTrait('sp-002', qAltura, optAlta);
    addTrait('sp-002', qFrutoVisible, optFrutoSi);
    addTrait('sp-002', qFormaHoja, optHojaOtras);

    // sp-003 Duraznillo: arbusto, rojizo, sin espinas, inflorescencia, alta, fruto sí, lanceolada
    addTrait('sp-003', qFormaBiologica, optArbusto);
    addTrait('sp-003', qColorFlor, optFlorRojizo);
    addTrait('sp-003', qEspinas, optSinEspinas);
    addTrait('sp-003', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-003', qAltura, optAlta);
    addTrait('sp-003', qFrutoVisible, optFrutoSi);
    addTrait('sp-003', qFormaHoja, optHojaLanceolada);

    // sp-004 Malaspina: arbusto, blanco, espinas, individual, alta, fruto sí, elíptica
    addTrait('sp-004', qFormaBiologica, optArbusto);
    addTrait('sp-004', qColorFlor, optFlorBlanco);
    addTrait('sp-004', qEspinas, optConEspinas);
    addTrait('sp-004', qAgrupacionFlor, optIndividual);
    addTrait('sp-004', qAltura, optAlta);
    addTrait('sp-004', qFrutoVisible, optFrutoSi);
    addTrait('sp-004', qFormaHoja, optHojaEliptica);

    // sp-005 Lechetrés: hierba, verde, sin espinas, inflorescencia, muy baja, fruto sí, elíptica
    addTrait('sp-005', qFormaBiologica, optHierba);
    addTrait('sp-005', qColorFlor, optFlorVerde);
    addTrait('sp-005', qEspinas, optSinEspinas);
    addTrait('sp-005', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-005', qAltura, optMuyBaja);
    addTrait('sp-005', qFrutoVisible, optFrutoSi);
    addTrait('sp-005', qFormaHoja, optHojaEliptica);

    // sp-006 Quilembay: arbusto, amarillo, espinas, inflorescencia, alta, fruto sí, lanceolada
    addTrait('sp-006', qFormaBiologica, optArbusto);
    addTrait('sp-006', qColorFlor, optFlorAmarillo);
    addTrait('sp-006', qEspinas, optConEspinas);
    addTrait('sp-006', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-006', qAltura, optAlta);
    addTrait('sp-006', qFrutoVisible, optFrutoSi);
    addTrait('sp-006', qFormaHoja, optHojaLanceolada);

    // sp-007 Uña de gato: arbusto, amarillo, sin espinas, inflorescencia, baja, fruto sí, acicular
    addTrait('sp-007', qFormaBiologica, optArbusto);
    addTrait('sp-007', qColorFlor, optFlorAmarillo);
    addTrait('sp-007', qEspinas, optSinEspinas);
    addTrait('sp-007', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-007', qAltura, optBaja);
    addTrait('sp-007', qFrutoVisible, optFrutoSi);
    addTrait('sp-007', qFormaHoja, optHojaAcicular);

    // sp-008 Verbena: arbusto, crema, sin espinas, individual, alta, fruto no, elíptica
    addTrait('sp-008', qFormaBiologica, optArbusto);
    addTrait('sp-008', qColorFlor, optFlorCrema);
    addTrait('sp-008', qEspinas, optSinEspinas);
    addTrait('sp-008', qAgrupacionFlor, optIndividual);
    addTrait('sp-008', qAltura, optAlta);
    addTrait('sp-008', qFrutoVisible, optFrutoNo);
    addTrait('sp-008', qFormaHoja, optHojaEliptica);

    // sp-009 Botón de oro: subarbusto, amarillo, sin espinas, inflorescencia, media, fruto no, lanceolada
    addTrait('sp-009', qFormaBiologica, optSubarbusto);
    addTrait('sp-009', qColorFlor, optFlorAmarillo);
    addTrait('sp-009', qEspinas, optSinEspinas);
    addTrait('sp-009', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-009', qAltura, optMedia);
    addTrait('sp-009', qFrutoVisible, optFrutoNo);
    addTrait('sp-009', qFormaHoja, optHojaLanceolada);

    // sp-010 Yao-yín: arbusto, blanco, sin espinas, individual, alta, fruto sí, linear
    addTrait('sp-010', qFormaBiologica, optArbusto);
    addTrait('sp-010', qColorFlor, optFlorBlanco);
    addTrait('sp-010', qEspinas, optSinEspinas);
    addTrait('sp-010', qAgrupacionFlor, optIndividual);
    addTrait('sp-010', qAltura, optAlta);
    addTrait('sp-010', qFrutoVisible, optFrutoSi);
    addTrait('sp-010', qFormaHoja, optHojaLinear);

    // sp-011 Molle: arbusto, amarillo, espinas, individual, alta, fruto sí, espatulada
    addTrait('sp-011', qFormaBiologica, optArbusto);
    addTrait('sp-011', qColorFlor, optFlorAmarillo);
    addTrait('sp-011', qEspinas, optConEspinas);
    addTrait('sp-011', qAgrupacionFlor, optIndividual);
    addTrait('sp-011', qAltura, optAlta);
    addTrait('sp-011', qFrutoVisible, optFrutoSi);
    addTrait('sp-011', qFormaHoja, optHojaEspatulada);

    // sp-012 Falso tomillo: arbusto, blanco, sin espinas, individual, baja, fruto no, elíptica
    addTrait('sp-012', qFormaBiologica, optArbusto);
    addTrait('sp-012', qColorFlor, optFlorBlanco);
    addTrait('sp-012', qEspinas, optSinEspinas);
    addTrait('sp-012', qAgrupacionFlor, optIndividual);
    addTrait('sp-012', qAltura, optBaja);
    addTrait('sp-012', qFrutoVisible, optFrutoNo);
    addTrait('sp-012', qFormaHoja, optHojaEliptica);

    // sp-013 Zampa: subarbusto, amarillo, sin espinas, individual, alta, fruto sí, otras
    addTrait('sp-013', qFormaBiologica, optSubarbusto);
    addTrait('sp-013', qColorFlor, optFlorAmarillo);
    addTrait('sp-013', qEspinas, optSinEspinas);
    addTrait('sp-013', qAgrupacionFlor, optIndividual);
    addTrait('sp-013', qAltura, optAlta);
    addTrait('sp-013', qFrutoVisible, optFrutoSi);
    addTrait('sp-013', qFormaHoja, optHojaOtras);

    // sp-014 Tomillo rosa: arbusto, rosa, sin espinas, individual, baja, fruto no, elíptica
    addTrait('sp-014', qFormaBiologica, optArbusto);
    addTrait('sp-014', qColorFlor, optFlorRosa);
    addTrait('sp-014', qEspinas, optSinEspinas);
    addTrait('sp-014', qAgrupacionFlor, optIndividual);
    addTrait('sp-014', qAltura, optBaja);
    addTrait('sp-014', qFrutoVisible, optFrutoNo);
    addTrait('sp-014', qFormaHoja, optHojaEliptica);

    // sp-015 Violeta de campo: hierba, violeta, sin espinas, individual, baja, fruto sí, compuesta
    addTrait('sp-015', qFormaBiologica, optHierba);
    addTrait('sp-015', qColorFlor, optFlorVioleta);
    addTrait('sp-015', qEspinas, optSinEspinas);
    addTrait('sp-015', qAgrupacionFlor, optIndividual);
    addTrait('sp-015', qAltura, optBaja);
    addTrait('sp-015', qFrutoVisible, optFrutoSi);
    addTrait('sp-015', qFormaHoja, optHojaCompuesta);

    // sp-016 Cerastio: hierba, blanco, sin espinas, individual, muy baja, fruto no, lanceolada
    addTrait('sp-016', qFormaBiologica, optHierba);
    addTrait('sp-016', qColorFlor, optFlorBlanco);
    addTrait('sp-016', qEspinas, optSinEspinas);
    addTrait('sp-016', qAgrupacionFlor, optIndividual);
    addTrait('sp-016', qAltura, optMuyBaja);
    addTrait('sp-016', qFrutoVisible, optFrutoNo);
    addTrait('sp-016', qFormaHoja, optHojaLanceolada);

    // sp-017 Zapato de reina: hierba, amarillo, sin espinas, individual, muy baja, fruto no, espatulada
    addTrait('sp-017', qFormaBiologica, optHierba);
    addTrait('sp-017', qColorFlor, optFlorAmarillo);
    addTrait('sp-017', qEspinas, optSinEspinas);
    addTrait('sp-017', qAgrupacionFlor, optIndividual);
    addTrait('sp-017', qAltura, optMuyBaja);
    addTrait('sp-017', qFrutoVisible, optFrutoNo);
    addTrait('sp-017', qFormaHoja, optHojaEspatulada);

    // sp-018 Pata de perdiz: hierba, naranja, sin espinas, individual, muy baja, fruto sí, compuesta
    addTrait('sp-018', qFormaBiologica, optHierba);
    addTrait('sp-018', qColorFlor, optFlorNaranja);
    addTrait('sp-018', qEspinas, optSinEspinas);
    addTrait('sp-018', qAgrupacionFlor, optIndividual);
    addTrait('sp-018', qAltura, optMuyBaja);
    addTrait('sp-018', qFrutoVisible, optFrutoSi);
    addTrait('sp-018', qFormaHoja, optHojaCompuesta);

    // sp-019 Mata fuego: subarbusto, rojizo, espinas, individual, media, fruto sí, compuesta
    addTrait('sp-019', qFormaBiologica, optSubarbusto);
    addTrait('sp-019', qColorFlor, optFlorRojizo);
    addTrait('sp-019', qEspinas, optConEspinas);
    addTrait('sp-019', qAgrupacionFlor, optIndividual);
    addTrait('sp-019', qAltura, optMedia);
    addTrait('sp-019', qFrutoVisible, optFrutoSi);
    addTrait('sp-019', qFormaHoja, optHojaCompuesta);

    // sp-020 Marancel: hierba, blanco, sin espinas, individual, baja, fruto no, linear
    addTrait('sp-020', qFormaBiologica, optHierba);
    addTrait('sp-020', qColorFlor, optFlorBlanco);
    addTrait('sp-020', qEspinas, optSinEspinas);
    addTrait('sp-020', qAgrupacionFlor, optIndividual);
    addTrait('sp-020', qAltura, optBaja);
    addTrait('sp-020', qFrutoVisible, optFrutoNo);
    addTrait('sp-020', qFormaHoja, optHojaLinear);

    // sp-021 Yuyo moro: arbusto, amarillo, sin espinas, inflorescencia, alta, fruto no, linear
    addTrait('sp-021', qFormaBiologica, optArbusto);
    addTrait('sp-021', qColorFlor, optFlorAmarillo);
    addTrait('sp-021', qEspinas, optSinEspinas);
    addTrait('sp-021', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-021', qAltura, optAlta);
    addTrait('sp-021', qFrutoVisible, optFrutoNo);
    addTrait('sp-021', qFormaHoja, optHojaLinear);

    // sp-022 Coirón duro: hierba, verde, sin espinas, inflorescencia, media, fruto no, linear
    addTrait('sp-022', qFormaBiologica, optHierba);
    addTrait('sp-022', qColorFlor, optFlorVerde);
    addTrait('sp-022', qEspinas, optSinEspinas);
    addTrait('sp-022', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-022', qAltura, optMedia);
    addTrait('sp-022', qFrutoVisible, optFrutoNo);
    addTrait('sp-022', qFormaHoja, optHojaLinear);

    // sp-023 Coirón llama: hierba, verde, sin espinas, inflorescencia, baja, fruto no, linear
    addTrait('sp-023', qFormaBiologica, optHierba);
    addTrait('sp-023', qColorFlor, optFlorVerde);
    addTrait('sp-023', qEspinas, optSinEspinas);
    addTrait('sp-023', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-023', qAltura, optBaja);
    addTrait('sp-023', qFrutoVisible, optFrutoNo);
    addTrait('sp-023', qFormaHoja, optHojaLinear);

    // sp-024 Coirón poa: hierba, verde, sin espinas, inflorescencia, media, fruto no, linear
    addTrait('sp-024', qFormaBiologica, optHierba);
    addTrait('sp-024', qColorFlor, optFlorVerde);
    addTrait('sp-024', qEspinas, optSinEspinas);
    addTrait('sp-024', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-024', qAltura, optMedia);
    addTrait('sp-024', qFrutoVisible, optFrutoNo);
    addTrait('sp-024', qFormaHoja, optHojaLinear);

    // sp-025 Coirón pluma: hierba, rojizo, sin espinas, inflorescencia, media, fruto no, linear
    addTrait('sp-025', qFormaBiologica, optHierba);
    addTrait('sp-025', qColorFlor, optFlorRojizo);
    addTrait('sp-025', qEspinas, optSinEspinas);
    addTrait('sp-025', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-025', qAltura, optMedia);
    addTrait('sp-025', qFrutoVisible, optFrutoNo);
    addTrait('sp-025', qFormaHoja, optHojaLinear);

    // sp-026 Tomillo de campo: arbusto, blanco, sin espinas, individual, baja, fruto no, elíptica
    addTrait('sp-026', qFormaBiologica, optArbusto);
    addTrait('sp-026', qColorFlor, optFlorBlanco);
    addTrait('sp-026', qEspinas, optSinEspinas);
    addTrait('sp-026', qAgrupacionFlor, optIndividual);
    addTrait('sp-026', qAltura, optBaja);
    addTrait('sp-026', qFrutoVisible, optFrutoNo);
    addTrait('sp-026', qFormaHoja, optHojaEliptica);

    // sp-027 Mata laguna: arbusto, blanco, espinas, individual, media, fruto sí, espatulada
    addTrait('sp-027', qFormaBiologica, optArbusto);
    addTrait('sp-027', qColorFlor, optFlorBlanco);
    addTrait('sp-027', qEspinas, optConEspinas);
    addTrait('sp-027', qAgrupacionFlor, optIndividual);
    addTrait('sp-027', qAltura, optMedia);
    addTrait('sp-027', qFrutoVisible, optFrutoSi);
    addTrait('sp-027', qFormaHoja, optHojaEspatulada);

    // sp-028 Solupe grueso: arbusto, verde, sin espinas, cono, alta, fruto sí, otras
    addTrait('sp-028', qFormaBiologica, optArbusto);
    addTrait('sp-028', qColorFlor, optFlorVerde);
    addTrait('sp-028', qEspinas, optSinEspinas);
    addTrait('sp-028', qAgrupacionFlor, optCono);
    addTrait('sp-028', qAltura, optAlta);
    addTrait('sp-028', qFrutoVisible, optFrutoSi);
    addTrait('sp-028', qFormaHoja, optHojaOtras);

    // sp-029 Barba de chivo: arbusto, amarillo, espinas, individual, alta, fruto sí, compuesta
    addTrait('sp-029', qFormaBiologica, optArbusto);
    addTrait('sp-029', qColorFlor, optFlorAmarillo);
    addTrait('sp-029', qEspinas, optConEspinas);
    addTrait('sp-029', qAgrupacionFlor, optIndividual);
    addTrait('sp-029', qAltura, optAlta);
    addTrait('sp-029', qFrutoVisible, optFrutoSi);
    addTrait('sp-029', qFormaHoja, optHojaCompuesta);

    // sp-030 Vidriera: arbusto, amarillo, sin espinas, individual, alta, fruto no, linear
    addTrait('sp-030', qFormaBiologica, optArbusto);
    addTrait('sp-030', qColorFlor, optFlorAmarillo);
    addTrait('sp-030', qEspinas, optSinEspinas);
    addTrait('sp-030', qAgrupacionFlor, optIndividual);
    addTrait('sp-030', qAltura, optAlta);
    addTrait('sp-030', qFrutoVisible, optFrutoNo);
    addTrait('sp-030', qFormaHoja, optHojaLinear);

    // sp-031 Jazmín de campo: subarbusto, amarillo, sin espinas, individual, baja, fruto no, elíptica
    addTrait('sp-031', qFormaBiologica, optSubarbusto);
    addTrait('sp-031', qColorFlor, optFlorAmarillo);
    addTrait('sp-031', qEspinas, optSinEspinas);
    addTrait('sp-031', qAgrupacionFlor, optIndividual);
    addTrait('sp-031', qAltura, optBaja);
    addTrait('sp-031', qFrutoVisible, optFrutoNo);
    addTrait('sp-031', qFormaHoja, optHojaEliptica);

    // sp-032 Algarrobillo: arbusto, amarillo, espinas, individual, alta, fruto sí, compuesta
    addTrait('sp-032', qFormaBiologica, optArbusto);
    addTrait('sp-032', qColorFlor, optFlorAmarillo);
    addTrait('sp-032', qEspinas, optConEspinas);
    addTrait('sp-032', qAgrupacionFlor, optIndividual);
    addTrait('sp-032', qAltura, optAlta);
    addTrait('sp-032', qFrutoVisible, optFrutoSi);
    addTrait('sp-032', qFormaHoja, optHojaCompuesta);

    // sp-033 Cactus patagónico: subarbusto suculento, rosa, espinas, individual, baja, fruto sí, otras
    addTrait('sp-033', qFormaBiologica, optSubarbustoSuculento);
    addTrait('sp-033', qColorFlor, optFlorRosa);
    addTrait('sp-033', qEspinas, optConEspinas);
    addTrait('sp-033', qAgrupacionFlor, optIndividual);
    addTrait('sp-033', qAltura, optBaja);
    addTrait('sp-033', qFrutoVisible, optFrutoSi);
    addTrait('sp-033', qFormaHoja, optHojaOtras);

    // sp-034 Tuna: subarbusto suculento, naranja, espinas, individual, muy baja, fruto sí, otras
    addTrait('sp-034', qFormaBiologica, optSubarbustoSuculento);
    addTrait('sp-034', qColorFlor, optFlorNaranja);
    addTrait('sp-034', qEspinas, optConEspinas);
    addTrait('sp-034', qAgrupacionFlor, optIndividual);
    addTrait('sp-034', qAltura, optMuyBaja);
    addTrait('sp-034', qFrutoVisible, optFrutoSi);
    addTrait('sp-034', qFormaHoja, optHojaOtras);

    // sp-035 Chupasangre: subarbusto suculento, blanco, espinas, individual, muy baja, fruto sí, otras
    addTrait('sp-035', qFormaBiologica, optSubarbustoSuculento);
    addTrait('sp-035', qColorFlor, optFlorBlanco);
    addTrait('sp-035', qEspinas, optConEspinas);
    addTrait('sp-035', qAgrupacionFlor, optIndividual);
    addTrait('sp-035', qAltura, optMuyBaja);
    addTrait('sp-035', qFrutoVisible, optFrutoSi);
    addTrait('sp-035', qFormaHoja, optHojaOtras);

    // sp-036 Clavel de campo: subarbusto, naranja, sin espinas, inflorescencia, media, fruto sí, lanceolada
    addTrait('sp-036', qFormaBiologica, optSubarbusto);
    addTrait('sp-036', qColorFlor, optFlorNaranja);
    addTrait('sp-036', qEspinas, optSinEspinas);
    addTrait('sp-036', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-036', qAltura, optMedia);
    addTrait('sp-036', qFrutoVisible, optFrutoSi);
    addTrait('sp-036', qFormaHoja, optHojaLanceolada);

    // sp-037 Mamuel choique: arbusto, amarillo, espinas, individual, alta, fruto sí, compuesta
    addTrait('sp-037', qFormaBiologica, optArbusto);
    addTrait('sp-037', qColorFlor, optFlorAmarillo);
    addTrait('sp-037', qEspinas, optConEspinas);
    addTrait('sp-037', qAgrupacionFlor, optIndividual);
    addTrait('sp-037', qAltura, optAlta);
    addTrait('sp-037', qFrutoVisible, optFrutoSi);
    addTrait('sp-037', qFormaHoja, optHojaCompuesta);

    // sp-038 Adesmia candida: subarbusto, amarillo, sin espinas, individual, baja, fruto sí, compuesta
    addTrait('sp-038', qFormaBiologica, optSubarbusto);
    addTrait('sp-038', qColorFlor, optFlorAmarillo);
    addTrait('sp-038', qEspinas, optSinEspinas);
    addTrait('sp-038', qAgrupacionFlor, optIndividual);
    addTrait('sp-038', qAltura, optBaja);
    addTrait('sp-038', qFrutoVisible, optFrutoSi);
    addTrait('sp-038', qFormaHoja, optHojaCompuesta);

    // sp-039 Mata guanaco: arbusto, amarillo, sin espinas, inflorescencia, media, fruto no, elíptica
    addTrait('sp-039', qFormaBiologica, optArbusto);
    addTrait('sp-039', qColorFlor, optFlorAmarillo);
    addTrait('sp-039', qEspinas, optSinEspinas);
    addTrait('sp-039', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-039', qAltura, optMedia);
    addTrait('sp-039', qFrutoVisible, optFrutoNo);
    addTrait('sp-039', qFormaHoja, optHojaEliptica);

    // sp-040 Tolilla: arbusto, crema, sin espinas, individual, media, fruto no, otras
    addTrait('sp-040', qFormaBiologica, optArbusto);
    addTrait('sp-040', qColorFlor, optFlorCrema);
    addTrait('sp-040', qEspinas, optSinEspinas);
    addTrait('sp-040', qAgrupacionFlor, optIndividual);
    addTrait('sp-040', qAltura, optMedia);
    addTrait('sp-040', qFrutoVisible, optFrutoNo);
    addTrait('sp-040', qFormaHoja, optHojaOtras);

    // sp-041 Junelia: arbusto, blanco, sin espinas, individual, baja, fruto no, otras
    addTrait('sp-041', qFormaBiologica, optArbusto);
    addTrait('sp-041', qColorFlor, optFlorBlanco);
    addTrait('sp-041', qEspinas, optSinEspinas);
    addTrait('sp-041', qAgrupacionFlor, optIndividual);
    addTrait('sp-041', qAltura, optBaja);
    addTrait('sp-041', qFrutoVisible, optFrutoNo);
    addTrait('sp-041', qFormaHoja, optHojaOtras);

    // sp-042 Neneo rosa: arbusto, blanco, espinas, individual, baja, fruto no, elíptica
    addTrait('sp-042', qFormaBiologica, optArbusto);
    addTrait('sp-042', qColorFlor, optFlorBlanco);
    addTrait('sp-042', qEspinas, optConEspinas);
    addTrait('sp-042', qAgrupacionFlor, optIndividual);
    addTrait('sp-042', qAltura, optBaja);
    addTrait('sp-042', qFrutoVisible, optFrutoNo);
    addTrait('sp-042', qFormaHoja, optHojaEliptica);

    // sp-043 Manca perro: arbusto, blanco, espinas, inflorescencia, baja, fruto no, acicular
    addTrait('sp-043', qFormaBiologica, optArbusto);
    addTrait('sp-043', qColorFlor, optFlorBlanco);
    addTrait('sp-043', qEspinas, optConEspinas);
    addTrait('sp-043', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-043', qAltura, optBaja);
    addTrait('sp-043', qFrutoVisible, optFrutoNo);
    addTrait('sp-043', qFormaHoja, optHojaAcicular);

    // sp-044 Molle colorado: arbusto, amarillo, espinas, individual, alta, fruto sí, espatulada
    addTrait('sp-044', qFormaBiologica, optArbusto);
    addTrait('sp-044', qColorFlor, optFlorAmarillo);
    addTrait('sp-044', qEspinas, optConEspinas);
    addTrait('sp-044', qAgrupacionFlor, optIndividual);
    addTrait('sp-044', qAltura, optAlta);
    addTrait('sp-044', qFrutoVisible, optFrutoSi);
    addTrait('sp-044', qFormaHoja, optHojaEspatulada);

    // sp-045 Chilca: subarbusto, crema, sin espinas, inflorescencia, media, fruto no, espatulada
    addTrait('sp-045', qFormaBiologica, optSubarbusto);
    addTrait('sp-045', qColorFlor, optFlorCrema);
    addTrait('sp-045', qEspinas, optSinEspinas);
    addTrait('sp-045', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-045', qAltura, optMedia);
    addTrait('sp-045', qFrutoVisible, optFrutoNo);
    addTrait('sp-045', qFormaHoja, optHojaEspatulada);

    // sp-046 Caulia: arbusto, rojizo, espinas, individual, baja, fruto sí, compuesta
    addTrait('sp-046', qFormaBiologica, optArbusto);
    addTrait('sp-046', qColorFlor, optFlorRojizo);
    addTrait('sp-046', qEspinas, optConEspinas);
    addTrait('sp-046', qAgrupacionFlor, optIndividual);
    addTrait('sp-046', qAltura, optBaja);
    addTrait('sp-046', qFrutoVisible, optFrutoSi);
    addTrait('sp-046', qFormaHoja, optHojaCompuesta);

    // sp-047 Yerba de la perdiz: arbusto, rojizo, espinas, individual, muy baja, fruto sí, compuesta
    addTrait('sp-047', qFormaBiologica, optArbusto);
    addTrait('sp-047', qColorFlor, optFlorRojizo);
    addTrait('sp-047', qEspinas, optConEspinas);
    addTrait('sp-047', qAgrupacionFlor, optIndividual);
    addTrait('sp-047', qAltura, optMuyBaja);
    addTrait('sp-047', qFrutoVisible, optFrutoSi);
    addTrait('sp-047', qFormaHoja, optHojaCompuesta);

    // sp-048 Yareta: arbusto, amarillo, sin espinas, inflorescencia, muy baja, fruto no, espatulada
    addTrait('sp-048', qFormaBiologica, optArbusto);
    addTrait('sp-048', qColorFlor, optFlorAmarillo);
    addTrait('sp-048', qEspinas, optSinEspinas);
    addTrait('sp-048', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-048', qAltura, optMuyBaja);
    addTrait('sp-048', qFrutoVisible, optFrutoNo);
    addTrait('sp-048', qFormaHoja, optHojaEspatulada);

    // sp-049 Cadillo: hierba, rojizo, espinas, inflorescencia, muy baja, fruto sí, compuesta
    addTrait('sp-049', qFormaBiologica, optHierba);
    addTrait('sp-049', qColorFlor, optFlorRojizo);
    addTrait('sp-049', qEspinas, optConEspinas);
    addTrait('sp-049', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-049', qAltura, optMuyBaja);
    addTrait('sp-049', qFrutoVisible, optFrutoSi);
    addTrait('sp-049', qFormaHoja, optHojaCompuesta);

    // sp-050 Abrojo: hierba, rojizo, espinas, inflorescencia, baja, fruto sí, compuesta
    addTrait('sp-050', qFormaBiologica, optHierba);
    addTrait('sp-050', qColorFlor, optFlorRojizo);
    addTrait('sp-050', qEspinas, optConEspinas);
    addTrait('sp-050', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-050', qAltura, optBaja);
    addTrait('sp-050', qFrutoVisible, optFrutoSi);
    addTrait('sp-050', qFormaHoja, optHojaCompuesta);

    // sp-051 Abrojo cojín: hierba, rojizo, espinas, inflorescencia, muy baja, fruto sí, compuesta
    addTrait('sp-051', qFormaBiologica, optHierba);
    addTrait('sp-051', qColorFlor, optFlorRojizo);
    addTrait('sp-051', qEspinas, optConEspinas);
    addTrait('sp-051', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-051', qAltura, optMuyBaja);
    addTrait('sp-051', qFrutoVisible, optFrutoSi);
    addTrait('sp-051', qFormaHoja, optHojaCompuesta);

    // sp-052 Ameginoa: arbusto, amarillo, sin espinas, inflorescencia, baja, fruto no, linear
    addTrait('sp-052', qFormaBiologica, optArbusto);
    addTrait('sp-052', qColorFlor, optFlorAmarillo);
    addTrait('sp-052', qEspinas, optSinEspinas);
    addTrait('sp-052', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-052', qAltura, optBaja);
    addTrait('sp-052', qFrutoVisible, optFrutoNo);
    addTrait('sp-052', qFormaHoja, optHojaLinear);

    // sp-053 Hierba salada: arbusto, rojizo, sin espinas, inflorescencia, baja, fruto no, otras
    addTrait('sp-053', qFormaBiologica, optArbusto);
    addTrait('sp-053', qColorFlor, optFlorRojizo);
    addTrait('sp-053', qEspinas, optSinEspinas);
    addTrait('sp-053', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-053', qAltura, optBaja);
    addTrait('sp-053', qFrutoVisible, optFrutoNo);
    addTrait('sp-053', qFormaHoja, optHojaOtras);

    // sp-054 Zampa sagitada: arbusto, amarillo, sin espinas, individual, alta, fruto sí, otras
    addTrait('sp-054', qFormaBiologica, optArbusto);
    addTrait('sp-054', qColorFlor, optFlorAmarillo);
    addTrait('sp-054', qEspinas, optSinEspinas);
    addTrait('sp-054', qAgrupacionFlor, optIndividual);
    addTrait('sp-054', qAltura, optAlta);
    addTrait('sp-054', qFrutoVisible, optFrutoSi);
    addTrait('sp-054', qFormaHoja, optHojaOtras);

    // sp-055 Macachín: hierba, blanco, sin espinas, individual, muy baja, fruto sí, linear
    addTrait('sp-055', qFormaBiologica, optHierba);
    addTrait('sp-055', qColorFlor, optFlorBlanco);
    addTrait('sp-055', qEspinas, optSinEspinas);
    addTrait('sp-055', qAgrupacionFlor, optIndividual);
    addTrait('sp-055', qAltura, optMuyBaja);
    addTrait('sp-055', qFrutoVisible, optFrutoSi);
    addTrait('sp-055', qFormaHoja, optHojaLinear);

    // sp-056 Llantén: hierba, blanco, sin espinas, individual, muy baja, fruto no, linear
    addTrait('sp-056', qFormaBiologica, optHierba);
    addTrait('sp-056', qColorFlor, optFlorBlanco);
    addTrait('sp-056', qEspinas, optSinEspinas);
    addTrait('sp-056', qAgrupacionFlor, optIndividual);
    addTrait('sp-056', qAltura, optMuyBaja);
    addTrait('sp-056', qFrutoVisible, optFrutoNo);
    addTrait('sp-056', qFormaHoja, optHojaLinear);

    // sp-057 Don Diego de noche: hierba, amarillo, sin espinas, individual, baja, fruto no, lanceolada
    addTrait('sp-057', qFormaBiologica, optHierba);
    addTrait('sp-057', qColorFlor, optFlorAmarillo);
    addTrait('sp-057', qEspinas, optSinEspinas);
    addTrait('sp-057', qAgrupacionFlor, optIndividual);
    addTrait('sp-057', qAltura, optBaja);
    addTrait('sp-057', qFrutoVisible, optFrutoNo);
    addTrait('sp-057', qFormaHoja, optHojaLanceolada);

    // sp-058 Sibara: subarbusto, crema, sin espinas, individual, muy baja, fruto no, compuesta
    addTrait('sp-058', qFormaBiologica, optSubarbusto);
    addTrait('sp-058', qColorFlor, optFlorCrema);
    addTrait('sp-058', qEspinas, optSinEspinas);
    addTrait('sp-058', qAgrupacionFlor, optIndividual);
    addTrait('sp-058', qAltura, optMuyBaja);
    addTrait('sp-058', qFrutoVisible, optFrutoNo);
    addTrait('sp-058', qFormaHoja, optHojaCompuesta);

    // sp-059 Cebadilla: hierba, verde, sin espinas, inflorescencia, media, fruto no, linear
    addTrait('sp-059', qFormaBiologica, optHierba);
    addTrait('sp-059', qColorFlor, optFlorVerde);
    addTrait('sp-059', qEspinas, optSinEspinas);
    addTrait('sp-059', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-059', qAltura, optMedia);
    addTrait('sp-059', qFrutoVisible, optFrutoNo);
    addTrait('sp-059', qFormaHoja, optHojaLinear);

    // sp-060 Flechilla: hierba, blanco, sin espinas, inflorescencia, baja, fruto no, linear
    addTrait('sp-060', qFormaBiologica, optHierba);
    addTrait('sp-060', qColorFlor, optFlorBlanco);
    addTrait('sp-060', qEspinas, optSinEspinas);
    addTrait('sp-060', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-060', qAltura, optBaja);
    addTrait('sp-060', qFrutoVisible, optFrutoNo);
    addTrait('sp-060', qFormaHoja, optHojaLinear);

    // sp-061 Estrellita de campo: hierba, blanco, sin espinas, individual, muy baja, fruto no, linear
    addTrait('sp-061', qFormaBiologica, optHierba);
    addTrait('sp-061', qColorFlor, optFlorBlanco);
    addTrait('sp-061', qEspinas, optSinEspinas);
    addTrait('sp-061', qAgrupacionFlor, optIndividual);
    addTrait('sp-061', qAltura, optMuyBaja);
    addTrait('sp-061', qFrutoVisible, optFrutoNo);
    addTrait('sp-061', qFormaHoja, optHojaLinear);

    // sp-062 Cebollín: hierba, verde, sin espinas, individual, muy baja, fruto no, linear
    addTrait('sp-062', qFormaBiologica, optHierba);
    addTrait('sp-062', qColorFlor, optFlorVerde);
    addTrait('sp-062', qEspinas, optSinEspinas);
    addTrait('sp-062', qAgrupacionFlor, optIndividual);
    addTrait('sp-062', qAltura, optMuyBaja);
    addTrait('sp-062', qFrutoVisible, optFrutoNo);
    addTrait('sp-062', qFormaHoja, optHojaLinear);

    // sp-063 Pterocactus: hierba suculenta, naranja, espinas, individual, muy baja, fruto sí, otras
    addTrait('sp-063', qFormaBiologica, optHierbaSuculenta);
    addTrait('sp-063', qColorFlor, optFlorNaranja);
    addTrait('sp-063', qEspinas, optConEspinas);
    addTrait('sp-063', qAgrupacionFlor, optIndividual);
    addTrait('sp-063', qAltura, optMuyBaja);
    addTrait('sp-063', qFrutoVisible, optFrutoSi);
    addTrait('sp-063', qFormaHoja, optHojaOtras);

    // sp-064 Boopis: hierba, blanco, sin espinas, individual, muy baja, fruto no, linear
    addTrait('sp-064', qFormaBiologica, optHierba);
    addTrait('sp-064', qColorFlor, optFlorBlanco);
    addTrait('sp-064', qEspinas, optSinEspinas);
    addTrait('sp-064', qAgrupacionFlor, optIndividual);
    addTrait('sp-064', qAltura, optMuyBaja);
    addTrait('sp-064', qFrutoVisible, optFrutoNo);
    addTrait('sp-064', qFormaHoja, optHojaLinear);

    // sp-065 Azucena de campo: hierba, naranja, sin espinas, individual, muy baja, fruto no, linear
    addTrait('sp-065', qFormaBiologica, optHierba);
    addTrait('sp-065', qColorFlor, optFlorNaranja);
    addTrait('sp-065', qEspinas, optSinEspinas);
    addTrait('sp-065', qAgrupacionFlor, optIndividual);
    addTrait('sp-065', qAltura, optMuyBaja);
    addTrait('sp-065', qFrutoVisible, optFrutoNo);
    addTrait('sp-065', qFormaHoja, optHojaLinear);

    // sp-066 Monjita: hierba, amarillo, sin espinas, individual, muy baja, fruto no, lanceolada
    addTrait('sp-066', qFormaBiologica, optHierba);
    addTrait('sp-066', qColorFlor, optFlorAmarillo);
    addTrait('sp-066', qEspinas, optSinEspinas);
    addTrait('sp-066', qAgrupacionFlor, optIndividual);
    addTrait('sp-066', qAltura, optMuyBaja);
    addTrait('sp-066', qFrutoVisible, optFrutoNo);
    addTrait('sp-066', qFormaHoja, optHojaLanceolada);

    // sp-067 Flor de la cuncuna: hierba, violeta, sin espinas, individual, baja, fruto no, compuesta
    addTrait('sp-067', qFormaBiologica, optHierba);
    addTrait('sp-067', qColorFlor, optFlorVioleta);
    addTrait('sp-067', qEspinas, optSinEspinas);
    addTrait('sp-067', qAgrupacionFlor, optIndividual);
    addTrait('sp-067', qAltura, optBaja);
    addTrait('sp-067', qFrutoVisible, optFrutoNo);
    addTrait('sp-067', qFormaHoja, optHojaCompuesta);

    // sp-068 Perezia: hierba, crema, sin espinas, inflorescencia, muy baja, fruto no, espatulada
    addTrait('sp-068', qFormaBiologica, optHierba);
    addTrait('sp-068', qColorFlor, optFlorCrema);
    addTrait('sp-068', qEspinas, optSinEspinas);
    addTrait('sp-068', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-068', qAltura, optMuyBaja);
    addTrait('sp-068', qFrutoVisible, optFrutoNo);
    addTrait('sp-068', qFormaHoja, optHojaEspatulada);

    // sp-069 Camisonia: hierba, amarillo, sin espinas, individual, muy baja, fruto no, lanceolada
    addTrait('sp-069', qFormaBiologica, optHierba);
    addTrait('sp-069', qColorFlor, optFlorAmarillo);
    addTrait('sp-069', qEspinas, optSinEspinas);
    addTrait('sp-069', qAgrupacionFlor, optIndividual);
    addTrait('sp-069', qAltura, optMuyBaja);
    addTrait('sp-069', qFrutoVisible, optFrutoNo);
    addTrait('sp-069', qFormaHoja, optHojaLanceolada);

    // sp-070 Rueda chica: hierba, violeta, sin espinas, individual, muy baja, fruto no, linear
    addTrait('sp-070', qFormaBiologica, optHierba);
    addTrait('sp-070', qColorFlor, optFlorVioleta);
    addTrait('sp-070', qEspinas, optSinEspinas);
    addTrait('sp-070', qAgrupacionFlor, optIndividual);
    addTrait('sp-070', qAltura, optMuyBaja);
    addTrait('sp-070', qFrutoVisible, optFrutoNo);
    addTrait('sp-070', qFormaHoja, optHojaLinear);

    // sp-071 Ortiga de campo: hierba, amarillo, sin espinas, individual, baja, fruto no, lanceolada
    addTrait('sp-071', qFormaBiologica, optHierba);
    addTrait('sp-071', qColorFlor, optFlorAmarillo);
    addTrait('sp-071', qEspinas, optSinEspinas);
    addTrait('sp-071', qAgrupacionFlor, optIndividual);
    addTrait('sp-071', qAltura, optBaja);
    addTrait('sp-071', qFrutoVisible, optFrutoNo);
    addTrait('sp-071', qFormaHoja, optHojaLanceolada);

    // sp-072 Adesmia villosa: hierba, amarillo, sin espinas, individual, muy baja, fruto sí, compuesta
    addTrait('sp-072', qFormaBiologica, optHierba);
    addTrait('sp-072', qColorFlor, optFlorAmarillo);
    addTrait('sp-072', qEspinas, optSinEspinas);
    addTrait('sp-072', qAgrupacionFlor, optIndividual);
    addTrait('sp-072', qAltura, optMuyBaja);
    addTrait('sp-072', qFrutoVisible, optFrutoSi);
    addTrait('sp-072', qFormaHoja, optHojaCompuesta);

    // sp-073 Yramea: hierba, amarillo, sin espinas, individual, baja, fruto sí, compuesta
    addTrait('sp-073', qFormaBiologica, optHierba);
    addTrait('sp-073', qColorFlor, optFlorAmarillo);
    addTrait('sp-073', qEspinas, optSinEspinas);
    addTrait('sp-073', qAgrupacionFlor, optIndividual);
    addTrait('sp-073', qAltura, optBaja);
    addTrait('sp-073', qFrutoVisible, optFrutoSi);
    addTrait('sp-073', qFormaHoja, optHojaCompuesta);

    // sp-074 Cuerno de cabra: arbusto, amarillo, espinas, individual, media, fruto sí, compuesta
    addTrait('sp-074', qFormaBiologica, optArbusto);
    addTrait('sp-074', qColorFlor, optFlorAmarillo);
    addTrait('sp-074', qEspinas, optConEspinas);
    addTrait('sp-074', qAgrupacionFlor, optIndividual);
    addTrait('sp-074', qAltura, optMedia);
    addTrait('sp-074', qFrutoVisible, optFrutoSi);
    addTrait('sp-074', qFormaHoja, optHojaCompuesta);

    // sp-075 Guaycurú: hierba, blanco, sin espinas, individual, baja, fruto no, espatulada
    addTrait('sp-075', qFormaBiologica, optHierba);
    addTrait('sp-075', qColorFlor, optFlorBlanco);
    addTrait('sp-075', qEspinas, optSinEspinas);
    addTrait('sp-075', qAgrupacionFlor, optIndividual);
    addTrait('sp-075', qAltura, optBaja);
    addTrait('sp-075', qFrutoVisible, optFrutoNo);
    addTrait('sp-075', qFormaHoja, optHojaEspatulada);

    // sp-076 Campana de convento: hierba, violeta, sin espinas, individual, muy baja, fruto no, compuesta
    addTrait('sp-076', qFormaBiologica, optHierba);
    addTrait('sp-076', qColorFlor, optFlorVioleta);
    addTrait('sp-076', qEspinas, optSinEspinas);
    addTrait('sp-076', qAgrupacionFlor, optIndividual);
    addTrait('sp-076', qAltura, optMuyBaja);
    addTrait('sp-076', qFrutoVisible, optFrutoNo);
    addTrait('sp-076', qFormaHoja, optHojaCompuesta);

    // sp-077 Duseniela: hierba, amarillo, sin espinas, inflorescencia, muy baja, fruto no, espatulada
    addTrait('sp-077', qFormaBiologica, optHierba);
    addTrait('sp-077', qColorFlor, optFlorAmarillo);
    addTrait('sp-077', qEspinas, optSinEspinas);
    addTrait('sp-077', qAgrupacionFlor, optInflorescencia);
    addTrait('sp-077', qAltura, optMuyBaja);
    addTrait('sp-077', qFrutoVisible, optFrutoNo);
    addTrait('sp-077', qFormaHoja, optHojaEspatulada);

    // sp-078 Alfilerillo: hierba, violeta, sin espinas, individual, muy baja, fruto no, compuesta
    addTrait('sp-078', qFormaBiologica, optHierba);
    addTrait('sp-078', qColorFlor, optFlorVioleta);
    addTrait('sp-078', qEspinas, optSinEspinas);
    addTrait('sp-078', qAgrupacionFlor, optIndividual);
    addTrait('sp-078', qAltura, optMuyBaja);
    addTrait('sp-078', qFrutoVisible, optFrutoNo);
    addTrait('sp-078', qFormaHoja, optHojaCompuesta);

    // sp-079 Magallana: hierba, amarillo, sin espinas, individual, baja, fruto no, espatulada
    addTrait('sp-079', qFormaBiologica, optHierba);
    addTrait('sp-079', qColorFlor, optFlorAmarillo);
    addTrait('sp-079', qEspinas, optSinEspinas);
    addTrait('sp-079', qAgrupacionFlor, optIndividual);
    addTrait('sp-079', qAltura, optBaja);
    addTrait('sp-079', qFrutoVisible, optFrutoNo);
    addTrait('sp-079', qFormaHoja, optHojaEspatulada);

    return traits;
  }
}
