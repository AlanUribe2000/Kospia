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
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    commonName,
    scientificName,
    description,
    imageUrl,
    family,
    habitat,
    flowerColor,
    isActive,
    syncStatus,
    createdAt,
  );
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    photoPath,
    latitude,
    longitude,
    altitude,
    accuracy,
    notes,
    syncStatus,
    capturedAt,
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
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    } else if (isInserting) {
      context.missing(_photoPathMeta);
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
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
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
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
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
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
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
  final String? speciesId;
  final String photoPath;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final String notes;
  final String syncStatus;
  final DateTime capturedAt;
  final DateTime? syncedAt;
  const Observation({
    required this.id,
    required this.userId,
    this.speciesId,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.notes,
    required this.syncStatus,
    required this.capturedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<String>(speciesId);
    }
    map['photo_path'] = Variable<String>(photoPath);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['altitude'] = Variable<double>(altitude);
    map['accuracy'] = Variable<double>(accuracy);
    map['notes'] = Variable<String>(notes);
    map['sync_status'] = Variable<String>(syncStatus);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      userId: Value(userId),
      speciesId: speciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesId),
      photoPath: Value(photoPath),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: Value(altitude),
      accuracy: Value(accuracy),
      notes: Value(notes),
      syncStatus: Value(syncStatus),
      capturedAt: Value(capturedAt),
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
      speciesId: serializer.fromJson<String?>(json['speciesId']),
      photoPath: serializer.fromJson<String>(json['photoPath']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double>(json['altitude']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      notes: serializer.fromJson<String>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'speciesId': serializer.toJson<String?>(speciesId),
      'photoPath': serializer.toJson<String>(photoPath),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double>(altitude),
      'accuracy': serializer.toJson<double>(accuracy),
      'notes': serializer.toJson<String>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  Observation copyWith({
    String? id,
    String? userId,
    Value<String?> speciesId = const Value.absent(),
    String? photoPath,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    String? notes,
    String? syncStatus,
    DateTime? capturedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => Observation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    photoPath: photoPath ?? this.photoPath,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude ?? this.altitude,
    accuracy: accuracy ?? this.accuracy,
    notes: notes ?? this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    capturedAt: capturedAt ?? this.capturedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('speciesId: $speciesId, ')
          ..write('photoPath: $photoPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    speciesId,
    photoPath,
    latitude,
    longitude,
    altitude,
    accuracy,
    notes,
    syncStatus,
    capturedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.speciesId == this.speciesId &&
          other.photoPath == this.photoPath &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.accuracy == this.accuracy &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.capturedAt == this.capturedAt &&
          other.syncedAt == this.syncedAt);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> speciesId;
  final Value<String> photoPath;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> altitude;
  final Value<double> accuracy;
  final Value<String> notes;
  final Value<String> syncStatus;
  final Value<DateTime> capturedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    required String id,
    required String userId,
    this.speciesId = const Value.absent(),
    required String photoPath,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       photoPath = Value(photoPath),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<Observation> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? speciesId,
    Expression<String>? photoPath,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? accuracy,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (speciesId != null) 'species_id': speciesId,
      if (photoPath != null) 'photo_path': photoPath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? speciesId,
    Value<String>? photoPath,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? altitude,
    Value<double>? accuracy,
    Value<String>? notes,
    Value<String>? syncStatus,
    Value<DateTime>? capturedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ObservationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesId: speciesId ?? this.speciesId,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      capturedAt: capturedAt ?? this.capturedAt,
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
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
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
          ..write('photoPath: $photoPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('syncedAt: $syncedAt, ')
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
      Value<String?> speciesId,
      required String photoPath,
      required double latitude,
      required double longitude,
      Value<double> altitude,
      Value<double> accuracy,
      Value<String> notes,
      Value<String> syncStatus,
      Value<DateTime> capturedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ObservationsTableUpdateCompanionBuilder =
    ObservationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> speciesId,
      Value<String> photoPath,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> altitude,
      Value<double> accuracy,
      Value<String> notes,
      Value<String> syncStatus,
      Value<DateTime> capturedAt,
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

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

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
                Value<String?> speciesId = const Value.absent(),
                Value<String> photoPath = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> altitude = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion(
                id: id,
                userId: userId,
                speciesId: speciesId,
                photoPath: photoPath,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                accuracy: accuracy,
                notes: notes,
                syncStatus: syncStatus,
                capturedAt: capturedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> speciesId = const Value.absent(),
                required String photoPath,
                required double latitude,
                required double longitude,
                Value<double> altitude = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion.insert(
                id: id,
                userId: userId,
                speciesId: speciesId,
                photoPath: photoPath,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                accuracy: accuracy,
                notes: notes,
                syncStatus: syncStatus,
                capturedAt: capturedAt,
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
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
