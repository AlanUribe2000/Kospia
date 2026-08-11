// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SpeciesTable extends Species with TableInfo<$SpeciesTable, Specy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commonNameMeta = const VerificationMeta(
    'commonName',
  );
  @override
  late final GeneratedColumn<String> commonName = GeneratedColumn<String>(
    'common_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _habitatMeta = const VerificationMeta(
    'habitat',
  );
  @override
  late final GeneratedColumn<String> habitat = GeneratedColumn<String>(
    'habitat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _flowerColorMeta = const VerificationMeta(
    'flowerColor',
  );
  @override
  late final GeneratedColumn<String> flowerColor = GeneratedColumn<String>(
    'flower_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _biologicalFormMeta = const VerificationMeta(
    'biologicalForm',
  );
  @override
  late final GeneratedColumn<String> biologicalForm = GeneratedColumn<String>(
    'biological_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _approximateHeightMeta = const VerificationMeta(
    'approximateHeight',
  );
  @override
  late final GeneratedColumn<String> approximateHeight =
      GeneratedColumn<String>(
        'approximate_height',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _leafLengthMeta = const VerificationMeta(
    'leafLength',
  );
  @override
  late final GeneratedColumn<String> leafLength = GeneratedColumn<String>(
    'leaf_length',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _leafShapeMeta = const VerificationMeta(
    'leafShape',
  );
  @override
  late final GeneratedColumn<String> leafShape = GeneratedColumn<String>(
    'leaf_shape',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _leafEdgeMeta = const VerificationMeta(
    'leafEdge',
  );
  @override
  late final GeneratedColumn<String> leafEdge = GeneratedColumn<String>(
    'leaf_edge',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _leafTextureMeta = const VerificationMeta(
    'leafTexture',
  );
  @override
  late final GeneratedColumn<String> leafTexture = GeneratedColumn<String>(
    'leaf_texture',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hasSpinesMeta = const VerificationMeta(
    'hasSpines',
  );
  @override
  late final GeneratedColumn<bool> hasSpines = GeneratedColumn<bool>(
    'has_spines',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_spines" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _spineTypeMeta = const VerificationMeta(
    'spineType',
  );
  @override
  late final GeneratedColumn<String> spineType = GeneratedColumn<String>(
    'spine_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _flowerGroupingMeta = const VerificationMeta(
    'flowerGrouping',
  );
  @override
  late final GeneratedColumn<String> flowerGrouping = GeneratedColumn<String>(
    'flower_grouping',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _petalCountMeta = const VerificationMeta(
    'petalCount',
  );
  @override
  late final GeneratedColumn<String> petalCount = GeneratedColumn<String>(
    'petal_count',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _flowerSizeMeta = const VerificationMeta(
    'flowerSize',
  );
  @override
  late final GeneratedColumn<String> flowerSize = GeneratedColumn<String>(
    'flower_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hasFruitMeta = const VerificationMeta(
    'hasFruit',
  );
  @override
  late final GeneratedColumn<bool> hasFruit = GeneratedColumn<bool>(
    'has_fruit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_fruit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fruitShapeMeta = const VerificationMeta(
    'fruitShape',
  );
  @override
  late final GeneratedColumn<String> fruitShape = GeneratedColumn<String>(
    'fruit_shape',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fruitColorMeta = const VerificationMeta(
    'fruitColor',
  );
  @override
  late final GeneratedColumn<String> fruitColor = GeneratedColumn<String>(
    'fruit_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fruitSizeMeta = const VerificationMeta(
    'fruitSize',
  );
  @override
  late final GeneratedColumn<String> fruitSize = GeneratedColumn<String>(
    'fruit_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    commonName,
    scientificName,
    description,
    imageUrl,
    family,
    habitat,
    flowerColor,
    biologicalForm,
    approximateHeight,
    leafLength,
    leafShape,
    leafEdge,
    leafTexture,
    hasSpines,
    spineType,
    flowerGrouping,
    petalCount,
    flowerSize,
    hasFruit,
    fruitShape,
    fruitColor,
    fruitSize,
    observations,
    isActive,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species';
  @override
  VerificationContext validateIntegrity(
    Insertable<Specy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('common_name')) {
      context.handle(
        _commonNameMeta,
        commonName.isAcceptableOrUnknown(data['common_name']!, _commonNameMeta),
      );
    } else if (isInserting) {
      context.missing(_commonNameMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    }
    if (data.containsKey('habitat')) {
      context.handle(
        _habitatMeta,
        habitat.isAcceptableOrUnknown(data['habitat']!, _habitatMeta),
      );
    }
    if (data.containsKey('flower_color')) {
      context.handle(
        _flowerColorMeta,
        flowerColor.isAcceptableOrUnknown(
          data['flower_color']!,
          _flowerColorMeta,
        ),
      );
    }
    if (data.containsKey('biological_form')) {
      context.handle(
        _biologicalFormMeta,
        biologicalForm.isAcceptableOrUnknown(
          data['biological_form']!,
          _biologicalFormMeta,
        ),
      );
    }
    if (data.containsKey('approximate_height')) {
      context.handle(
        _approximateHeightMeta,
        approximateHeight.isAcceptableOrUnknown(
          data['approximate_height']!,
          _approximateHeightMeta,
        ),
      );
    }
    if (data.containsKey('leaf_length')) {
      context.handle(
        _leafLengthMeta,
        leafLength.isAcceptableOrUnknown(data['leaf_length']!, _leafLengthMeta),
      );
    }
    if (data.containsKey('leaf_shape')) {
      context.handle(
        _leafShapeMeta,
        leafShape.isAcceptableOrUnknown(data['leaf_shape']!, _leafShapeMeta),
      );
    }
    if (data.containsKey('leaf_edge')) {
      context.handle(
        _leafEdgeMeta,
        leafEdge.isAcceptableOrUnknown(data['leaf_edge']!, _leafEdgeMeta),
      );
    }
    if (data.containsKey('leaf_texture')) {
      context.handle(
        _leafTextureMeta,
        leafTexture.isAcceptableOrUnknown(
          data['leaf_texture']!,
          _leafTextureMeta,
        ),
      );
    }
    if (data.containsKey('has_spines')) {
      context.handle(
        _hasSpinesMeta,
        hasSpines.isAcceptableOrUnknown(data['has_spines']!, _hasSpinesMeta),
      );
    }
    if (data.containsKey('spine_type')) {
      context.handle(
        _spineTypeMeta,
        spineType.isAcceptableOrUnknown(data['spine_type']!, _spineTypeMeta),
      );
    }
    if (data.containsKey('flower_grouping')) {
      context.handle(
        _flowerGroupingMeta,
        flowerGrouping.isAcceptableOrUnknown(
          data['flower_grouping']!,
          _flowerGroupingMeta,
        ),
      );
    }
    if (data.containsKey('petal_count')) {
      context.handle(
        _petalCountMeta,
        petalCount.isAcceptableOrUnknown(data['petal_count']!, _petalCountMeta),
      );
    }
    if (data.containsKey('flower_size')) {
      context.handle(
        _flowerSizeMeta,
        flowerSize.isAcceptableOrUnknown(data['flower_size']!, _flowerSizeMeta),
      );
    }
    if (data.containsKey('has_fruit')) {
      context.handle(
        _hasFruitMeta,
        hasFruit.isAcceptableOrUnknown(data['has_fruit']!, _hasFruitMeta),
      );
    }
    if (data.containsKey('fruit_shape')) {
      context.handle(
        _fruitShapeMeta,
        fruitShape.isAcceptableOrUnknown(data['fruit_shape']!, _fruitShapeMeta),
      );
    }
    if (data.containsKey('fruit_color')) {
      context.handle(
        _fruitColorMeta,
        fruitColor.isAcceptableOrUnknown(data['fruit_color']!, _fruitColorMeta),
      );
    }
    if (data.containsKey('fruit_size')) {
      context.handle(
        _fruitSizeMeta,
        fruitSize.isAcceptableOrUnknown(data['fruit_size']!, _fruitSizeMeta),
      );
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Specy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Specy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      commonName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_name'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      habitat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitat'],
      )!,
      flowerColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flower_color'],
      )!,
      biologicalForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}biological_form'],
      )!,
      approximateHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approximate_height'],
      )!,
      leafLength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaf_length'],
      )!,
      leafShape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaf_shape'],
      )!,
      leafEdge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaf_edge'],
      )!,
      leafTexture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaf_texture'],
      )!,
      hasSpines: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_spines'],
      )!,
      spineType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spine_type'],
      )!,
      flowerGrouping: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flower_grouping'],
      )!,
      petalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}petal_count'],
      )!,
      flowerSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flower_size'],
      )!,
      hasFruit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_fruit'],
      )!,
      fruitShape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fruit_shape'],
      )!,
      fruitColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fruit_color'],
      )!,
      fruitSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fruit_size'],
      )!,
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SpeciesTable createAlias(String alias) {
    return $SpeciesTable(attachedDatabase, alias);
  }
}

class Specy extends DataClass implements Insertable<Specy> {
  final String id;
  final String commonName;
  final String scientificName;
  final String description;
  final String imageUrl;
  final String family;
  final String habitat;
  final String flowerColor;
  final String biologicalForm;
  final String approximateHeight;
  final String leafLength;
  final String leafShape;
  final String leafEdge;
  final String leafTexture;
  final bool hasSpines;
  final String spineType;
  final String flowerGrouping;
  final String petalCount;
  final String flowerSize;
  final bool hasFruit;
  final String fruitShape;
  final String fruitColor;
  final String fruitSize;
  final String observations;
  final bool isActive;
  final String syncStatus;
  final DateTime createdAt;
  const Specy({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.description,
    required this.imageUrl,
    required this.family,
    required this.habitat,
    required this.flowerColor,
    required this.biologicalForm,
    required this.approximateHeight,
    required this.leafLength,
    required this.leafShape,
    required this.leafEdge,
    required this.leafTexture,
    required this.hasSpines,
    required this.spineType,
    required this.flowerGrouping,
    required this.petalCount,
    required this.flowerSize,
    required this.hasFruit,
    required this.fruitShape,
    required this.fruitColor,
    required this.fruitSize,
    required this.observations,
    required this.isActive,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['common_name'] = Variable<String>(commonName);
    map['scientific_name'] = Variable<String>(scientificName);
    map['description'] = Variable<String>(description);
    map['image_url'] = Variable<String>(imageUrl);
    map['family'] = Variable<String>(family);
    map['habitat'] = Variable<String>(habitat);
    map['flower_color'] = Variable<String>(flowerColor);
    map['biological_form'] = Variable<String>(biologicalForm);
    map['approximate_height'] = Variable<String>(approximateHeight);
    map['leaf_length'] = Variable<String>(leafLength);
    map['leaf_shape'] = Variable<String>(leafShape);
    map['leaf_edge'] = Variable<String>(leafEdge);
    map['leaf_texture'] = Variable<String>(leafTexture);
    map['has_spines'] = Variable<bool>(hasSpines);
    map['spine_type'] = Variable<String>(spineType);
    map['flower_grouping'] = Variable<String>(flowerGrouping);
    map['petal_count'] = Variable<String>(petalCount);
    map['flower_size'] = Variable<String>(flowerSize);
    map['has_fruit'] = Variable<bool>(hasFruit);
    map['fruit_shape'] = Variable<String>(fruitShape);
    map['fruit_color'] = Variable<String>(fruitColor);
    map['fruit_size'] = Variable<String>(fruitSize);
    map['observations'] = Variable<String>(observations);
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SpeciesCompanion toCompanion(bool nullToAbsent) {
    return SpeciesCompanion(
      id: Value(id),
      commonName: Value(commonName),
      scientificName: Value(scientificName),
      description: Value(description),
      imageUrl: Value(imageUrl),
      family: Value(family),
      habitat: Value(habitat),
      flowerColor: Value(flowerColor),
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
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory Specy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Specy(
      id: serializer.fromJson<String>(json['id']),
      commonName: serializer.fromJson<String>(json['commonName']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      description: serializer.fromJson<String>(json['description']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      family: serializer.fromJson<String>(json['family']),
      habitat: serializer.fromJson<String>(json['habitat']),
      flowerColor: serializer.fromJson<String>(json['flowerColor']),
      biologicalForm: serializer.fromJson<String>(json['biologicalForm']),
      approximateHeight: serializer.fromJson<String>(json['approximateHeight']),
      leafLength: serializer.fromJson<String>(json['leafLength']),
      leafShape: serializer.fromJson<String>(json['leafShape']),
      leafEdge: serializer.fromJson<String>(json['leafEdge']),
      leafTexture: serializer.fromJson<String>(json['leafTexture']),
      hasSpines: serializer.fromJson<bool>(json['hasSpines']),
      spineType: serializer.fromJson<String>(json['spineType']),
      flowerGrouping: serializer.fromJson<String>(json['flowerGrouping']),
      petalCount: serializer.fromJson<String>(json['petalCount']),
      flowerSize: serializer.fromJson<String>(json['flowerSize']),
      hasFruit: serializer.fromJson<bool>(json['hasFruit']),
      fruitShape: serializer.fromJson<String>(json['fruitShape']),
      fruitColor: serializer.fromJson<String>(json['fruitColor']),
      fruitSize: serializer.fromJson<String>(json['fruitSize']),
      observations: serializer.fromJson<String>(json['observations']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'commonName': serializer.toJson<String>(commonName),
      'scientificName': serializer.toJson<String>(scientificName),
      'description': serializer.toJson<String>(description),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'family': serializer.toJson<String>(family),
      'habitat': serializer.toJson<String>(habitat),
      'flowerColor': serializer.toJson<String>(flowerColor),
      'biologicalForm': serializer.toJson<String>(biologicalForm),
      'approximateHeight': serializer.toJson<String>(approximateHeight),
      'leafLength': serializer.toJson<String>(leafLength),
      'leafShape': serializer.toJson<String>(leafShape),
      'leafEdge': serializer.toJson<String>(leafEdge),
      'leafTexture': serializer.toJson<String>(leafTexture),
      'hasSpines': serializer.toJson<bool>(hasSpines),
      'spineType': serializer.toJson<String>(spineType),
      'flowerGrouping': serializer.toJson<String>(flowerGrouping),
      'petalCount': serializer.toJson<String>(petalCount),
      'flowerSize': serializer.toJson<String>(flowerSize),
      'hasFruit': serializer.toJson<bool>(hasFruit),
      'fruitShape': serializer.toJson<String>(fruitShape),
      'fruitColor': serializer.toJson<String>(fruitColor),
      'fruitSize': serializer.toJson<String>(fruitSize),
      'observations': serializer.toJson<String>(observations),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Specy copyWith({
    String? id,
    String? commonName,
    String? scientificName,
    String? description,
    String? imageUrl,
    String? family,
    String? habitat,
    String? flowerColor,
    String? biologicalForm,
    String? approximateHeight,
    String? leafLength,
    String? leafShape,
    String? leafEdge,
    String? leafTexture,
    bool? hasSpines,
    String? spineType,
    String? flowerGrouping,
    String? petalCount,
    String? flowerSize,
    bool? hasFruit,
    String? fruitShape,
    String? fruitColor,
    String? fruitSize,
    String? observations,
    bool? isActive,
    String? syncStatus,
    DateTime? createdAt,
  }) => Specy(
    id: id ?? this.id,
    commonName: commonName ?? this.commonName,
    scientificName: scientificName ?? this.scientificName,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    family: family ?? this.family,
    habitat: habitat ?? this.habitat,
    flowerColor: flowerColor ?? this.flowerColor,
    biologicalForm: biologicalForm ?? this.biologicalForm,
    approximateHeight: approximateHeight ?? this.approximateHeight,
    leafLength: leafLength ?? this.leafLength,
    leafShape: leafShape ?? this.leafShape,
    leafEdge: leafEdge ?? this.leafEdge,
    leafTexture: leafTexture ?? this.leafTexture,
    hasSpines: hasSpines ?? this.hasSpines,
    spineType: spineType ?? this.spineType,
    flowerGrouping: flowerGrouping ?? this.flowerGrouping,
    petalCount: petalCount ?? this.petalCount,
    flowerSize: flowerSize ?? this.flowerSize,
    hasFruit: hasFruit ?? this.hasFruit,
    fruitShape: fruitShape ?? this.fruitShape,
    fruitColor: fruitColor ?? this.fruitColor,
    fruitSize: fruitSize ?? this.fruitSize,
    observations: observations ?? this.observations,
    isActive: isActive ?? this.isActive,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  Specy copyWithCompanion(SpeciesCompanion data) {
    return Specy(
      id: data.id.present ? data.id.value : this.id,
      commonName: data.commonName.present
          ? data.commonName.value
          : this.commonName,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      family: data.family.present ? data.family.value : this.family,
      habitat: data.habitat.present ? data.habitat.value : this.habitat,
      flowerColor: data.flowerColor.present
          ? data.flowerColor.value
          : this.flowerColor,
      biologicalForm: data.biologicalForm.present
          ? data.biologicalForm.value
          : this.biologicalForm,
      approximateHeight: data.approximateHeight.present
          ? data.approximateHeight.value
          : this.approximateHeight,
      leafLength: data.leafLength.present
          ? data.leafLength.value
          : this.leafLength,
      leafShape: data.leafShape.present ? data.leafShape.value : this.leafShape,
      leafEdge: data.leafEdge.present ? data.leafEdge.value : this.leafEdge,
      leafTexture: data.leafTexture.present
          ? data.leafTexture.value
          : this.leafTexture,
      hasSpines: data.hasSpines.present ? data.hasSpines.value : this.hasSpines,
      spineType: data.spineType.present ? data.spineType.value : this.spineType,
      flowerGrouping: data.flowerGrouping.present
          ? data.flowerGrouping.value
          : this.flowerGrouping,
      petalCount: data.petalCount.present
          ? data.petalCount.value
          : this.petalCount,
      flowerSize: data.flowerSize.present
          ? data.flowerSize.value
          : this.flowerSize,
      hasFruit: data.hasFruit.present ? data.hasFruit.value : this.hasFruit,
      fruitShape: data.fruitShape.present
          ? data.fruitShape.value
          : this.fruitShape,
      fruitColor: data.fruitColor.present
          ? data.fruitColor.value
          : this.fruitColor,
      fruitSize: data.fruitSize.present ? data.fruitSize.value : this.fruitSize,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Specy(')
          ..write('id: $id, ')
          ..write('commonName: $commonName, ')
          ..write('scientificName: $scientificName, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('family: $family, ')
          ..write('habitat: $habitat, ')
          ..write('flowerColor: $flowerColor, ')
          ..write('biologicalForm: $biologicalForm, ')
          ..write('approximateHeight: $approximateHeight, ')
          ..write('leafLength: $leafLength, ')
          ..write('leafShape: $leafShape, ')
          ..write('leafEdge: $leafEdge, ')
          ..write('leafTexture: $leafTexture, ')
          ..write('hasSpines: $hasSpines, ')
          ..write('spineType: $spineType, ')
          ..write('flowerGrouping: $flowerGrouping, ')
          ..write('petalCount: $petalCount, ')
          ..write('flowerSize: $flowerSize, ')
          ..write('hasFruit: $hasFruit, ')
          ..write('fruitShape: $fruitShape, ')
          ..write('fruitColor: $fruitColor, ')
          ..write('fruitSize: $fruitSize, ')
          ..write('observations: $observations, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    commonName,
    scientificName,
    description,
    imageUrl,
    family,
    habitat,
    flowerColor,
    biologicalForm,
    approximateHeight,
    leafLength,
    leafShape,
    leafEdge,
    leafTexture,
    hasSpines,
    spineType,
    flowerGrouping,
    petalCount,
    flowerSize,
    hasFruit,
    fruitShape,
    fruitColor,
    fruitSize,
    observations,
    isActive,
    syncStatus,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Specy &&
          other.id == this.id &&
          other.commonName == this.commonName &&
          other.scientificName == this.scientificName &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.family == this.family &&
          other.habitat == this.habitat &&
          other.flowerColor == this.flowerColor &&
          other.biologicalForm == this.biologicalForm &&
          other.approximateHeight == this.approximateHeight &&
          other.leafLength == this.leafLength &&
          other.leafShape == this.leafShape &&
          other.leafEdge == this.leafEdge &&
          other.leafTexture == this.leafTexture &&
          other.hasSpines == this.hasSpines &&
          other.spineType == this.spineType &&
          other.flowerGrouping == this.flowerGrouping &&
          other.petalCount == this.petalCount &&
          other.flowerSize == this.flowerSize &&
          other.hasFruit == this.hasFruit &&
          other.fruitShape == this.fruitShape &&
          other.fruitColor == this.fruitColor &&
          other.fruitSize == this.fruitSize &&
          other.observations == this.observations &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class SpeciesCompanion extends UpdateCompanion<Specy> {
  final Value<String> id;
  final Value<String> commonName;
  final Value<String> scientificName;
  final Value<String> description;
  final Value<String> imageUrl;
  final Value<String> family;
  final Value<String> habitat;
  final Value<String> flowerColor;
  final Value<String> biologicalForm;
  final Value<String> approximateHeight;
  final Value<String> leafLength;
  final Value<String> leafShape;
  final Value<String> leafEdge;
  final Value<String> leafTexture;
  final Value<bool> hasSpines;
  final Value<String> spineType;
  final Value<String> flowerGrouping;
  final Value<String> petalCount;
  final Value<String> flowerSize;
  final Value<bool> hasFruit;
  final Value<String> fruitShape;
  final Value<String> fruitColor;
  final Value<String> fruitSize;
  final Value<String> observations;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SpeciesCompanion({
    this.id = const Value.absent(),
    this.commonName = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.family = const Value.absent(),
    this.habitat = const Value.absent(),
    this.flowerColor = const Value.absent(),
    this.biologicalForm = const Value.absent(),
    this.approximateHeight = const Value.absent(),
    this.leafLength = const Value.absent(),
    this.leafShape = const Value.absent(),
    this.leafEdge = const Value.absent(),
    this.leafTexture = const Value.absent(),
    this.hasSpines = const Value.absent(),
    this.spineType = const Value.absent(),
    this.flowerGrouping = const Value.absent(),
    this.petalCount = const Value.absent(),
    this.flowerSize = const Value.absent(),
    this.hasFruit = const Value.absent(),
    this.fruitShape = const Value.absent(),
    this.fruitColor = const Value.absent(),
    this.fruitSize = const Value.absent(),
    this.observations = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeciesCompanion.insert({
    required String id,
    required String commonName,
    required String scientificName,
    required String description,
    this.imageUrl = const Value.absent(),
    this.family = const Value.absent(),
    this.habitat = const Value.absent(),
    this.flowerColor = const Value.absent(),
    this.biologicalForm = const Value.absent(),
    this.approximateHeight = const Value.absent(),
    this.leafLength = const Value.absent(),
    this.leafShape = const Value.absent(),
    this.leafEdge = const Value.absent(),
    this.leafTexture = const Value.absent(),
    this.hasSpines = const Value.absent(),
    this.spineType = const Value.absent(),
    this.flowerGrouping = const Value.absent(),
    this.petalCount = const Value.absent(),
    this.flowerSize = const Value.absent(),
    this.hasFruit = const Value.absent(),
    this.fruitShape = const Value.absent(),
    this.fruitColor = const Value.absent(),
    this.fruitSize = const Value.absent(),
    this.observations = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       commonName = Value(commonName),
       scientificName = Value(scientificName),
       description = Value(description);
  static Insertable<Specy> custom({
    Expression<String>? id,
    Expression<String>? commonName,
    Expression<String>? scientificName,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? family,
    Expression<String>? habitat,
    Expression<String>? flowerColor,
    Expression<String>? biologicalForm,
    Expression<String>? approximateHeight,
    Expression<String>? leafLength,
    Expression<String>? leafShape,
    Expression<String>? leafEdge,
    Expression<String>? leafTexture,
    Expression<bool>? hasSpines,
    Expression<String>? spineType,
    Expression<String>? flowerGrouping,
    Expression<String>? petalCount,
    Expression<String>? flowerSize,
    Expression<bool>? hasFruit,
    Expression<String>? fruitShape,
    Expression<String>? fruitColor,
    Expression<String>? fruitSize,
    Expression<String>? observations,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commonName != null) 'common_name': commonName,
      if (scientificName != null) 'scientific_name': scientificName,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (family != null) 'family': family,
      if (habitat != null) 'habitat': habitat,
      if (flowerColor != null) 'flower_color': flowerColor,
      if (biologicalForm != null) 'biological_form': biologicalForm,
      if (approximateHeight != null) 'approximate_height': approximateHeight,
      if (leafLength != null) 'leaf_length': leafLength,
      if (leafShape != null) 'leaf_shape': leafShape,
      if (leafEdge != null) 'leaf_edge': leafEdge,
      if (leafTexture != null) 'leaf_texture': leafTexture,
      if (hasSpines != null) 'has_spines': hasSpines,
      if (spineType != null) 'spine_type': spineType,
      if (flowerGrouping != null) 'flower_grouping': flowerGrouping,
      if (petalCount != null) 'petal_count': petalCount,
      if (flowerSize != null) 'flower_size': flowerSize,
      if (hasFruit != null) 'has_fruit': hasFruit,
      if (fruitShape != null) 'fruit_shape': fruitShape,
      if (fruitColor != null) 'fruit_color': fruitColor,
      if (fruitSize != null) 'fruit_size': fruitSize,
      if (observations != null) 'observations': observations,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeciesCompanion copyWith({
    Value<String>? id,
    Value<String>? commonName,
    Value<String>? scientificName,
    Value<String>? description,
    Value<String>? imageUrl,
    Value<String>? family,
    Value<String>? habitat,
    Value<String>? flowerColor,
    Value<String>? biologicalForm,
    Value<String>? approximateHeight,
    Value<String>? leafLength,
    Value<String>? leafShape,
    Value<String>? leafEdge,
    Value<String>? leafTexture,
    Value<bool>? hasSpines,
    Value<String>? spineType,
    Value<String>? flowerGrouping,
    Value<String>? petalCount,
    Value<String>? flowerSize,
    Value<bool>? hasFruit,
    Value<String>? fruitShape,
    Value<String>? fruitColor,
    Value<String>? fruitSize,
    Value<String>? observations,
    Value<bool>? isActive,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SpeciesCompanion(
      id: id ?? this.id,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      family: family ?? this.family,
      habitat: habitat ?? this.habitat,
      flowerColor: flowerColor ?? this.flowerColor,
      biologicalForm: biologicalForm ?? this.biologicalForm,
      approximateHeight: approximateHeight ?? this.approximateHeight,
      leafLength: leafLength ?? this.leafLength,
      leafShape: leafShape ?? this.leafShape,
      leafEdge: leafEdge ?? this.leafEdge,
      leafTexture: leafTexture ?? this.leafTexture,
      hasSpines: hasSpines ?? this.hasSpines,
      spineType: spineType ?? this.spineType,
      flowerGrouping: flowerGrouping ?? this.flowerGrouping,
      petalCount: petalCount ?? this.petalCount,
      flowerSize: flowerSize ?? this.flowerSize,
      hasFruit: hasFruit ?? this.hasFruit,
      fruitShape: fruitShape ?? this.fruitShape,
      fruitColor: fruitColor ?? this.fruitColor,
      fruitSize: fruitSize ?? this.fruitSize,
      observations: observations ?? this.observations,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (commonName.present) {
      map['common_name'] = Variable<String>(commonName.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (habitat.present) {
      map['habitat'] = Variable<String>(habitat.value);
    }
    if (flowerColor.present) {
      map['flower_color'] = Variable<String>(flowerColor.value);
    }
    if (biologicalForm.present) {
      map['biological_form'] = Variable<String>(biologicalForm.value);
    }
    if (approximateHeight.present) {
      map['approximate_height'] = Variable<String>(approximateHeight.value);
    }
    if (leafLength.present) {
      map['leaf_length'] = Variable<String>(leafLength.value);
    }
    if (leafShape.present) {
      map['leaf_shape'] = Variable<String>(leafShape.value);
    }
    if (leafEdge.present) {
      map['leaf_edge'] = Variable<String>(leafEdge.value);
    }
    if (leafTexture.present) {
      map['leaf_texture'] = Variable<String>(leafTexture.value);
    }
    if (hasSpines.present) {
      map['has_spines'] = Variable<bool>(hasSpines.value);
    }
    if (spineType.present) {
      map['spine_type'] = Variable<String>(spineType.value);
    }
    if (flowerGrouping.present) {
      map['flower_grouping'] = Variable<String>(flowerGrouping.value);
    }
    if (petalCount.present) {
      map['petal_count'] = Variable<String>(petalCount.value);
    }
    if (flowerSize.present) {
      map['flower_size'] = Variable<String>(flowerSize.value);
    }
    if (hasFruit.present) {
      map['has_fruit'] = Variable<bool>(hasFruit.value);
    }
    if (fruitShape.present) {
      map['fruit_shape'] = Variable<String>(fruitShape.value);
    }
    if (fruitColor.present) {
      map['fruit_color'] = Variable<String>(fruitColor.value);
    }
    if (fruitSize.present) {
      map['fruit_size'] = Variable<String>(fruitSize.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesCompanion(')
          ..write('id: $id, ')
          ..write('commonName: $commonName, ')
          ..write('scientificName: $scientificName, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('family: $family, ')
          ..write('habitat: $habitat, ')
          ..write('flowerColor: $flowerColor, ')
          ..write('biologicalForm: $biologicalForm, ')
          ..write('approximateHeight: $approximateHeight, ')
          ..write('leafLength: $leafLength, ')
          ..write('leafShape: $leafShape, ')
          ..write('leafEdge: $leafEdge, ')
          ..write('leafTexture: $leafTexture, ')
          ..write('hasSpines: $hasSpines, ')
          ..write('spineType: $spineType, ')
          ..write('flowerGrouping: $flowerGrouping, ')
          ..write('petalCount: $petalCount, ')
          ..write('flowerSize: $flowerSize, ')
          ..write('hasFruit: $hasFruit, ')
          ..write('fruitShape: $fruitShape, ')
          ..write('fruitColor: $fruitColor, ')
          ..write('fruitSize: $fruitSize, ')
          ..write('observations: $observations, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionText,
    orderIndex,
    isActive,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Question> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final String id;
  final String questionText;
  final int orderIndex;
  final bool isActive;
  final String syncStatus;
  const Question({
    required this.id,
    required this.questionText,
    required this.orderIndex,
    required this.isActive,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_text'] = Variable<String>(questionText);
    map['order_index'] = Variable<int>(orderIndex);
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      questionText: Value(questionText),
      orderIndex: Value(orderIndex),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
    );
  }

  factory Question.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<String>(json['id']),
      questionText: serializer.fromJson<String>(json['questionText']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionText': serializer.toJson<String>(questionText),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Question copyWith({
    String? id,
    String? questionText,
    int? orderIndex,
    bool? isActive,
    String? syncStatus,
  }) => Question(
    id: id ?? this.id,
    questionText: questionText ?? this.questionText,
    orderIndex: orderIndex ?? this.orderIndex,
    isActive: isActive ?? this.isActive,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('questionText: $questionText, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, questionText, orderIndex, isActive, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.questionText == this.questionText &&
          other.orderIndex == this.orderIndex &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<String> id;
  final Value<String> questionText;
  final Value<int> orderIndex;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.questionText = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionsCompanion.insert({
    required String id,
    required String questionText,
    required int orderIndex,
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questionText = Value(questionText),
       orderIndex = Value(orderIndex);
  static Insertable<Question> custom({
    Expression<String>? id,
    Expression<String>? questionText,
    Expression<int>? orderIndex,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionText != null) 'question_text': questionText,
      if (orderIndex != null) 'order_index': orderIndex,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? questionText,
    Value<int>? orderIndex,
    Value<bool>? isActive,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return QuestionsCompanion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('questionText: $questionText, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionOptionsTable extends QuestionOptions
    with TableInfo<$QuestionOptionsTable, QuestionOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionTextMeta = const VerificationMeta(
    'optionText',
  );
  @override
  late final GeneratedColumn<String> optionText = GeneratedColumn<String>(
    'option_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionId,
    optionText,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('option_text')) {
      context.handle(
        _optionTextMeta,
        optionText.isAcceptableOrUnknown(data['option_text']!, _optionTextMeta),
      );
    } else if (isInserting) {
      context.missing(_optionTextMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      optionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_text'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $QuestionOptionsTable createAlias(String alias) {
    return $QuestionOptionsTable(attachedDatabase, alias);
  }
}

class QuestionOption extends DataClass implements Insertable<QuestionOption> {
  final String id;
  final String questionId;
  final String optionText;
  final int orderIndex;
  const QuestionOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_id'] = Variable<String>(questionId);
    map['option_text'] = Variable<String>(optionText);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  QuestionOptionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionOptionsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      optionText: Value(optionText),
      orderIndex: Value(orderIndex),
    );
  }

  factory QuestionOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionOption(
      id: serializer.fromJson<String>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      optionText: serializer.fromJson<String>(json['optionText']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionId': serializer.toJson<String>(questionId),
      'optionText': serializer.toJson<String>(optionText),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  QuestionOption copyWith({
    String? id,
    String? questionId,
    String? optionText,
    int? orderIndex,
  }) => QuestionOption(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    optionText: optionText ?? this.optionText,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  QuestionOption copyWithCompanion(QuestionOptionsCompanion data) {
    return QuestionOption(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      optionText: data.optionText.present
          ? data.optionText.value
          : this.optionText,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionOption(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('optionText: $optionText, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, optionText, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionOption &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.optionText == this.optionText &&
          other.orderIndex == this.orderIndex);
}

class QuestionOptionsCompanion extends UpdateCompanion<QuestionOption> {
  final Value<String> id;
  final Value<String> questionId;
  final Value<String> optionText;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const QuestionOptionsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.optionText = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionOptionsCompanion.insert({
    required String id,
    required String questionId,
    required String optionText,
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questionId = Value(questionId),
       optionText = Value(optionText);
  static Insertable<QuestionOption> custom({
    Expression<String>? id,
    Expression<String>? questionId,
    Expression<String>? optionText,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (optionText != null) 'option_text': optionText,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? questionId,
    Value<String>? optionText,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return QuestionOptionsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      optionText: optionText ?? this.optionText,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (optionText.present) {
      map['option_text'] = Variable<String>(optionText.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionOptionsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('optionText: $optionText, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpeciesTraitsTable extends SpeciesTraits
    with TableInfo<$SpeciesTraitsTable, SpeciesTrait> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesTraitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionIdMeta = const VerificationMeta(
    'optionId',
  );
  @override
  late final GeneratedColumn<String> optionId = GeneratedColumn<String>(
    'option_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, speciesId, questionId, optionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_traits';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesTrait> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('option_id')) {
      context.handle(
        _optionIdMeta,
        optionId.isAcceptableOrUnknown(data['option_id']!, _optionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_optionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesTrait map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesTrait(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      optionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_id'],
      )!,
    );
  }

  @override
  $SpeciesTraitsTable createAlias(String alias) {
    return $SpeciesTraitsTable(attachedDatabase, alias);
  }
}

class SpeciesTrait extends DataClass implements Insertable<SpeciesTrait> {
  final String id;
  final String speciesId;
  final String questionId;
  final String optionId;
  const SpeciesTrait({
    required this.id,
    required this.speciesId,
    required this.questionId,
    required this.optionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['species_id'] = Variable<String>(speciesId);
    map['question_id'] = Variable<String>(questionId);
    map['option_id'] = Variable<String>(optionId);
    return map;
  }

  SpeciesTraitsCompanion toCompanion(bool nullToAbsent) {
    return SpeciesTraitsCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      questionId: Value(questionId),
      optionId: Value(optionId),
    );
  }

  factory SpeciesTrait.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesTrait(
      id: serializer.fromJson<String>(json['id']),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      optionId: serializer.fromJson<String>(json['optionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'speciesId': serializer.toJson<String>(speciesId),
      'questionId': serializer.toJson<String>(questionId),
      'optionId': serializer.toJson<String>(optionId),
    };
  }

  SpeciesTrait copyWith({
    String? id,
    String? speciesId,
    String? questionId,
    String? optionId,
  }) => SpeciesTrait(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    questionId: questionId ?? this.questionId,
    optionId: optionId ?? this.optionId,
  );
  SpeciesTrait copyWithCompanion(SpeciesTraitsCompanion data) {
    return SpeciesTrait(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      optionId: data.optionId.present ? data.optionId.value : this.optionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesTrait(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('questionId: $questionId, ')
          ..write('optionId: $optionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, speciesId, questionId, optionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesTrait &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.questionId == this.questionId &&
          other.optionId == this.optionId);
}

class SpeciesTraitsCompanion extends UpdateCompanion<SpeciesTrait> {
  final Value<String> id;
  final Value<String> speciesId;
  final Value<String> questionId;
  final Value<String> optionId;
  final Value<int> rowid;
  const SpeciesTraitsCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.optionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeciesTraitsCompanion.insert({
    required String id,
    required String speciesId,
    required String questionId,
    required String optionId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       speciesId = Value(speciesId),
       questionId = Value(questionId),
       optionId = Value(optionId);
  static Insertable<SpeciesTrait> custom({
    Expression<String>? id,
    Expression<String>? speciesId,
    Expression<String>? questionId,
    Expression<String>? optionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (questionId != null) 'question_id': questionId,
      if (optionId != null) 'option_id': optionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeciesTraitsCompanion copyWith({
    Value<String>? id,
    Value<String>? speciesId,
    Value<String>? questionId,
    Value<String>? optionId,
    Value<int>? rowid,
  }) {
    return SpeciesTraitsCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      questionId: questionId ?? this.questionId,
      optionId: optionId ?? this.optionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (optionId.present) {
      map['option_id'] = Variable<String>(optionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesTraitsCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('questionId: $questionId, ')
          ..write('optionId: $optionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<String> speciesId = GeneratedColumn<String>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    speciesId,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Observation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_id'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }
}

class Observation extends DataClass implements Insertable<Observation> {
  final String id;
  final String userId;
  final String speciesId;
  final String notes;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  const Observation({
    required this.id,
    required this.userId,
    required this.speciesId,
    required this.notes,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['species_id'] = Variable<String>(speciesId);
    map['notes'] = Variable<String>(notes);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      userId: Value(userId),
      speciesId: Value(speciesId),
      notes: Value(notes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory Observation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      speciesId: serializer.fromJson<String>(json['speciesId']),
      notes: serializer.fromJson<String>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'speciesId': serializer.toJson<String>(speciesId),
      'notes': serializer.toJson<String>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  Observation copyWith({
    String? id,
    String? userId,
    String? speciesId,
    String? notes,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => Observation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    speciesId: speciesId ?? this.speciesId,
    notes: notes ?? this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    speciesId,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.speciesId == this.speciesId &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> speciesId;
  final Value<String> notes;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    required String id,
    required String userId,
    required String speciesId,
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       speciesId = Value(speciesId);
  static Insertable<Observation> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? speciesId,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (speciesId != null) 'species_id': speciesId,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? speciesId,
    Value<String>? notes,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ObservationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesId: speciesId ?? this.speciesId,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<String>(speciesId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObservationPhotosTable extends ObservationPhotos
    with TableInfo<$ObservationPhotosTable, ObservationPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observationIdMeta = const VerificationMeta(
    'observationId',
  );
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
    'observation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plantPartMeta = const VerificationMeta(
    'plantPart',
  );
  @override
  late final GeneratedColumn<String> plantPart = GeneratedColumn<String>(
    'plant_part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('camera'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    observationId,
    photoPath,
    plantPart,
    latitude,
    longitude,
    altitude,
    accuracy,
    source,
    syncStatus,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observation_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObservationPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('observation_id')) {
      context.handle(
        _observationIdMeta,
        observationId.isAcceptableOrUnknown(
          data['observation_id']!,
          _observationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    } else if (isInserting) {
      context.missing(_photoPathMeta);
    }
    if (data.containsKey('plant_part')) {
      context.handle(
        _plantPartMeta,
        plantPart.isAcceptableOrUnknown(data['plant_part']!, _plantPartMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObservationPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObservationPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      observationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_id'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      )!,
      plantPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_part'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $ObservationPhotosTable createAlias(String alias) {
    return $ObservationPhotosTable(attachedDatabase, alias);
  }
}

class ObservationPhoto extends DataClass
    implements Insertable<ObservationPhoto> {
  final String id;
  final String observationId;
  final String photoPath;

  /// Parte de la planta: general, hoja, flor, espinas, fruto
  final String plantPart;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;

  /// Fuente de la foto: camera, gallery
  final String source;
  final String syncStatus;
  final DateTime capturedAt;
  const ObservationPhoto({
    required this.id,
    required this.observationId,
    required this.photoPath,
    required this.plantPart,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.source,
    required this.syncStatus,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['observation_id'] = Variable<String>(observationId);
    map['photo_path'] = Variable<String>(photoPath);
    map['plant_part'] = Variable<String>(plantPart);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['altitude'] = Variable<double>(altitude);
    map['accuracy'] = Variable<double>(accuracy);
    map['source'] = Variable<String>(source);
    map['sync_status'] = Variable<String>(syncStatus);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  ObservationPhotosCompanion toCompanion(bool nullToAbsent) {
    return ObservationPhotosCompanion(
      id: Value(id),
      observationId: Value(observationId),
      photoPath: Value(photoPath),
      plantPart: Value(plantPart),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: Value(altitude),
      accuracy: Value(accuracy),
      source: Value(source),
      syncStatus: Value(syncStatus),
      capturedAt: Value(capturedAt),
    );
  }

  factory ObservationPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObservationPhoto(
      id: serializer.fromJson<String>(json['id']),
      observationId: serializer.fromJson<String>(json['observationId']),
      photoPath: serializer.fromJson<String>(json['photoPath']),
      plantPart: serializer.fromJson<String>(json['plantPart']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double>(json['altitude']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      source: serializer.fromJson<String>(json['source']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'observationId': serializer.toJson<String>(observationId),
      'photoPath': serializer.toJson<String>(photoPath),
      'plantPart': serializer.toJson<String>(plantPart),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double>(altitude),
      'accuracy': serializer.toJson<double>(accuracy),
      'source': serializer.toJson<String>(source),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  ObservationPhoto copyWith({
    String? id,
    String? observationId,
    String? photoPath,
    String? plantPart,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    String? source,
    String? syncStatus,
    DateTime? capturedAt,
  }) => ObservationPhoto(
    id: id ?? this.id,
    observationId: observationId ?? this.observationId,
    photoPath: photoPath ?? this.photoPath,
    plantPart: plantPart ?? this.plantPart,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude ?? this.altitude,
    accuracy: accuracy ?? this.accuracy,
    source: source ?? this.source,
    syncStatus: syncStatus ?? this.syncStatus,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  ObservationPhoto copyWithCompanion(ObservationPhotosCompanion data) {
    return ObservationPhoto(
      id: data.id.present ? data.id.value : this.id,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      plantPart: data.plantPart.present ? data.plantPart.value : this.plantPart,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      source: data.source.present ? data.source.value : this.source,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObservationPhoto(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('photoPath: $photoPath, ')
          ..write('plantPart: $plantPart, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('source: $source, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    observationId,
    photoPath,
    plantPart,
    latitude,
    longitude,
    altitude,
    accuracy,
    source,
    syncStatus,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObservationPhoto &&
          other.id == this.id &&
          other.observationId == this.observationId &&
          other.photoPath == this.photoPath &&
          other.plantPart == this.plantPart &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.accuracy == this.accuracy &&
          other.source == this.source &&
          other.syncStatus == this.syncStatus &&
          other.capturedAt == this.capturedAt);
}

class ObservationPhotosCompanion extends UpdateCompanion<ObservationPhoto> {
  final Value<String> id;
  final Value<String> observationId;
  final Value<String> photoPath;
  final Value<String> plantPart;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> altitude;
  final Value<double> accuracy;
  final Value<String> source;
  final Value<String> syncStatus;
  final Value<DateTime> capturedAt;
  final Value<int> rowid;
  const ObservationPhotosCompanion({
    this.id = const Value.absent(),
    this.observationId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.plantPart = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.source = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationPhotosCompanion.insert({
    required String id,
    required String observationId,
    required String photoPath,
    this.plantPart = const Value.absent(),
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.source = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       observationId = Value(observationId),
       photoPath = Value(photoPath),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<ObservationPhoto> custom({
    Expression<String>? id,
    Expression<String>? observationId,
    Expression<String>? photoPath,
    Expression<String>? plantPart,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? accuracy,
    Expression<String>? source,
    Expression<String>? syncStatus,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (observationId != null) 'observation_id': observationId,
      if (photoPath != null) 'photo_path': photoPath,
      if (plantPart != null) 'plant_part': plantPart,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (source != null) 'source': source,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? observationId,
    Value<String>? photoPath,
    Value<String>? plantPart,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? altitude,
    Value<double>? accuracy,
    Value<String>? source,
    Value<String>? syncStatus,
    Value<DateTime>? capturedAt,
    Value<int>? rowid,
  }) {
    return ObservationPhotosCompanion(
      id: id ?? this.id,
      observationId: observationId ?? this.observationId,
      photoPath: photoPath ?? this.photoPath,
      plantPart: plantPart ?? this.plantPart,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (plantPart.present) {
      map['plant_part'] = Variable<String>(plantPart.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationPhotosCompanion(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('photoPath: $photoPath, ')
          ..write('plantPart: $plantPart, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('source: $source, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _totalObservationsMeta = const VerificationMeta(
    'totalObservations',
  );
  @override
  late final GeneratedColumn<int> totalObservations = GeneratedColumn<int>(
    'total_observations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speciesUnlockedMeta = const VerificationMeta(
    'speciesUnlocked',
  );
  @override
  late final GeneratedColumn<int> speciesUnlocked = GeneratedColumn<int>(
    'species_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    totalObservations,
    speciesUnlocked,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('total_observations')) {
      context.handle(
        _totalObservationsMeta,
        totalObservations.isAcceptableOrUnknown(
          data['total_observations']!,
          _totalObservationsMeta,
        ),
      );
    }
    if (data.containsKey('species_unlocked')) {
      context.handle(
        _speciesUnlockedMeta,
        speciesUnlocked.isAcceptableOrUnknown(
          data['species_unlocked']!,
          _speciesUnlockedMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      totalObservations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_observations'],
      )!,
      speciesUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_unlocked'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String name;
  final String email;
  final int totalObservations;
  final int speciesUnlocked;
  final String syncStatus;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.totalObservations,
    required this.speciesUnlocked,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['total_observations'] = Variable<int>(totalObservations);
    map['species_unlocked'] = Variable<int>(speciesUnlocked);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      totalObservations: Value(totalObservations),
      speciesUnlocked: Value(speciesUnlocked),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      totalObservations: serializer.fromJson<int>(json['totalObservations']),
      speciesUnlocked: serializer.fromJson<int>(json['speciesUnlocked']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'totalObservations': serializer.toJson<int>(totalObservations),
      'speciesUnlocked': serializer.toJson<int>(speciesUnlocked),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? totalObservations,
    int? speciesUnlocked,
    String? syncStatus,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    totalObservations: totalObservations ?? this.totalObservations,
    speciesUnlocked: speciesUnlocked ?? this.speciesUnlocked,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      totalObservations: data.totalObservations.present
          ? data.totalObservations.value
          : this.totalObservations,
      speciesUnlocked: data.speciesUnlocked.present
          ? data.speciesUnlocked.value
          : this.speciesUnlocked,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('totalObservations: $totalObservations, ')
          ..write('speciesUnlocked: $speciesUnlocked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    totalObservations,
    speciesUnlocked,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.totalObservations == this.totalObservations &&
          other.speciesUnlocked == this.speciesUnlocked &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<int> totalObservations;
  final Value<int> speciesUnlocked;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.totalObservations = const Value.absent(),
    this.speciesUnlocked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    this.totalObservations = const Value.absent(),
    this.speciesUnlocked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? totalObservations,
    Expression<int>? speciesUnlocked,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (totalObservations != null) 'total_observations': totalObservations,
      if (speciesUnlocked != null) 'species_unlocked': speciesUnlocked,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<int>? totalObservations,
    Value<int>? speciesUnlocked,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      totalObservations: totalObservations ?? this.totalObservations,
      speciesUnlocked: speciesUnlocked ?? this.speciesUnlocked,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (totalObservations.present) {
      map['total_observations'] = Variable<int>(totalObservations.value);
    }
    if (speciesUnlocked.present) {
      map['species_unlocked'] = Variable<int>(speciesUnlocked.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('totalObservations: $totalObservations, ')
          ..write('speciesUnlocked: $speciesUnlocked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SpeciesTable species = $SpeciesTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $QuestionOptionsTable questionOptions = $QuestionOptionsTable(
    this,
  );
  late final $SpeciesTraitsTable speciesTraits = $SpeciesTraitsTable(this);
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $ObservationPhotosTable observationPhotos =
      $ObservationPhotosTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    species,
    questions,
    questionOptions,
    speciesTraits,
    observations,
    observationPhotos,
    users,
  ];
}

typedef $$SpeciesTableCreateCompanionBuilder =
    SpeciesCompanion Function({
      required String id,
      required String commonName,
      required String scientificName,
      required String description,
      Value<String> imageUrl,
      Value<String> family,
      Value<String> habitat,
      Value<String> flowerColor,
      Value<String> biologicalForm,
      Value<String> approximateHeight,
      Value<String> leafLength,
      Value<String> leafShape,
      Value<String> leafEdge,
      Value<String> leafTexture,
      Value<bool> hasSpines,
      Value<String> spineType,
      Value<String> flowerGrouping,
      Value<String> petalCount,
      Value<String> flowerSize,
      Value<bool> hasFruit,
      Value<String> fruitShape,
      Value<String> fruitColor,
      Value<String> fruitSize,
      Value<String> observations,
      Value<bool> isActive,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SpeciesTableUpdateCompanionBuilder =
    SpeciesCompanion Function({
      Value<String> id,
      Value<String> commonName,
      Value<String> scientificName,
      Value<String> description,
      Value<String> imageUrl,
      Value<String> family,
      Value<String> habitat,
      Value<String> flowerColor,
      Value<String> biologicalForm,
      Value<String> approximateHeight,
      Value<String> leafLength,
      Value<String> leafShape,
      Value<String> leafEdge,
      Value<String> leafTexture,
      Value<bool> hasSpines,
      Value<String> spineType,
      Value<String> flowerGrouping,
      Value<String> petalCount,
      Value<String> flowerSize,
      Value<bool> hasFruit,
      Value<String> fruitShape,
      Value<String> fruitColor,
      Value<String> fruitSize,
      Value<String> observations,
      Value<bool> isActive,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SpeciesTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesTable> {
  $$SpeciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitat => $composableBuilder(
    column: $table.habitat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flowerColor => $composableBuilder(
    column: $table.flowerColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get biologicalForm => $composableBuilder(
    column: $table.biologicalForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approximateHeight => $composableBuilder(
    column: $table.approximateHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leafLength => $composableBuilder(
    column: $table.leafLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leafShape => $composableBuilder(
    column: $table.leafShape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leafEdge => $composableBuilder(
    column: $table.leafEdge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leafTexture => $composableBuilder(
    column: $table.leafTexture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasSpines => $composableBuilder(
    column: $table.hasSpines,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spineType => $composableBuilder(
    column: $table.spineType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flowerGrouping => $composableBuilder(
    column: $table.flowerGrouping,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get petalCount => $composableBuilder(
    column: $table.petalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flowerSize => $composableBuilder(
    column: $table.flowerSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasFruit => $composableBuilder(
    column: $table.hasFruit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fruitShape => $composableBuilder(
    column: $table.fruitShape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fruitColor => $composableBuilder(
    column: $table.fruitColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fruitSize => $composableBuilder(
    column: $table.fruitSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesTable> {
  $$SpeciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitat => $composableBuilder(
    column: $table.habitat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flowerColor => $composableBuilder(
    column: $table.flowerColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get biologicalForm => $composableBuilder(
    column: $table.biologicalForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approximateHeight => $composableBuilder(
    column: $table.approximateHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leafLength => $composableBuilder(
    column: $table.leafLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leafShape => $composableBuilder(
    column: $table.leafShape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leafEdge => $composableBuilder(
    column: $table.leafEdge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leafTexture => $composableBuilder(
    column: $table.leafTexture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSpines => $composableBuilder(
    column: $table.hasSpines,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spineType => $composableBuilder(
    column: $table.spineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flowerGrouping => $composableBuilder(
    column: $table.flowerGrouping,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get petalCount => $composableBuilder(
    column: $table.petalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flowerSize => $composableBuilder(
    column: $table.flowerSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasFruit => $composableBuilder(
    column: $table.hasFruit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fruitShape => $composableBuilder(
    column: $table.fruitShape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fruitColor => $composableBuilder(
    column: $table.fruitColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fruitSize => $composableBuilder(
    column: $table.fruitSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesTable> {
  $$SpeciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get habitat =>
      $composableBuilder(column: $table.habitat, builder: (column) => column);

  GeneratedColumn<String> get flowerColor => $composableBuilder(
    column: $table.flowerColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get biologicalForm => $composableBuilder(
    column: $table.biologicalForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get approximateHeight => $composableBuilder(
    column: $table.approximateHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leafLength => $composableBuilder(
    column: $table.leafLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leafShape =>
      $composableBuilder(column: $table.leafShape, builder: (column) => column);

  GeneratedColumn<String> get leafEdge =>
      $composableBuilder(column: $table.leafEdge, builder: (column) => column);

  GeneratedColumn<String> get leafTexture => $composableBuilder(
    column: $table.leafTexture,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasSpines =>
      $composableBuilder(column: $table.hasSpines, builder: (column) => column);

  GeneratedColumn<String> get spineType =>
      $composableBuilder(column: $table.spineType, builder: (column) => column);

  GeneratedColumn<String> get flowerGrouping => $composableBuilder(
    column: $table.flowerGrouping,
    builder: (column) => column,
  );

  GeneratedColumn<String> get petalCount => $composableBuilder(
    column: $table.petalCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flowerSize => $composableBuilder(
    column: $table.flowerSize,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasFruit =>
      $composableBuilder(column: $table.hasFruit, builder: (column) => column);

  GeneratedColumn<String> get fruitShape => $composableBuilder(
    column: $table.fruitShape,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fruitColor => $composableBuilder(
    column: $table.fruitColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fruitSize =>
      $composableBuilder(column: $table.fruitSize, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SpeciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesTable,
          Specy,
          $$SpeciesTableFilterComposer,
          $$SpeciesTableOrderingComposer,
          $$SpeciesTableAnnotationComposer,
          $$SpeciesTableCreateCompanionBuilder,
          $$SpeciesTableUpdateCompanionBuilder,
          (Specy, BaseReferences<_$AppDatabase, $SpeciesTable, Specy>),
          Specy,
          PrefetchHooks Function()
        > {
  $$SpeciesTableTableManager(_$AppDatabase db, $SpeciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> commonName = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<String> habitat = const Value.absent(),
                Value<String> flowerColor = const Value.absent(),
                Value<String> biologicalForm = const Value.absent(),
                Value<String> approximateHeight = const Value.absent(),
                Value<String> leafLength = const Value.absent(),
                Value<String> leafShape = const Value.absent(),
                Value<String> leafEdge = const Value.absent(),
                Value<String> leafTexture = const Value.absent(),
                Value<bool> hasSpines = const Value.absent(),
                Value<String> spineType = const Value.absent(),
                Value<String> flowerGrouping = const Value.absent(),
                Value<String> petalCount = const Value.absent(),
                Value<String> flowerSize = const Value.absent(),
                Value<bool> hasFruit = const Value.absent(),
                Value<String> fruitShape = const Value.absent(),
                Value<String> fruitColor = const Value.absent(),
                Value<String> fruitSize = const Value.absent(),
                Value<String> observations = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeciesCompanion(
                id: id,
                commonName: commonName,
                scientificName: scientificName,
                description: description,
                imageUrl: imageUrl,
                family: family,
                habitat: habitat,
                flowerColor: flowerColor,
                biologicalForm: biologicalForm,
                approximateHeight: approximateHeight,
                leafLength: leafLength,
                leafShape: leafShape,
                leafEdge: leafEdge,
                leafTexture: leafTexture,
                hasSpines: hasSpines,
                spineType: spineType,
                flowerGrouping: flowerGrouping,
                petalCount: petalCount,
                flowerSize: flowerSize,
                hasFruit: hasFruit,
                fruitShape: fruitShape,
                fruitColor: fruitColor,
                fruitSize: fruitSize,
                observations: observations,
                isActive: isActive,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String commonName,
                required String scientificName,
                required String description,
                Value<String> imageUrl = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<String> habitat = const Value.absent(),
                Value<String> flowerColor = const Value.absent(),
                Value<String> biologicalForm = const Value.absent(),
                Value<String> approximateHeight = const Value.absent(),
                Value<String> leafLength = const Value.absent(),
                Value<String> leafShape = const Value.absent(),
                Value<String> leafEdge = const Value.absent(),
                Value<String> leafTexture = const Value.absent(),
                Value<bool> hasSpines = const Value.absent(),
                Value<String> spineType = const Value.absent(),
                Value<String> flowerGrouping = const Value.absent(),
                Value<String> petalCount = const Value.absent(),
                Value<String> flowerSize = const Value.absent(),
                Value<bool> hasFruit = const Value.absent(),
                Value<String> fruitShape = const Value.absent(),
                Value<String> fruitColor = const Value.absent(),
                Value<String> fruitSize = const Value.absent(),
                Value<String> observations = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeciesCompanion.insert(
                id: id,
                commonName: commonName,
                scientificName: scientificName,
                description: description,
                imageUrl: imageUrl,
                family: family,
                habitat: habitat,
                flowerColor: flowerColor,
                biologicalForm: biologicalForm,
                approximateHeight: approximateHeight,
                leafLength: leafLength,
                leafShape: leafShape,
                leafEdge: leafEdge,
                leafTexture: leafTexture,
                hasSpines: hasSpines,
                spineType: spineType,
                flowerGrouping: flowerGrouping,
                petalCount: petalCount,
                flowerSize: flowerSize,
                hasFruit: hasFruit,
                fruitShape: fruitShape,
                fruitColor: fruitColor,
                fruitSize: fruitSize,
                observations: observations,
                isActive: isActive,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesTable,
      Specy,
      $$SpeciesTableFilterComposer,
      $$SpeciesTableOrderingComposer,
      $$SpeciesTableAnnotationComposer,
      $$SpeciesTableCreateCompanionBuilder,
      $$SpeciesTableUpdateCompanionBuilder,
      (Specy, BaseReferences<_$AppDatabase, $SpeciesTable, Specy>),
      Specy,
      PrefetchHooks Function()
    >;
typedef $$QuestionsTableCreateCompanionBuilder =
    QuestionsCompanion Function({
      required String id,
      required String questionText,
      required int orderIndex,
      Value<bool> isActive,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$QuestionsTableUpdateCompanionBuilder =
    QuestionsCompanion Function({
      Value<String> id,
      Value<String> questionText,
      Value<int> orderIndex,
      Value<bool> isActive,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$QuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionsTable,
          Question,
          $$QuestionsTableFilterComposer,
          $$QuestionsTableOrderingComposer,
          $$QuestionsTableAnnotationComposer,
          $$QuestionsTableCreateCompanionBuilder,
          $$QuestionsTableUpdateCompanionBuilder,
          (Question, BaseReferences<_$AppDatabase, $QuestionsTable, Question>),
          Question,
          PrefetchHooks Function()
        > {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion(
                id: id,
                questionText: questionText,
                orderIndex: orderIndex,
                isActive: isActive,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questionText,
                required int orderIndex,
                Value<bool> isActive = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion.insert(
                id: id,
                questionText: questionText,
                orderIndex: orderIndex,
                isActive: isActive,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionsTable,
      Question,
      $$QuestionsTableFilterComposer,
      $$QuestionsTableOrderingComposer,
      $$QuestionsTableAnnotationComposer,
      $$QuestionsTableCreateCompanionBuilder,
      $$QuestionsTableUpdateCompanionBuilder,
      (Question, BaseReferences<_$AppDatabase, $QuestionsTable, Question>),
      Question,
      PrefetchHooks Function()
    >;
typedef $$QuestionOptionsTableCreateCompanionBuilder =
    QuestionOptionsCompanion Function({
      required String id,
      required String questionId,
      required String optionText,
      Value<int> orderIndex,
      Value<int> rowid,
    });
typedef $$QuestionOptionsTableUpdateCompanionBuilder =
    QuestionOptionsCompanion Function({
      Value<String> id,
      Value<String> questionId,
      Value<String> optionText,
      Value<int> orderIndex,
      Value<int> rowid,
    });

class $$QuestionOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionOptionsTable> {
  $$QuestionOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionOptionsTable> {
  $$QuestionOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionOptionsTable> {
  $$QuestionOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$QuestionOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionOptionsTable,
          QuestionOption,
          $$QuestionOptionsTableFilterComposer,
          $$QuestionOptionsTableOrderingComposer,
          $$QuestionOptionsTableAnnotationComposer,
          $$QuestionOptionsTableCreateCompanionBuilder,
          $$QuestionOptionsTableUpdateCompanionBuilder,
          (
            QuestionOption,
            BaseReferences<
              _$AppDatabase,
              $QuestionOptionsTable,
              QuestionOption
            >,
          ),
          QuestionOption,
          PrefetchHooks Function()
        > {
  $$QuestionOptionsTableTableManager(
    _$AppDatabase db,
    $QuestionOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> optionText = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionOptionsCompanion(
                id: id,
                questionId: questionId,
                optionText: optionText,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questionId,
                required String optionText,
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionOptionsCompanion.insert(
                id: id,
                questionId: questionId,
                optionText: optionText,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionOptionsTable,
      QuestionOption,
      $$QuestionOptionsTableFilterComposer,
      $$QuestionOptionsTableOrderingComposer,
      $$QuestionOptionsTableAnnotationComposer,
      $$QuestionOptionsTableCreateCompanionBuilder,
      $$QuestionOptionsTableUpdateCompanionBuilder,
      (
        QuestionOption,
        BaseReferences<_$AppDatabase, $QuestionOptionsTable, QuestionOption>,
      ),
      QuestionOption,
      PrefetchHooks Function()
    >;
typedef $$SpeciesTraitsTableCreateCompanionBuilder =
    SpeciesTraitsCompanion Function({
      required String id,
      required String speciesId,
      required String questionId,
      required String optionId,
      Value<int> rowid,
    });
typedef $$SpeciesTraitsTableUpdateCompanionBuilder =
    SpeciesTraitsCompanion Function({
      Value<String> id,
      Value<String> speciesId,
      Value<String> questionId,
      Value<String> optionId,
      Value<int> rowid,
    });

class $$SpeciesTraitsTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesTraitsTable> {
  $$SpeciesTraitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionId => $composableBuilder(
    column: $table.optionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesTraitsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesTraitsTable> {
  $$SpeciesTraitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionId => $composableBuilder(
    column: $table.optionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesTraitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesTraitsTable> {
  $$SpeciesTraitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionId =>
      $composableBuilder(column: $table.optionId, builder: (column) => column);
}

class $$SpeciesTraitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesTraitsTable,
          SpeciesTrait,
          $$SpeciesTraitsTableFilterComposer,
          $$SpeciesTraitsTableOrderingComposer,
          $$SpeciesTraitsTableAnnotationComposer,
          $$SpeciesTraitsTableCreateCompanionBuilder,
          $$SpeciesTraitsTableUpdateCompanionBuilder,
          (
            SpeciesTrait,
            BaseReferences<_$AppDatabase, $SpeciesTraitsTable, SpeciesTrait>,
          ),
          SpeciesTrait,
          PrefetchHooks Function()
        > {
  $$SpeciesTraitsTableTableManager(_$AppDatabase db, $SpeciesTraitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesTraitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesTraitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesTraitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> speciesId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> optionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeciesTraitsCompanion(
                id: id,
                speciesId: speciesId,
                questionId: questionId,
                optionId: optionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String speciesId,
                required String questionId,
                required String optionId,
                Value<int> rowid = const Value.absent(),
              }) => SpeciesTraitsCompanion.insert(
                id: id,
                speciesId: speciesId,
                questionId: questionId,
                optionId: optionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesTraitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesTraitsTable,
      SpeciesTrait,
      $$SpeciesTraitsTableFilterComposer,
      $$SpeciesTraitsTableOrderingComposer,
      $$SpeciesTraitsTableAnnotationComposer,
      $$SpeciesTraitsTableCreateCompanionBuilder,
      $$SpeciesTraitsTableUpdateCompanionBuilder,
      (
        SpeciesTrait,
        BaseReferences<_$AppDatabase, $SpeciesTraitsTable, SpeciesTrait>,
      ),
      SpeciesTrait,
      PrefetchHooks Function()
    >;
typedef $$ObservationsTableCreateCompanionBuilder =
    ObservationsCompanion Function({
      required String id,
      required String userId,
      required String speciesId,
      Value<String> notes,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ObservationsTableUpdateCompanionBuilder =
    ObservationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> speciesId,
      Value<String> notes,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesId => $composableBuilder(
    column: $table.speciesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObservationsTable,
          Observation,
          $$ObservationsTableFilterComposer,
          $$ObservationsTableOrderingComposer,
          $$ObservationsTableAnnotationComposer,
          $$ObservationsTableCreateCompanionBuilder,
          $$ObservationsTableUpdateCompanionBuilder,
          (
            Observation,
            BaseReferences<_$AppDatabase, $ObservationsTable, Observation>,
          ),
          Observation,
          PrefetchHooks Function()
        > {
  $$ObservationsTableTableManager(_$AppDatabase db, $ObservationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> speciesId = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion(
                id: id,
                userId: userId,
                speciesId: speciesId,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String speciesId,
                Value<String> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion.insert(
                id: id,
                userId: userId,
                speciesId: speciesId,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObservationsTable,
      Observation,
      $$ObservationsTableFilterComposer,
      $$ObservationsTableOrderingComposer,
      $$ObservationsTableAnnotationComposer,
      $$ObservationsTableCreateCompanionBuilder,
      $$ObservationsTableUpdateCompanionBuilder,
      (
        Observation,
        BaseReferences<_$AppDatabase, $ObservationsTable, Observation>,
      ),
      Observation,
      PrefetchHooks Function()
    >;
typedef $$ObservationPhotosTableCreateCompanionBuilder =
    ObservationPhotosCompanion Function({
      required String id,
      required String observationId,
      required String photoPath,
      Value<String> plantPart,
      required double latitude,
      required double longitude,
      Value<double> altitude,
      Value<double> accuracy,
      Value<String> source,
      Value<String> syncStatus,
      Value<DateTime> capturedAt,
      Value<int> rowid,
    });
typedef $$ObservationPhotosTableUpdateCompanionBuilder =
    ObservationPhotosCompanion Function({
      Value<String> id,
      Value<String> observationId,
      Value<String> photoPath,
      Value<String> plantPart,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> altitude,
      Value<double> accuracy,
      Value<String> source,
      Value<String> syncStatus,
      Value<DateTime> capturedAt,
      Value<int> rowid,
    });

class $$ObservationPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $ObservationPhotosTable> {
  $$ObservationPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observationId => $composableBuilder(
    column: $table.observationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantPart => $composableBuilder(
    column: $table.plantPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ObservationPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservationPhotosTable> {
  $$ObservationPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observationId => $composableBuilder(
    column: $table.observationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantPart => $composableBuilder(
    column: $table.plantPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObservationPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservationPhotosTable> {
  $$ObservationPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get observationId => $composableBuilder(
    column: $table.observationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get plantPart =>
      $composableBuilder(column: $table.plantPart, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );
}

class $$ObservationPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObservationPhotosTable,
          ObservationPhoto,
          $$ObservationPhotosTableFilterComposer,
          $$ObservationPhotosTableOrderingComposer,
          $$ObservationPhotosTableAnnotationComposer,
          $$ObservationPhotosTableCreateCompanionBuilder,
          $$ObservationPhotosTableUpdateCompanionBuilder,
          (
            ObservationPhoto,
            BaseReferences<
              _$AppDatabase,
              $ObservationPhotosTable,
              ObservationPhoto
            >,
          ),
          ObservationPhoto,
          PrefetchHooks Function()
        > {
  $$ObservationPhotosTableTableManager(
    _$AppDatabase db,
    $ObservationPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservationPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservationPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservationPhotosTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> observationId = const Value.absent(),
                Value<String> photoPath = const Value.absent(),
                Value<String> plantPart = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> altitude = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationPhotosCompanion(
                id: id,
                observationId: observationId,
                photoPath: photoPath,
                plantPart: plantPart,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                accuracy: accuracy,
                source: source,
                syncStatus: syncStatus,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String observationId,
                required String photoPath,
                Value<String> plantPart = const Value.absent(),
                required double latitude,
                required double longitude,
                Value<double> altitude = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationPhotosCompanion.insert(
                id: id,
                observationId: observationId,
                photoPath: photoPath,
                plantPart: plantPart,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                accuracy: accuracy,
                source: source,
                syncStatus: syncStatus,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ObservationPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObservationPhotosTable,
      ObservationPhoto,
      $$ObservationPhotosTableFilterComposer,
      $$ObservationPhotosTableOrderingComposer,
      $$ObservationPhotosTableAnnotationComposer,
      $$ObservationPhotosTableCreateCompanionBuilder,
      $$ObservationPhotosTableUpdateCompanionBuilder,
      (
        ObservationPhoto,
        BaseReferences<
          _$AppDatabase,
          $ObservationPhotosTable,
          ObservationPhoto
        >,
      ),
      ObservationPhoto,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String name,
      Value<String> email,
      Value<int> totalObservations,
      Value<int> speciesUnlocked,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<int> totalObservations,
      Value<int> speciesUnlocked,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalObservations => $composableBuilder(
    column: $table.totalObservations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speciesUnlocked => $composableBuilder(
    column: $table.speciesUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalObservations => $composableBuilder(
    column: $table.totalObservations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speciesUnlocked => $composableBuilder(
    column: $table.speciesUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<int> get totalObservations => $composableBuilder(
    column: $table.totalObservations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speciesUnlocked => $composableBuilder(
    column: $table.speciesUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int> totalObservations = const Value.absent(),
                Value<int> speciesUnlocked = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                email: email,
                totalObservations: totalObservations,
                speciesUnlocked: speciesUnlocked,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> email = const Value.absent(),
                Value<int> totalObservations = const Value.absent(),
                Value<int> speciesUnlocked = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                totalObservations: totalObservations,
                speciesUnlocked: speciesUnlocked,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SpeciesTableTableManager get species =>
      $$SpeciesTableTableManager(_db, _db.species);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$QuestionOptionsTableTableManager get questionOptions =>
      $$QuestionOptionsTableTableManager(_db, _db.questionOptions);
  $$SpeciesTraitsTableTableManager get speciesTraits =>
      $$SpeciesTraitsTableTableManager(_db, _db.speciesTraits);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db, _db.observations);
  $$ObservationPhotosTableTableManager get observationPhotos =>
      $$ObservationPhotosTableTableManager(_db, _db.observationPhotos);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
