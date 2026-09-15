// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preferredLanguageMeta =
      const VerificationMeta('preferredLanguage');
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>('preferred_language', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, preferredLanguage, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
          _preferredLanguageMeta,
          preferredLanguage.isAcceptableOrUnknown(
              data['preferred_language']!, _preferredLanguageMeta));
    } else if (isInserting) {
      context.missing(_preferredLanguageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      preferredLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preferred_language'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final String preferredLanguage;
  final DateTime createdAt;
  const Profile(
      {required this.id,
      required this.name,
      required this.preferredLanguage,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['preferred_language'] = Variable<String>(preferredLanguage);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      preferredLanguage: Value(preferredLanguage),
      createdAt: Value(createdAt),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      preferredLanguage: serializer.fromJson<String>(json['preferredLanguage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'preferredLanguage': serializer.toJson<String>(preferredLanguage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Profile copyWith(
          {int? id,
          String? name,
          String? preferredLanguage,
          DateTime? createdAt}) =>
      Profile(
        id: id ?? this.id,
        name: name ?? this.name,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        createdAt: createdAt ?? this.createdAt,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, preferredLanguage, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.preferredLanguage == this.preferredLanguage &&
          other.createdAt == this.createdAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> preferredLanguage;
  final Value<DateTime> createdAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String preferredLanguage,
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        preferredLanguage = Value(preferredLanguage);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? preferredLanguage,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? preferredLanguage,
      Value<DateTime>? createdAt}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SpeechCorrectionsTable extends SpeechCorrections
    with TableInfo<$SpeechCorrectionsTable, SpeechCorrection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeechCorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _originalTranscriptMeta =
      const VerificationMeta('originalTranscript');
  @override
  late final GeneratedColumn<String> originalTranscript =
      GeneratedColumn<String>('original_transcript', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctedTranscriptMeta =
      const VerificationMeta('correctedTranscript');
  @override
  late final GeneratedColumn<String> correctedTranscript =
      GeneratedColumn<String>('corrected_transcript', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, originalTranscript, correctedTranscript, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'speech_corrections';
  @override
  VerificationContext validateIntegrity(Insertable<SpeechCorrection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('original_transcript')) {
      context.handle(
          _originalTranscriptMeta,
          originalTranscript.isAcceptableOrUnknown(
              data['original_transcript']!, _originalTranscriptMeta));
    } else if (isInserting) {
      context.missing(_originalTranscriptMeta);
    }
    if (data.containsKey('corrected_transcript')) {
      context.handle(
          _correctedTranscriptMeta,
          correctedTranscript.isAcceptableOrUnknown(
              data['corrected_transcript']!, _correctedTranscriptMeta));
    } else if (isInserting) {
      context.missing(_correctedTranscriptMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeechCorrection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeechCorrection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      originalTranscript: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_transcript'])!,
      correctedTranscript: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}corrected_transcript'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $SpeechCorrectionsTable createAlias(String alias) {
    return $SpeechCorrectionsTable(attachedDatabase, alias);
  }
}

class SpeechCorrection extends DataClass
    implements Insertable<SpeechCorrection> {
  final int id;
  final int profileId;
  final String originalTranscript;
  final String correctedTranscript;
  final DateTime timestamp;
  const SpeechCorrection(
      {required this.id,
      required this.profileId,
      required this.originalTranscript,
      required this.correctedTranscript,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['original_transcript'] = Variable<String>(originalTranscript);
    map['corrected_transcript'] = Variable<String>(correctedTranscript);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  SpeechCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return SpeechCorrectionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      originalTranscript: Value(originalTranscript),
      correctedTranscript: Value(correctedTranscript),
      timestamp: Value(timestamp),
    );
  }

  factory SpeechCorrection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeechCorrection(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      originalTranscript:
          serializer.fromJson<String>(json['originalTranscript']),
      correctedTranscript:
          serializer.fromJson<String>(json['correctedTranscript']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'originalTranscript': serializer.toJson<String>(originalTranscript),
      'correctedTranscript': serializer.toJson<String>(correctedTranscript),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  SpeechCorrection copyWith(
          {int? id,
          int? profileId,
          String? originalTranscript,
          String? correctedTranscript,
          DateTime? timestamp}) =>
      SpeechCorrection(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        originalTranscript: originalTranscript ?? this.originalTranscript,
        correctedTranscript: correctedTranscript ?? this.correctedTranscript,
        timestamp: timestamp ?? this.timestamp,
      );
  SpeechCorrection copyWithCompanion(SpeechCorrectionsCompanion data) {
    return SpeechCorrection(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      originalTranscript: data.originalTranscript.present
          ? data.originalTranscript.value
          : this.originalTranscript,
      correctedTranscript: data.correctedTranscript.present
          ? data.correctedTranscript.value
          : this.correctedTranscript,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeechCorrection(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('originalTranscript: $originalTranscript, ')
          ..write('correctedTranscript: $correctedTranscript, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, originalTranscript, correctedTranscript, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeechCorrection &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.originalTranscript == this.originalTranscript &&
          other.correctedTranscript == this.correctedTranscript &&
          other.timestamp == this.timestamp);
}

class SpeechCorrectionsCompanion extends UpdateCompanion<SpeechCorrection> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> originalTranscript;
  final Value<String> correctedTranscript;
  final Value<DateTime> timestamp;
  const SpeechCorrectionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.originalTranscript = const Value.absent(),
    this.correctedTranscript = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  SpeechCorrectionsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String originalTranscript,
    required String correctedTranscript,
    this.timestamp = const Value.absent(),
  })  : profileId = Value(profileId),
        originalTranscript = Value(originalTranscript),
        correctedTranscript = Value(correctedTranscript);
  static Insertable<SpeechCorrection> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? originalTranscript,
    Expression<String>? correctedTranscript,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (originalTranscript != null) 'original_transcript': originalTranscript,
      if (correctedTranscript != null)
        'corrected_transcript': correctedTranscript,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  SpeechCorrectionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? originalTranscript,
      Value<String>? correctedTranscript,
      Value<DateTime>? timestamp}) {
    return SpeechCorrectionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      originalTranscript: originalTranscript ?? this.originalTranscript,
      correctedTranscript: correctedTranscript ?? this.correctedTranscript,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (originalTranscript.present) {
      map['original_transcript'] = Variable<String>(originalTranscript.value);
    }
    if (correctedTranscript.present) {
      map['corrected_transcript'] = Variable<String>(correctedTranscript.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeechCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('originalTranscript: $originalTranscript, ')
          ..write('correctedTranscript: $correctedTranscript, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $PhrasebookEntriesTable extends PhrasebookEntries
    with TableInfo<$PhrasebookEntriesTable, PhrasebookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhrasebookEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
      'phrase', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, phrase, category, usageCount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phrasebook_entries';
  @override
  VerificationContext validateIntegrity(Insertable<PhrasebookEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('phrase')) {
      context.handle(_phraseMeta,
          phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta));
    } else if (isInserting) {
      context.missing(_phraseMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhrasebookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhrasebookEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      phrase: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phrase'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PhrasebookEntriesTable createAlias(String alias) {
    return $PhrasebookEntriesTable(attachedDatabase, alias);
  }
}

class PhrasebookEntry extends DataClass implements Insertable<PhrasebookEntry> {
  final int id;
  final int profileId;
  final String phrase;
  final String? category;
  final int usageCount;
  final DateTime createdAt;
  const PhrasebookEntry(
      {required this.id,
      required this.profileId,
      required this.phrase,
      this.category,
      required this.usageCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['phrase'] = Variable<String>(phrase);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PhrasebookEntriesCompanion toCompanion(bool nullToAbsent) {
    return PhrasebookEntriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      phrase: Value(phrase),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
    );
  }

  factory PhrasebookEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhrasebookEntry(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      phrase: serializer.fromJson<String>(json['phrase']),
      category: serializer.fromJson<String?>(json['category']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'phrase': serializer.toJson<String>(phrase),
      'category': serializer.toJson<String?>(category),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PhrasebookEntry copyWith(
          {int? id,
          int? profileId,
          String? phrase,
          Value<String?> category = const Value.absent(),
          int? usageCount,
          DateTime? createdAt}) =>
      PhrasebookEntry(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        phrase: phrase ?? this.phrase,
        category: category.present ? category.value : this.category,
        usageCount: usageCount ?? this.usageCount,
        createdAt: createdAt ?? this.createdAt,
      );
  PhrasebookEntry copyWithCompanion(PhrasebookEntriesCompanion data) {
    return PhrasebookEntry(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      category: data.category.present ? data.category.value : this.category,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhrasebookEntry(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('phrase: $phrase, ')
          ..write('category: $category, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, phrase, category, usageCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhrasebookEntry &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.phrase == this.phrase &&
          other.category == this.category &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt);
}

class PhrasebookEntriesCompanion extends UpdateCompanion<PhrasebookEntry> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> phrase;
  final Value<String?> category;
  final Value<int> usageCount;
  final Value<DateTime> createdAt;
  const PhrasebookEntriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.phrase = const Value.absent(),
    this.category = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PhrasebookEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String phrase,
    this.category = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : profileId = Value(profileId),
        phrase = Value(phrase);
  static Insertable<PhrasebookEntry> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? phrase,
    Expression<String>? category,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (phrase != null) 'phrase': phrase,
      if (category != null) 'category': category,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PhrasebookEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? phrase,
      Value<String?>? category,
      Value<int>? usageCount,
      Value<DateTime>? createdAt}) {
    return PhrasebookEntriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      phrase: phrase ?? this.phrase,
      category: category ?? this.category,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhrasebookEntriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('phrase: $phrase, ')
          ..write('category: $category, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PersonalProfilesTable extends PersonalProfiles
    with TableInfo<$PersonalProfilesTable, PersonalProfileEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preferredLanguageMeta =
      const VerificationMeta('preferredLanguage');
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>('preferred_language', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('en_GH'));
  static const VerificationMeta _secondaryLanguagesMeta =
      const VerificationMeta('secondaryLanguages');
  @override
  late final GeneratedColumn<String> secondaryLanguages =
      GeneratedColumn<String>('secondary_languages', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _minConfidenceThresholdMeta =
      const VerificationMeta('minConfidenceThreshold');
  @override
  late final GeneratedColumn<double> minConfidenceThreshold =
      GeneratedColumn<double>('min_confidence_threshold', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.6));
  static const VerificationMeta _enablePersonalVocabularyMeta =
      const VerificationMeta('enablePersonalVocabulary');
  @override
  late final GeneratedColumn<bool> enablePersonalVocabulary =
      GeneratedColumn<bool>(
          'enable_personal_vocabulary', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_personal_vocabulary" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _enablePhraseBiasingMeta =
      const VerificationMeta('enablePhraseBiasing');
  @override
  late final GeneratedColumn<bool> enablePhraseBiasing = GeneratedColumn<bool>(
      'enable_phrase_biasing', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_phrase_biasing" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _enableCorrectionMemoryMeta =
      const VerificationMeta('enableCorrectionMemory');
  @override
  late final GeneratedColumn<bool> enableCorrectionMemory =
      GeneratedColumn<bool>('enable_correction_memory', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_correction_memory" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        profileId,
        preferredLanguage,
        secondaryLanguages,
        minConfidenceThreshold,
        enablePersonalVocabulary,
        enablePhraseBiasing,
        enableCorrectionMemory,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_profiles';
  @override
  VerificationContext validateIntegrity(
      Insertable<PersonalProfileEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
          _preferredLanguageMeta,
          preferredLanguage.isAcceptableOrUnknown(
              data['preferred_language']!, _preferredLanguageMeta));
    }
    if (data.containsKey('secondary_languages')) {
      context.handle(
          _secondaryLanguagesMeta,
          secondaryLanguages.isAcceptableOrUnknown(
              data['secondary_languages']!, _secondaryLanguagesMeta));
    }
    if (data.containsKey('min_confidence_threshold')) {
      context.handle(
          _minConfidenceThresholdMeta,
          minConfidenceThreshold.isAcceptableOrUnknown(
              data['min_confidence_threshold']!, _minConfidenceThresholdMeta));
    }
    if (data.containsKey('enable_personal_vocabulary')) {
      context.handle(
          _enablePersonalVocabularyMeta,
          enablePersonalVocabulary.isAcceptableOrUnknown(
              data['enable_personal_vocabulary']!,
              _enablePersonalVocabularyMeta));
    }
    if (data.containsKey('enable_phrase_biasing')) {
      context.handle(
          _enablePhraseBiasingMeta,
          enablePhraseBiasing.isAcceptableOrUnknown(
              data['enable_phrase_biasing']!, _enablePhraseBiasingMeta));
    }
    if (data.containsKey('enable_correction_memory')) {
      context.handle(
          _enableCorrectionMemoryMeta,
          enableCorrectionMemory.isAcceptableOrUnknown(
              data['enable_correction_memory']!, _enableCorrectionMemoryMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  PersonalProfileEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalProfileEntity(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      preferredLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preferred_language'])!,
      secondaryLanguages: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}secondary_languages'])!,
      minConfidenceThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}min_confidence_threshold'])!,
      enablePersonalVocabulary: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_personal_vocabulary'])!,
      enablePhraseBiasing: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}enable_phrase_biasing'])!,
      enableCorrectionMemory: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_correction_memory'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PersonalProfilesTable createAlias(String alias) {
    return $PersonalProfilesTable(attachedDatabase, alias);
  }
}

class PersonalProfileEntity extends DataClass
    implements Insertable<PersonalProfileEntity> {
  final String profileId;
  final String preferredLanguage;
  final String secondaryLanguages;
  final double minConfidenceThreshold;
  final bool enablePersonalVocabulary;
  final bool enablePhraseBiasing;
  final bool enableCorrectionMemory;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PersonalProfileEntity(
      {required this.profileId,
      required this.preferredLanguage,
      required this.secondaryLanguages,
      required this.minConfidenceThreshold,
      required this.enablePersonalVocabulary,
      required this.enablePhraseBiasing,
      required this.enableCorrectionMemory,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['preferred_language'] = Variable<String>(preferredLanguage);
    map['secondary_languages'] = Variable<String>(secondaryLanguages);
    map['min_confidence_threshold'] = Variable<double>(minConfidenceThreshold);
    map['enable_personal_vocabulary'] =
        Variable<bool>(enablePersonalVocabulary);
    map['enable_phrase_biasing'] = Variable<bool>(enablePhraseBiasing);
    map['enable_correction_memory'] = Variable<bool>(enableCorrectionMemory);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonalProfilesCompanion toCompanion(bool nullToAbsent) {
    return PersonalProfilesCompanion(
      profileId: Value(profileId),
      preferredLanguage: Value(preferredLanguage),
      secondaryLanguages: Value(secondaryLanguages),
      minConfidenceThreshold: Value(minConfidenceThreshold),
      enablePersonalVocabulary: Value(enablePersonalVocabulary),
      enablePhraseBiasing: Value(enablePhraseBiasing),
      enableCorrectionMemory: Value(enableCorrectionMemory),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonalProfileEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalProfileEntity(
      profileId: serializer.fromJson<String>(json['profileId']),
      preferredLanguage: serializer.fromJson<String>(json['preferredLanguage']),
      secondaryLanguages:
          serializer.fromJson<String>(json['secondaryLanguages']),
      minConfidenceThreshold:
          serializer.fromJson<double>(json['minConfidenceThreshold']),
      enablePersonalVocabulary:
          serializer.fromJson<bool>(json['enablePersonalVocabulary']),
      enablePhraseBiasing:
          serializer.fromJson<bool>(json['enablePhraseBiasing']),
      enableCorrectionMemory:
          serializer.fromJson<bool>(json['enableCorrectionMemory']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'preferredLanguage': serializer.toJson<String>(preferredLanguage),
      'secondaryLanguages': serializer.toJson<String>(secondaryLanguages),
      'minConfidenceThreshold':
          serializer.toJson<double>(minConfidenceThreshold),
      'enablePersonalVocabulary':
          serializer.toJson<bool>(enablePersonalVocabulary),
      'enablePhraseBiasing': serializer.toJson<bool>(enablePhraseBiasing),
      'enableCorrectionMemory': serializer.toJson<bool>(enableCorrectionMemory),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonalProfileEntity copyWith(
          {String? profileId,
          String? preferredLanguage,
          String? secondaryLanguages,
          double? minConfidenceThreshold,
          bool? enablePersonalVocabulary,
          bool? enablePhraseBiasing,
          bool? enableCorrectionMemory,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PersonalProfileEntity(
        profileId: profileId ?? this.profileId,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        secondaryLanguages: secondaryLanguages ?? this.secondaryLanguages,
        minConfidenceThreshold:
            minConfidenceThreshold ?? this.minConfidenceThreshold,
        enablePersonalVocabulary:
            enablePersonalVocabulary ?? this.enablePersonalVocabulary,
        enablePhraseBiasing: enablePhraseBiasing ?? this.enablePhraseBiasing,
        enableCorrectionMemory:
            enableCorrectionMemory ?? this.enableCorrectionMemory,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PersonalProfileEntity copyWithCompanion(PersonalProfilesCompanion data) {
    return PersonalProfileEntity(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      secondaryLanguages: data.secondaryLanguages.present
          ? data.secondaryLanguages.value
          : this.secondaryLanguages,
      minConfidenceThreshold: data.minConfidenceThreshold.present
          ? data.minConfidenceThreshold.value
          : this.minConfidenceThreshold,
      enablePersonalVocabulary: data.enablePersonalVocabulary.present
          ? data.enablePersonalVocabulary.value
          : this.enablePersonalVocabulary,
      enablePhraseBiasing: data.enablePhraseBiasing.present
          ? data.enablePhraseBiasing.value
          : this.enablePhraseBiasing,
      enableCorrectionMemory: data.enableCorrectionMemory.present
          ? data.enableCorrectionMemory.value
          : this.enableCorrectionMemory,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalProfileEntity(')
          ..write('profileId: $profileId, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('secondaryLanguages: $secondaryLanguages, ')
          ..write('minConfidenceThreshold: $minConfidenceThreshold, ')
          ..write('enablePersonalVocabulary: $enablePersonalVocabulary, ')
          ..write('enablePhraseBiasing: $enablePhraseBiasing, ')
          ..write('enableCorrectionMemory: $enableCorrectionMemory, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      profileId,
      preferredLanguage,
      secondaryLanguages,
      minConfidenceThreshold,
      enablePersonalVocabulary,
      enablePhraseBiasing,
      enableCorrectionMemory,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalProfileEntity &&
          other.profileId == this.profileId &&
          other.preferredLanguage == this.preferredLanguage &&
          other.secondaryLanguages == this.secondaryLanguages &&
          other.minConfidenceThreshold == this.minConfidenceThreshold &&
          other.enablePersonalVocabulary == this.enablePersonalVocabulary &&
          other.enablePhraseBiasing == this.enablePhraseBiasing &&
          other.enableCorrectionMemory == this.enableCorrectionMemory &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PersonalProfilesCompanion extends UpdateCompanion<PersonalProfileEntity> {
  final Value<String> profileId;
  final Value<String> preferredLanguage;
  final Value<String> secondaryLanguages;
  final Value<double> minConfidenceThreshold;
  final Value<bool> enablePersonalVocabulary;
  final Value<bool> enablePhraseBiasing;
  final Value<bool> enableCorrectionMemory;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PersonalProfilesCompanion({
    this.profileId = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.secondaryLanguages = const Value.absent(),
    this.minConfidenceThreshold = const Value.absent(),
    this.enablePersonalVocabulary = const Value.absent(),
    this.enablePhraseBiasing = const Value.absent(),
    this.enableCorrectionMemory = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalProfilesCompanion.insert({
    required String profileId,
    this.preferredLanguage = const Value.absent(),
    this.secondaryLanguages = const Value.absent(),
    this.minConfidenceThreshold = const Value.absent(),
    this.enablePersonalVocabulary = const Value.absent(),
    this.enablePhraseBiasing = const Value.absent(),
    this.enableCorrectionMemory = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId);
  static Insertable<PersonalProfileEntity> custom({
    Expression<String>? profileId,
    Expression<String>? preferredLanguage,
    Expression<String>? secondaryLanguages,
    Expression<double>? minConfidenceThreshold,
    Expression<bool>? enablePersonalVocabulary,
    Expression<bool>? enablePhraseBiasing,
    Expression<bool>? enableCorrectionMemory,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (secondaryLanguages != null) 'secondary_languages': secondaryLanguages,
      if (minConfidenceThreshold != null)
        'min_confidence_threshold': minConfidenceThreshold,
      if (enablePersonalVocabulary != null)
        'enable_personal_vocabulary': enablePersonalVocabulary,
      if (enablePhraseBiasing != null)
        'enable_phrase_biasing': enablePhraseBiasing,
      if (enableCorrectionMemory != null)
        'enable_correction_memory': enableCorrectionMemory,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalProfilesCompanion copyWith(
      {Value<String>? profileId,
      Value<String>? preferredLanguage,
      Value<String>? secondaryLanguages,
      Value<double>? minConfidenceThreshold,
      Value<bool>? enablePersonalVocabulary,
      Value<bool>? enablePhraseBiasing,
      Value<bool>? enableCorrectionMemory,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PersonalProfilesCompanion(
      profileId: profileId ?? this.profileId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      secondaryLanguages: secondaryLanguages ?? this.secondaryLanguages,
      minConfidenceThreshold:
          minConfidenceThreshold ?? this.minConfidenceThreshold,
      enablePersonalVocabulary:
          enablePersonalVocabulary ?? this.enablePersonalVocabulary,
      enablePhraseBiasing: enablePhraseBiasing ?? this.enablePhraseBiasing,
      enableCorrectionMemory:
          enableCorrectionMemory ?? this.enableCorrectionMemory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (secondaryLanguages.present) {
      map['secondary_languages'] = Variable<String>(secondaryLanguages.value);
    }
    if (minConfidenceThreshold.present) {
      map['min_confidence_threshold'] =
          Variable<double>(minConfidenceThreshold.value);
    }
    if (enablePersonalVocabulary.present) {
      map['enable_personal_vocabulary'] =
          Variable<bool>(enablePersonalVocabulary.value);
    }
    if (enablePhraseBiasing.present) {
      map['enable_phrase_biasing'] = Variable<bool>(enablePhraseBiasing.value);
    }
    if (enableCorrectionMemory.present) {
      map['enable_correction_memory'] =
          Variable<bool>(enableCorrectionMemory.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalProfilesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('secondaryLanguages: $secondaryLanguages, ')
          ..write('minConfidenceThreshold: $minConfidenceThreshold, ')
          ..write('enablePersonalVocabulary: $enablePersonalVocabulary, ')
          ..write('enablePhraseBiasing: $enablePhraseBiasing, ')
          ..write('enableCorrectionMemory: $enableCorrectionMemory, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalVocabularyTable extends PersonalVocabulary
    with TableInfo<$PersonalVocabularyTable, PersonalVocabularyEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalVocabularyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en_GH'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _pronunciationHintMeta =
      const VerificationMeta('pronunciationHint');
  @override
  late final GeneratedColumn<String> pronunciationHint =
      GeneratedColumn<String>('pronunciation_hint', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _biasWeightMeta =
      const VerificationMeta('biasWeight');
  @override
  late final GeneratedColumn<double> biasWeight = GeneratedColumn<double>(
      'bias_weight', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.5));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        word,
        language,
        category,
        pronunciationHint,
        biasWeight,
        enabled,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_vocabulary';
  @override
  VerificationContext validateIntegrity(
      Insertable<PersonalVocabularyEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('pronunciation_hint')) {
      context.handle(
          _pronunciationHintMeta,
          pronunciationHint.isAcceptableOrUnknown(
              data['pronunciation_hint']!, _pronunciationHintMeta));
    }
    if (data.containsKey('bias_weight')) {
      context.handle(
          _biasWeightMeta,
          biasWeight.isAcceptableOrUnknown(
              data['bias_weight']!, _biasWeightMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalVocabularyEntity map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalVocabularyEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      pronunciationHint: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pronunciation_hint']),
      biasWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bias_weight'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PersonalVocabularyTable createAlias(String alias) {
    return $PersonalVocabularyTable(attachedDatabase, alias);
  }
}

class PersonalVocabularyEntity extends DataClass
    implements Insertable<PersonalVocabularyEntity> {
  final int id;
  final String profileId;
  final String word;
  final String language;
  final String category;
  final String? pronunciationHint;
  final double biasWeight;
  final bool enabled;
  final DateTime createdAt;
  const PersonalVocabularyEntity(
      {required this.id,
      required this.profileId,
      required this.word,
      required this.language,
      required this.category,
      this.pronunciationHint,
      required this.biasWeight,
      required this.enabled,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['word'] = Variable<String>(word);
    map['language'] = Variable<String>(language);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || pronunciationHint != null) {
      map['pronunciation_hint'] = Variable<String>(pronunciationHint);
    }
    map['bias_weight'] = Variable<double>(biasWeight);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonalVocabularyCompanion toCompanion(bool nullToAbsent) {
    return PersonalVocabularyCompanion(
      id: Value(id),
      profileId: Value(profileId),
      word: Value(word),
      language: Value(language),
      category: Value(category),
      pronunciationHint: pronunciationHint == null && nullToAbsent
          ? const Value.absent()
          : Value(pronunciationHint),
      biasWeight: Value(biasWeight),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory PersonalVocabularyEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalVocabularyEntity(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      word: serializer.fromJson<String>(json['word']),
      language: serializer.fromJson<String>(json['language']),
      category: serializer.fromJson<String>(json['category']),
      pronunciationHint:
          serializer.fromJson<String?>(json['pronunciationHint']),
      biasWeight: serializer.fromJson<double>(json['biasWeight']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'word': serializer.toJson<String>(word),
      'language': serializer.toJson<String>(language),
      'category': serializer.toJson<String>(category),
      'pronunciationHint': serializer.toJson<String?>(pronunciationHint),
      'biasWeight': serializer.toJson<double>(biasWeight),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonalVocabularyEntity copyWith(
          {int? id,
          String? profileId,
          String? word,
          String? language,
          String? category,
          Value<String?> pronunciationHint = const Value.absent(),
          double? biasWeight,
          bool? enabled,
          DateTime? createdAt}) =>
      PersonalVocabularyEntity(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        word: word ?? this.word,
        language: language ?? this.language,
        category: category ?? this.category,
        pronunciationHint: pronunciationHint.present
            ? pronunciationHint.value
            : this.pronunciationHint,
        biasWeight: biasWeight ?? this.biasWeight,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt ?? this.createdAt,
      );
  PersonalVocabularyEntity copyWithCompanion(PersonalVocabularyCompanion data) {
    return PersonalVocabularyEntity(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      word: data.word.present ? data.word.value : this.word,
      language: data.language.present ? data.language.value : this.language,
      category: data.category.present ? data.category.value : this.category,
      pronunciationHint: data.pronunciationHint.present
          ? data.pronunciationHint.value
          : this.pronunciationHint,
      biasWeight:
          data.biasWeight.present ? data.biasWeight.value : this.biasWeight,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalVocabularyEntity(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('word: $word, ')
          ..write('language: $language, ')
          ..write('category: $category, ')
          ..write('pronunciationHint: $pronunciationHint, ')
          ..write('biasWeight: $biasWeight, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, word, language, category,
      pronunciationHint, biasWeight, enabled, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalVocabularyEntity &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.word == this.word &&
          other.language == this.language &&
          other.category == this.category &&
          other.pronunciationHint == this.pronunciationHint &&
          other.biasWeight == this.biasWeight &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class PersonalVocabularyCompanion
    extends UpdateCompanion<PersonalVocabularyEntity> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> word;
  final Value<String> language;
  final Value<String> category;
  final Value<String?> pronunciationHint;
  final Value<double> biasWeight;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  const PersonalVocabularyCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.word = const Value.absent(),
    this.language = const Value.absent(),
    this.category = const Value.absent(),
    this.pronunciationHint = const Value.absent(),
    this.biasWeight = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PersonalVocabularyCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String word,
    this.language = const Value.absent(),
    this.category = const Value.absent(),
    this.pronunciationHint = const Value.absent(),
    this.biasWeight = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : profileId = Value(profileId),
        word = Value(word);
  static Insertable<PersonalVocabularyEntity> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? word,
    Expression<String>? language,
    Expression<String>? category,
    Expression<String>? pronunciationHint,
    Expression<double>? biasWeight,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (word != null) 'word': word,
      if (language != null) 'language': language,
      if (category != null) 'category': category,
      if (pronunciationHint != null) 'pronunciation_hint': pronunciationHint,
      if (biasWeight != null) 'bias_weight': biasWeight,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PersonalVocabularyCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? word,
      Value<String>? language,
      Value<String>? category,
      Value<String?>? pronunciationHint,
      Value<double>? biasWeight,
      Value<bool>? enabled,
      Value<DateTime>? createdAt}) {
    return PersonalVocabularyCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      word: word ?? this.word,
      language: language ?? this.language,
      category: category ?? this.category,
      pronunciationHint: pronunciationHint ?? this.pronunciationHint,
      biasWeight: biasWeight ?? this.biasWeight,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (pronunciationHint.present) {
      map['pronunciation_hint'] = Variable<String>(pronunciationHint.value);
    }
    if (biasWeight.present) {
      map['bias_weight'] = Variable<double>(biasWeight.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalVocabularyCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('word: $word, ')
          ..write('language: $language, ')
          ..write('category: $category, ')
          ..write('pronunciationHint: $pronunciationHint, ')
          ..write('biasWeight: $biasWeight, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PersonalPhrasesTable extends PersonalPhrases
    with TableInfo<$PersonalPhrasesTable, PersonalPhraseEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalPhrasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
      'phrase', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en_GH'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        phrase,
        language,
        category,
        priority,
        usageCount,
        enabled,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_phrases';
  @override
  VerificationContext validateIntegrity(
      Insertable<PersonalPhraseEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('phrase')) {
      context.handle(_phraseMeta,
          phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta));
    } else if (isInserting) {
      context.missing(_phraseMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalPhraseEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalPhraseEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      phrase: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phrase'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PersonalPhrasesTable createAlias(String alias) {
    return $PersonalPhrasesTable(attachedDatabase, alias);
  }
}

class PersonalPhraseEntity extends DataClass
    implements Insertable<PersonalPhraseEntity> {
  final int id;
  final String profileId;
  final String phrase;
  final String language;
  final String category;
  final String priority;
  final int usageCount;
  final bool enabled;
  final DateTime createdAt;
  const PersonalPhraseEntity(
      {required this.id,
      required this.profileId,
      required this.phrase,
      required this.language,
      required this.category,
      required this.priority,
      required this.usageCount,
      required this.enabled,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['phrase'] = Variable<String>(phrase);
    map['language'] = Variable<String>(language);
    map['category'] = Variable<String>(category);
    map['priority'] = Variable<String>(priority);
    map['usage_count'] = Variable<int>(usageCount);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonalPhrasesCompanion toCompanion(bool nullToAbsent) {
    return PersonalPhrasesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      phrase: Value(phrase),
      language: Value(language),
      category: Value(category),
      priority: Value(priority),
      usageCount: Value(usageCount),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory PersonalPhraseEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalPhraseEntity(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      phrase: serializer.fromJson<String>(json['phrase']),
      language: serializer.fromJson<String>(json['language']),
      category: serializer.fromJson<String>(json['category']),
      priority: serializer.fromJson<String>(json['priority']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'phrase': serializer.toJson<String>(phrase),
      'language': serializer.toJson<String>(language),
      'category': serializer.toJson<String>(category),
      'priority': serializer.toJson<String>(priority),
      'usageCount': serializer.toJson<int>(usageCount),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonalPhraseEntity copyWith(
          {int? id,
          String? profileId,
          String? phrase,
          String? language,
          String? category,
          String? priority,
          int? usageCount,
          bool? enabled,
          DateTime? createdAt}) =>
      PersonalPhraseEntity(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        phrase: phrase ?? this.phrase,
        language: language ?? this.language,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        usageCount: usageCount ?? this.usageCount,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt ?? this.createdAt,
      );
  PersonalPhraseEntity copyWithCompanion(PersonalPhrasesCompanion data) {
    return PersonalPhraseEntity(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      language: data.language.present ? data.language.value : this.language,
      category: data.category.present ? data.category.value : this.category,
      priority: data.priority.present ? data.priority.value : this.priority,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalPhraseEntity(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('phrase: $phrase, ')
          ..write('language: $language, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('usageCount: $usageCount, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, phrase, language, category,
      priority, usageCount, enabled, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalPhraseEntity &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.phrase == this.phrase &&
          other.language == this.language &&
          other.category == this.category &&
          other.priority == this.priority &&
          other.usageCount == this.usageCount &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class PersonalPhrasesCompanion extends UpdateCompanion<PersonalPhraseEntity> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> phrase;
  final Value<String> language;
  final Value<String> category;
  final Value<String> priority;
  final Value<int> usageCount;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  const PersonalPhrasesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.phrase = const Value.absent(),
    this.language = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PersonalPhrasesCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String phrase,
    this.language = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : profileId = Value(profileId),
        phrase = Value(phrase);
  static Insertable<PersonalPhraseEntity> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? phrase,
    Expression<String>? language,
    Expression<String>? category,
    Expression<String>? priority,
    Expression<int>? usageCount,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (phrase != null) 'phrase': phrase,
      if (language != null) 'language': language,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      if (usageCount != null) 'usage_count': usageCount,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PersonalPhrasesCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? phrase,
      Value<String>? language,
      Value<String>? category,
      Value<String>? priority,
      Value<int>? usageCount,
      Value<bool>? enabled,
      Value<DateTime>? createdAt}) {
    return PersonalPhrasesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      phrase: phrase ?? this.phrase,
      language: language ?? this.language,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      usageCount: usageCount ?? this.usageCount,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalPhrasesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('phrase: $phrase, ')
          ..write('language: $language, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('usageCount: $usageCount, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WordCorrectionsTable extends WordCorrections
    with TableInfo<$WordCorrectionsTable, WordCorrectionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordCorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observedMeta =
      const VerificationMeta('observed');
  @override
  late final GeneratedColumn<String> observed = GeneratedColumn<String>(
      'observed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intendedMeta =
      const VerificationMeta('intended');
  @override
  late final GeneratedColumn<String> intended = GeneratedColumn<String>(
      'intended', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en_GH'));
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  static const VerificationMeta _lastCorrectedAtMeta =
      const VerificationMeta('lastCorrectedAt');
  @override
  late final GeneratedColumn<DateTime> lastCorrectedAt =
      GeneratedColumn<DateTime>('last_corrected_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        observed,
        intended,
        language,
        context,
        frequency,
        confidence,
        lastCorrectedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_corrections';
  @override
  VerificationContext validateIntegrity(
      Insertable<WordCorrectionEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('observed')) {
      context.handle(_observedMeta,
          observed.isAcceptableOrUnknown(data['observed']!, _observedMeta));
    } else if (isInserting) {
      context.missing(_observedMeta);
    }
    if (data.containsKey('intended')) {
      context.handle(_intendedMeta,
          intended.isAcceptableOrUnknown(data['intended']!, _intendedMeta));
    } else if (isInserting) {
      context.missing(_intendedMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('last_corrected_at')) {
      context.handle(
          _lastCorrectedAtMeta,
          lastCorrectedAt.isAcceptableOrUnknown(
              data['last_corrected_at']!, _lastCorrectedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordCorrectionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordCorrectionEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      observed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observed'])!,
      intended: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intended'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      lastCorrectedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_corrected_at'])!,
    );
  }

  @override
  $WordCorrectionsTable createAlias(String alias) {
    return $WordCorrectionsTable(attachedDatabase, alias);
  }
}

class WordCorrectionEntity extends DataClass
    implements Insertable<WordCorrectionEntity> {
  final int id;
  final String profileId;
  final String observed;
  final String intended;
  final String language;
  final String context;
  final int frequency;
  final double confidence;
  final DateTime lastCorrectedAt;
  const WordCorrectionEntity(
      {required this.id,
      required this.profileId,
      required this.observed,
      required this.intended,
      required this.language,
      required this.context,
      required this.frequency,
      required this.confidence,
      required this.lastCorrectedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['observed'] = Variable<String>(observed);
    map['intended'] = Variable<String>(intended);
    map['language'] = Variable<String>(language);
    map['context'] = Variable<String>(context);
    map['frequency'] = Variable<int>(frequency);
    map['confidence'] = Variable<double>(confidence);
    map['last_corrected_at'] = Variable<DateTime>(lastCorrectedAt);
    return map;
  }

  WordCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return WordCorrectionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      observed: Value(observed),
      intended: Value(intended),
      language: Value(language),
      context: Value(context),
      frequency: Value(frequency),
      confidence: Value(confidence),
      lastCorrectedAt: Value(lastCorrectedAt),
    );
  }

  factory WordCorrectionEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordCorrectionEntity(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      observed: serializer.fromJson<String>(json['observed']),
      intended: serializer.fromJson<String>(json['intended']),
      language: serializer.fromJson<String>(json['language']),
      context: serializer.fromJson<String>(json['context']),
      frequency: serializer.fromJson<int>(json['frequency']),
      confidence: serializer.fromJson<double>(json['confidence']),
      lastCorrectedAt: serializer.fromJson<DateTime>(json['lastCorrectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'observed': serializer.toJson<String>(observed),
      'intended': serializer.toJson<String>(intended),
      'language': serializer.toJson<String>(language),
      'context': serializer.toJson<String>(context),
      'frequency': serializer.toJson<int>(frequency),
      'confidence': serializer.toJson<double>(confidence),
      'lastCorrectedAt': serializer.toJson<DateTime>(lastCorrectedAt),
    };
  }

  WordCorrectionEntity copyWith(
          {int? id,
          String? profileId,
          String? observed,
          String? intended,
          String? language,
          String? context,
          int? frequency,
          double? confidence,
          DateTime? lastCorrectedAt}) =>
      WordCorrectionEntity(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        observed: observed ?? this.observed,
        intended: intended ?? this.intended,
        language: language ?? this.language,
        context: context ?? this.context,
        frequency: frequency ?? this.frequency,
        confidence: confidence ?? this.confidence,
        lastCorrectedAt: lastCorrectedAt ?? this.lastCorrectedAt,
      );
  WordCorrectionEntity copyWithCompanion(WordCorrectionsCompanion data) {
    return WordCorrectionEntity(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      observed: data.observed.present ? data.observed.value : this.observed,
      intended: data.intended.present ? data.intended.value : this.intended,
      language: data.language.present ? data.language.value : this.language,
      context: data.context.present ? data.context.value : this.context,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      lastCorrectedAt: data.lastCorrectedAt.present
          ? data.lastCorrectedAt.value
          : this.lastCorrectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordCorrectionEntity(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('observed: $observed, ')
          ..write('intended: $intended, ')
          ..write('language: $language, ')
          ..write('context: $context, ')
          ..write('frequency: $frequency, ')
          ..write('confidence: $confidence, ')
          ..write('lastCorrectedAt: $lastCorrectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, observed, intended, language,
      context, frequency, confidence, lastCorrectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordCorrectionEntity &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.observed == this.observed &&
          other.intended == this.intended &&
          other.language == this.language &&
          other.context == this.context &&
          other.frequency == this.frequency &&
          other.confidence == this.confidence &&
          other.lastCorrectedAt == this.lastCorrectedAt);
}

class WordCorrectionsCompanion extends UpdateCompanion<WordCorrectionEntity> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> observed;
  final Value<String> intended;
  final Value<String> language;
  final Value<String> context;
  final Value<int> frequency;
  final Value<double> confidence;
  final Value<DateTime> lastCorrectedAt;
  const WordCorrectionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.observed = const Value.absent(),
    this.intended = const Value.absent(),
    this.language = const Value.absent(),
    this.context = const Value.absent(),
    this.frequency = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastCorrectedAt = const Value.absent(),
  });
  WordCorrectionsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String observed,
    required String intended,
    this.language = const Value.absent(),
    this.context = const Value.absent(),
    this.frequency = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastCorrectedAt = const Value.absent(),
  })  : profileId = Value(profileId),
        observed = Value(observed),
        intended = Value(intended);
  static Insertable<WordCorrectionEntity> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? observed,
    Expression<String>? intended,
    Expression<String>? language,
    Expression<String>? context,
    Expression<int>? frequency,
    Expression<double>? confidence,
    Expression<DateTime>? lastCorrectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (observed != null) 'observed': observed,
      if (intended != null) 'intended': intended,
      if (language != null) 'language': language,
      if (context != null) 'context': context,
      if (frequency != null) 'frequency': frequency,
      if (confidence != null) 'confidence': confidence,
      if (lastCorrectedAt != null) 'last_corrected_at': lastCorrectedAt,
    });
  }

  WordCorrectionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? observed,
      Value<String>? intended,
      Value<String>? language,
      Value<String>? context,
      Value<int>? frequency,
      Value<double>? confidence,
      Value<DateTime>? lastCorrectedAt}) {
    return WordCorrectionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      observed: observed ?? this.observed,
      intended: intended ?? this.intended,
      language: language ?? this.language,
      context: context ?? this.context,
      frequency: frequency ?? this.frequency,
      confidence: confidence ?? this.confidence,
      lastCorrectedAt: lastCorrectedAt ?? this.lastCorrectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (observed.present) {
      map['observed'] = Variable<String>(observed.value);
    }
    if (intended.present) {
      map['intended'] = Variable<String>(intended.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (lastCorrectedAt.present) {
      map['last_corrected_at'] = Variable<DateTime>(lastCorrectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('observed: $observed, ')
          ..write('intended: $intended, ')
          ..write('language: $language, ')
          ..write('context: $context, ')
          ..write('frequency: $frequency, ')
          ..write('confidence: $confidence, ')
          ..write('lastCorrectedAt: $lastCorrectedAt')
          ..write(')'))
        .toString();
  }
}

class $PhraseCorrectionsTable extends PhraseCorrections
    with TableInfo<$PhraseCorrectionsTable, PhraseCorrectionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhraseCorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observedPhraseMeta =
      const VerificationMeta('observedPhrase');
  @override
  late final GeneratedColumn<String> observedPhrase = GeneratedColumn<String>(
      'observed_phrase', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intendedPhraseMeta =
      const VerificationMeta('intendedPhrase');
  @override
  late final GeneratedColumn<String> intendedPhrase = GeneratedColumn<String>(
      'intended_phrase', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en_GH'));
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  static const VerificationMeta _lastCorrectedAtMeta =
      const VerificationMeta('lastCorrectedAt');
  @override
  late final GeneratedColumn<DateTime> lastCorrectedAt =
      GeneratedColumn<DateTime>('last_corrected_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        observedPhrase,
        intendedPhrase,
        language,
        context,
        frequency,
        confidence,
        lastCorrectedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phrase_corrections';
  @override
  VerificationContext validateIntegrity(
      Insertable<PhraseCorrectionEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('observed_phrase')) {
      context.handle(
          _observedPhraseMeta,
          observedPhrase.isAcceptableOrUnknown(
              data['observed_phrase']!, _observedPhraseMeta));
    } else if (isInserting) {
      context.missing(_observedPhraseMeta);
    }
    if (data.containsKey('intended_phrase')) {
      context.handle(
          _intendedPhraseMeta,
          intendedPhrase.isAcceptableOrUnknown(
              data['intended_phrase']!, _intendedPhraseMeta));
    } else if (isInserting) {
      context.missing(_intendedPhraseMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('last_corrected_at')) {
      context.handle(
          _lastCorrectedAtMeta,
          lastCorrectedAt.isAcceptableOrUnknown(
              data['last_corrected_at']!, _lastCorrectedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhraseCorrectionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhraseCorrectionEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      observedPhrase: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}observed_phrase'])!,
      intendedPhrase: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}intended_phrase'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      lastCorrectedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_corrected_at'])!,
    );
  }

  @override
  $PhraseCorrectionsTable createAlias(String alias) {
    return $PhraseCorrectionsTable(attachedDatabase, alias);
  }
}

class PhraseCorrectionEntity extends DataClass
    implements Insertable<PhraseCorrectionEntity> {
  final int id;
  final String profileId;
  final String observedPhrase;
  final String intendedPhrase;
  final String language;
  final String context;
  final int frequency;
  final double confidence;
  final DateTime lastCorrectedAt;
  const PhraseCorrectionEntity(
      {required this.id,
      required this.profileId,
      required this.observedPhrase,
      required this.intendedPhrase,
      required this.language,
      required this.context,
      required this.frequency,
      required this.confidence,
      required this.lastCorrectedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['observed_phrase'] = Variable<String>(observedPhrase);
    map['intended_phrase'] = Variable<String>(intendedPhrase);
    map['language'] = Variable<String>(language);
    map['context'] = Variable<String>(context);
    map['frequency'] = Variable<int>(frequency);
    map['confidence'] = Variable<double>(confidence);
    map['last_corrected_at'] = Variable<DateTime>(lastCorrectedAt);
    return map;
  }

  PhraseCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return PhraseCorrectionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      observedPhrase: Value(observedPhrase),
      intendedPhrase: Value(intendedPhrase),
      language: Value(language),
      context: Value(context),
      frequency: Value(frequency),
      confidence: Value(confidence),
      lastCorrectedAt: Value(lastCorrectedAt),
    );
  }

  factory PhraseCorrectionEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhraseCorrectionEntity(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      observedPhrase: serializer.fromJson<String>(json['observedPhrase']),
      intendedPhrase: serializer.fromJson<String>(json['intendedPhrase']),
      language: serializer.fromJson<String>(json['language']),
      context: serializer.fromJson<String>(json['context']),
      frequency: serializer.fromJson<int>(json['frequency']),
      confidence: serializer.fromJson<double>(json['confidence']),
      lastCorrectedAt: serializer.fromJson<DateTime>(json['lastCorrectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'observedPhrase': serializer.toJson<String>(observedPhrase),
      'intendedPhrase': serializer.toJson<String>(intendedPhrase),
      'language': serializer.toJson<String>(language),
      'context': serializer.toJson<String>(context),
      'frequency': serializer.toJson<int>(frequency),
      'confidence': serializer.toJson<double>(confidence),
      'lastCorrectedAt': serializer.toJson<DateTime>(lastCorrectedAt),
    };
  }

  PhraseCorrectionEntity copyWith(
          {int? id,
          String? profileId,
          String? observedPhrase,
          String? intendedPhrase,
          String? language,
          String? context,
          int? frequency,
          double? confidence,
          DateTime? lastCorrectedAt}) =>
      PhraseCorrectionEntity(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        observedPhrase: observedPhrase ?? this.observedPhrase,
        intendedPhrase: intendedPhrase ?? this.intendedPhrase,
        language: language ?? this.language,
        context: context ?? this.context,
        frequency: frequency ?? this.frequency,
        confidence: confidence ?? this.confidence,
        lastCorrectedAt: lastCorrectedAt ?? this.lastCorrectedAt,
      );
  PhraseCorrectionEntity copyWithCompanion(PhraseCorrectionsCompanion data) {
    return PhraseCorrectionEntity(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      observedPhrase: data.observedPhrase.present
          ? data.observedPhrase.value
          : this.observedPhrase,
      intendedPhrase: data.intendedPhrase.present
          ? data.intendedPhrase.value
          : this.intendedPhrase,
      language: data.language.present ? data.language.value : this.language,
      context: data.context.present ? data.context.value : this.context,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      lastCorrectedAt: data.lastCorrectedAt.present
          ? data.lastCorrectedAt.value
          : this.lastCorrectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhraseCorrectionEntity(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('observedPhrase: $observedPhrase, ')
          ..write('intendedPhrase: $intendedPhrase, ')
          ..write('language: $language, ')
          ..write('context: $context, ')
          ..write('frequency: $frequency, ')
          ..write('confidence: $confidence, ')
          ..write('lastCorrectedAt: $lastCorrectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, observedPhrase, intendedPhrase,
      language, context, frequency, confidence, lastCorrectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhraseCorrectionEntity &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.observedPhrase == this.observedPhrase &&
          other.intendedPhrase == this.intendedPhrase &&
          other.language == this.language &&
          other.context == this.context &&
          other.frequency == this.frequency &&
          other.confidence == this.confidence &&
          other.lastCorrectedAt == this.lastCorrectedAt);
}

class PhraseCorrectionsCompanion
    extends UpdateCompanion<PhraseCorrectionEntity> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> observedPhrase;
  final Value<String> intendedPhrase;
  final Value<String> language;
  final Value<String> context;
  final Value<int> frequency;
  final Value<double> confidence;
  final Value<DateTime> lastCorrectedAt;
  const PhraseCorrectionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.observedPhrase = const Value.absent(),
    this.intendedPhrase = const Value.absent(),
    this.language = const Value.absent(),
    this.context = const Value.absent(),
    this.frequency = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastCorrectedAt = const Value.absent(),
  });
  PhraseCorrectionsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String observedPhrase,
    required String intendedPhrase,
    this.language = const Value.absent(),
    this.context = const Value.absent(),
    this.frequency = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastCorrectedAt = const Value.absent(),
  })  : profileId = Value(profileId),
        observedPhrase = Value(observedPhrase),
        intendedPhrase = Value(intendedPhrase);
  static Insertable<PhraseCorrectionEntity> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? observedPhrase,
    Expression<String>? intendedPhrase,
    Expression<String>? language,
    Expression<String>? context,
    Expression<int>? frequency,
    Expression<double>? confidence,
    Expression<DateTime>? lastCorrectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (observedPhrase != null) 'observed_phrase': observedPhrase,
      if (intendedPhrase != null) 'intended_phrase': intendedPhrase,
      if (language != null) 'language': language,
      if (context != null) 'context': context,
      if (frequency != null) 'frequency': frequency,
      if (confidence != null) 'confidence': confidence,
      if (lastCorrectedAt != null) 'last_corrected_at': lastCorrectedAt,
    });
  }

  PhraseCorrectionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? observedPhrase,
      Value<String>? intendedPhrase,
      Value<String>? language,
      Value<String>? context,
      Value<int>? frequency,
      Value<double>? confidence,
      Value<DateTime>? lastCorrectedAt}) {
    return PhraseCorrectionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      observedPhrase: observedPhrase ?? this.observedPhrase,
      intendedPhrase: intendedPhrase ?? this.intendedPhrase,
      language: language ?? this.language,
      context: context ?? this.context,
      frequency: frequency ?? this.frequency,
      confidence: confidence ?? this.confidence,
      lastCorrectedAt: lastCorrectedAt ?? this.lastCorrectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (observedPhrase.present) {
      map['observed_phrase'] = Variable<String>(observedPhrase.value);
    }
    if (intendedPhrase.present) {
      map['intended_phrase'] = Variable<String>(intendedPhrase.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (lastCorrectedAt.present) {
      map['last_corrected_at'] = Variable<DateTime>(lastCorrectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhraseCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('observedPhrase: $observedPhrase, ')
          ..write('intendedPhrase: $intendedPhrase, ')
          ..write('language: $language, ')
          ..write('context: $context, ')
          ..write('frequency: $frequency, ')
          ..write('confidence: $confidence, ')
          ..write('lastCorrectedAt: $lastCorrectedAt')
          ..write(')'))
        .toString();
  }
}

class $RecognitionEventsTable extends RecognitionEvents
    with TableInfo<$RecognitionEventsTable, RecognitionEventEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecognitionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawTranscriptMeta =
      const VerificationMeta('rawTranscript');
  @override
  late final GeneratedColumn<String> rawTranscript = GeneratedColumn<String>(
      'raw_transcript', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personalizedTranscriptMeta =
      const VerificationMeta('personalizedTranscript');
  @override
  late final GeneratedColumn<String> personalizedTranscript =
      GeneratedColumn<String>('personalized_transcript', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _wasCorrectedMeta =
      const VerificationMeta('wasCorrected');
  @override
  late final GeneratedColumn<bool> wasCorrected = GeneratedColumn<bool>(
      'was_corrected', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("was_corrected" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        rawTranscript,
        personalizedTranscript,
        confidence,
        context,
        wasCorrected,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recognition_events';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecognitionEventEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('raw_transcript')) {
      context.handle(
          _rawTranscriptMeta,
          rawTranscript.isAcceptableOrUnknown(
              data['raw_transcript']!, _rawTranscriptMeta));
    } else if (isInserting) {
      context.missing(_rawTranscriptMeta);
    }
    if (data.containsKey('personalized_transcript')) {
      context.handle(
          _personalizedTranscriptMeta,
          personalizedTranscript.isAcceptableOrUnknown(
              data['personalized_transcript']!, _personalizedTranscriptMeta));
    } else if (isInserting) {
      context.missing(_personalizedTranscriptMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    }
    if (data.containsKey('was_corrected')) {
      context.handle(
          _wasCorrectedMeta,
          wasCorrected.isAcceptableOrUnknown(
              data['was_corrected']!, _wasCorrectedMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecognitionEventEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecognitionEventEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      rawTranscript: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_transcript'])!,
      personalizedTranscript: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}personalized_transcript'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context'])!,
      wasCorrected: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_corrected'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $RecognitionEventsTable createAlias(String alias) {
    return $RecognitionEventsTable(attachedDatabase, alias);
  }
}

class RecognitionEventEntity extends DataClass
    implements Insertable<RecognitionEventEntity> {
  final int id;
  final String profileId;
  final String rawTranscript;
  final String personalizedTranscript;
  final double? confidence;
  final String context;
  final bool wasCorrected;
  final DateTime timestamp;
  const RecognitionEventEntity(
      {required this.id,
      required this.profileId,
      required this.rawTranscript,
      required this.personalizedTranscript,
      this.confidence,
      required this.context,
      required this.wasCorrected,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['raw_transcript'] = Variable<String>(rawTranscript);
    map['personalized_transcript'] = Variable<String>(personalizedTranscript);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['context'] = Variable<String>(context);
    map['was_corrected'] = Variable<bool>(wasCorrected);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  RecognitionEventsCompanion toCompanion(bool nullToAbsent) {
    return RecognitionEventsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      rawTranscript: Value(rawTranscript),
      personalizedTranscript: Value(personalizedTranscript),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      context: Value(context),
      wasCorrected: Value(wasCorrected),
      timestamp: Value(timestamp),
    );
  }

  factory RecognitionEventEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecognitionEventEntity(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      rawTranscript: serializer.fromJson<String>(json['rawTranscript']),
      personalizedTranscript:
          serializer.fromJson<String>(json['personalizedTranscript']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      context: serializer.fromJson<String>(json['context']),
      wasCorrected: serializer.fromJson<bool>(json['wasCorrected']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'rawTranscript': serializer.toJson<String>(rawTranscript),
      'personalizedTranscript':
          serializer.toJson<String>(personalizedTranscript),
      'confidence': serializer.toJson<double?>(confidence),
      'context': serializer.toJson<String>(context),
      'wasCorrected': serializer.toJson<bool>(wasCorrected),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  RecognitionEventEntity copyWith(
          {int? id,
          String? profileId,
          String? rawTranscript,
          String? personalizedTranscript,
          Value<double?> confidence = const Value.absent(),
          String? context,
          bool? wasCorrected,
          DateTime? timestamp}) =>
      RecognitionEventEntity(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        rawTranscript: rawTranscript ?? this.rawTranscript,
        personalizedTranscript:
            personalizedTranscript ?? this.personalizedTranscript,
        confidence: confidence.present ? confidence.value : this.confidence,
        context: context ?? this.context,
        wasCorrected: wasCorrected ?? this.wasCorrected,
        timestamp: timestamp ?? this.timestamp,
      );
  RecognitionEventEntity copyWithCompanion(RecognitionEventsCompanion data) {
    return RecognitionEventEntity(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      rawTranscript: data.rawTranscript.present
          ? data.rawTranscript.value
          : this.rawTranscript,
      personalizedTranscript: data.personalizedTranscript.present
          ? data.personalizedTranscript.value
          : this.personalizedTranscript,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      context: data.context.present ? data.context.value : this.context,
      wasCorrected: data.wasCorrected.present
          ? data.wasCorrected.value
          : this.wasCorrected,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecognitionEventEntity(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('personalizedTranscript: $personalizedTranscript, ')
          ..write('confidence: $confidence, ')
          ..write('context: $context, ')
          ..write('wasCorrected: $wasCorrected, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, rawTranscript,
      personalizedTranscript, confidence, context, wasCorrected, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecognitionEventEntity &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.rawTranscript == this.rawTranscript &&
          other.personalizedTranscript == this.personalizedTranscript &&
          other.confidence == this.confidence &&
          other.context == this.context &&
          other.wasCorrected == this.wasCorrected &&
          other.timestamp == this.timestamp);
}

class RecognitionEventsCompanion
    extends UpdateCompanion<RecognitionEventEntity> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> rawTranscript;
  final Value<String> personalizedTranscript;
  final Value<double?> confidence;
  final Value<String> context;
  final Value<bool> wasCorrected;
  final Value<DateTime> timestamp;
  const RecognitionEventsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.personalizedTranscript = const Value.absent(),
    this.confidence = const Value.absent(),
    this.context = const Value.absent(),
    this.wasCorrected = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  RecognitionEventsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String rawTranscript,
    required String personalizedTranscript,
    this.confidence = const Value.absent(),
    this.context = const Value.absent(),
    this.wasCorrected = const Value.absent(),
    this.timestamp = const Value.absent(),
  })  : profileId = Value(profileId),
        rawTranscript = Value(rawTranscript),
        personalizedTranscript = Value(personalizedTranscript);
  static Insertable<RecognitionEventEntity> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? rawTranscript,
    Expression<String>? personalizedTranscript,
    Expression<double>? confidence,
    Expression<String>? context,
    Expression<bool>? wasCorrected,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (rawTranscript != null) 'raw_transcript': rawTranscript,
      if (personalizedTranscript != null)
        'personalized_transcript': personalizedTranscript,
      if (confidence != null) 'confidence': confidence,
      if (context != null) 'context': context,
      if (wasCorrected != null) 'was_corrected': wasCorrected,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  RecognitionEventsCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileId,
      Value<String>? rawTranscript,
      Value<String>? personalizedTranscript,
      Value<double?>? confidence,
      Value<String>? context,
      Value<bool>? wasCorrected,
      Value<DateTime>? timestamp}) {
    return RecognitionEventsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      personalizedTranscript:
          personalizedTranscript ?? this.personalizedTranscript,
      confidence: confidence ?? this.confidence,
      context: context ?? this.context,
      wasCorrected: wasCorrected ?? this.wasCorrected,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (rawTranscript.present) {
      map['raw_transcript'] = Variable<String>(rawTranscript.value);
    }
    if (personalizedTranscript.present) {
      map['personalized_transcript'] =
          Variable<String>(personalizedTranscript.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (wasCorrected.present) {
      map['was_corrected'] = Variable<bool>(wasCorrected.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecognitionEventsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('personalizedTranscript: $personalizedTranscript, ')
          ..write('confidence: $confidence, ')
          ..write('context: $context, ')
          ..write('wasCorrected: $wasCorrected, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SpeechCorrectionsTable speechCorrections =
      $SpeechCorrectionsTable(this);
  late final $PhrasebookEntriesTable phrasebookEntries =
      $PhrasebookEntriesTable(this);
  late final $PersonalProfilesTable personalProfiles =
      $PersonalProfilesTable(this);
  late final $PersonalVocabularyTable personalVocabulary =
      $PersonalVocabularyTable(this);
  late final $PersonalPhrasesTable personalPhrases =
      $PersonalPhrasesTable(this);
  late final $WordCorrectionsTable wordCorrections =
      $WordCorrectionsTable(this);
  late final $PhraseCorrectionsTable phraseCorrections =
      $PhraseCorrectionsTable(this);
  late final $RecognitionEventsTable recognitionEvents =
      $RecognitionEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        profiles,
        speechCorrections,
        phrasebookEntries,
        personalProfiles,
        personalVocabulary,
        personalPhrases,
        wordCorrections,
        phraseCorrections,
        recognitionEvents
      ];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String name,
  required String preferredLanguage,
  Value<DateTime> createdAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> preferredLanguage,
  Value<DateTime> createdAt,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SpeechCorrectionsTable, List<SpeechCorrection>>
      _speechCorrectionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.speechCorrections,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.speechCorrections.profileId));

  $$SpeechCorrectionsTableProcessedTableManager get speechCorrectionsRefs {
    final manager =
        $$SpeechCorrectionsTableTableManager($_db, $_db.speechCorrections)
            .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_speechCorrectionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PhrasebookEntriesTable, List<PhrasebookEntry>>
      _phrasebookEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.phrasebookEntries,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.phrasebookEntries.profileId));

  $$PhrasebookEntriesTableProcessedTableManager get phrasebookEntriesRefs {
    final manager =
        $$PhrasebookEntriesTableTableManager($_db, $_db.phrasebookEntries)
            .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_phrasebookEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> speechCorrectionsRefs(
      Expression<bool> Function($$SpeechCorrectionsTableFilterComposer f) f) {
    final $$SpeechCorrectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.speechCorrections,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SpeechCorrectionsTableFilterComposer(
              $db: $db,
              $table: $db.speechCorrections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> phrasebookEntriesRefs(
      Expression<bool> Function($$PhrasebookEntriesTableFilterComposer f) f) {
    final $$PhrasebookEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.phrasebookEntries,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhrasebookEntriesTableFilterComposer(
              $db: $db,
              $table: $db.phrasebookEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> speechCorrectionsRefs<T extends Object>(
      Expression<T> Function($$SpeechCorrectionsTableAnnotationComposer a) f) {
    final $$SpeechCorrectionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.speechCorrections,
            getReferencedColumn: (t) => t.profileId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SpeechCorrectionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.speechCorrections,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> phrasebookEntriesRefs<T extends Object>(
      Expression<T> Function($$PhrasebookEntriesTableAnnotationComposer a) f) {
    final $$PhrasebookEntriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.phrasebookEntries,
            getReferencedColumn: (t) => t.profileId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PhrasebookEntriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.phrasebookEntries,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function(
        {bool speechCorrectionsRefs, bool phrasebookEntriesRefs})> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> preferredLanguage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            name: name,
            preferredLanguage: preferredLanguage,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String preferredLanguage,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            name: name,
            preferredLanguage: preferredLanguage,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {speechCorrectionsRefs = false, phrasebookEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (speechCorrectionsRefs) db.speechCorrections,
                if (phrasebookEntriesRefs) db.phrasebookEntries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (speechCorrectionsRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable,
                            SpeechCorrection>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._speechCorrectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .speechCorrectionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (phrasebookEntriesRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable,
                            PhrasebookEntry>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._phrasebookEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .phrasebookEntriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function(
        {bool speechCorrectionsRefs, bool phrasebookEntriesRefs})>;
typedef $$SpeechCorrectionsTableCreateCompanionBuilder
    = SpeechCorrectionsCompanion Function({
  Value<int> id,
  required int profileId,
  required String originalTranscript,
  required String correctedTranscript,
  Value<DateTime> timestamp,
});
typedef $$SpeechCorrectionsTableUpdateCompanionBuilder
    = SpeechCorrectionsCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> originalTranscript,
  Value<String> correctedTranscript,
  Value<DateTime> timestamp,
});

final class $$SpeechCorrectionsTableReferences extends BaseReferences<
    _$AppDatabase, $SpeechCorrectionsTable, SpeechCorrection> {
  $$SpeechCorrectionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.speechCorrections.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SpeechCorrectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SpeechCorrectionsTable> {
  $$SpeechCorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalTranscript => $composableBuilder(
      column: $table.originalTranscript,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctedTranscript => $composableBuilder(
      column: $table.correctedTranscript,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SpeechCorrectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeechCorrectionsTable> {
  $$SpeechCorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalTranscript => $composableBuilder(
      column: $table.originalTranscript,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctedTranscript => $composableBuilder(
      column: $table.correctedTranscript,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SpeechCorrectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeechCorrectionsTable> {
  $$SpeechCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalTranscript => $composableBuilder(
      column: $table.originalTranscript, builder: (column) => column);

  GeneratedColumn<String> get correctedTranscript => $composableBuilder(
      column: $table.correctedTranscript, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SpeechCorrectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SpeechCorrectionsTable,
    SpeechCorrection,
    $$SpeechCorrectionsTableFilterComposer,
    $$SpeechCorrectionsTableOrderingComposer,
    $$SpeechCorrectionsTableAnnotationComposer,
    $$SpeechCorrectionsTableCreateCompanionBuilder,
    $$SpeechCorrectionsTableUpdateCompanionBuilder,
    (SpeechCorrection, $$SpeechCorrectionsTableReferences),
    SpeechCorrection,
    PrefetchHooks Function({bool profileId})> {
  $$SpeechCorrectionsTableTableManager(
      _$AppDatabase db, $SpeechCorrectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeechCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeechCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeechCorrectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> originalTranscript = const Value.absent(),
            Value<String> correctedTranscript = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              SpeechCorrectionsCompanion(
            id: id,
            profileId: profileId,
            originalTranscript: originalTranscript,
            correctedTranscript: correctedTranscript,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required String originalTranscript,
            required String correctedTranscript,
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              SpeechCorrectionsCompanion.insert(
            id: id,
            profileId: profileId,
            originalTranscript: originalTranscript,
            correctedTranscript: correctedTranscript,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SpeechCorrectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$SpeechCorrectionsTableReferences._profileIdTable(db),
                    referencedColumn: $$SpeechCorrectionsTableReferences
                        ._profileIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SpeechCorrectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SpeechCorrectionsTable,
    SpeechCorrection,
    $$SpeechCorrectionsTableFilterComposer,
    $$SpeechCorrectionsTableOrderingComposer,
    $$SpeechCorrectionsTableAnnotationComposer,
    $$SpeechCorrectionsTableCreateCompanionBuilder,
    $$SpeechCorrectionsTableUpdateCompanionBuilder,
    (SpeechCorrection, $$SpeechCorrectionsTableReferences),
    SpeechCorrection,
    PrefetchHooks Function({bool profileId})>;
typedef $$PhrasebookEntriesTableCreateCompanionBuilder
    = PhrasebookEntriesCompanion Function({
  Value<int> id,
  required int profileId,
  required String phrase,
  Value<String?> category,
  Value<int> usageCount,
  Value<DateTime> createdAt,
});
typedef $$PhrasebookEntriesTableUpdateCompanionBuilder
    = PhrasebookEntriesCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> phrase,
  Value<String?> category,
  Value<int> usageCount,
  Value<DateTime> createdAt,
});

final class $$PhrasebookEntriesTableReferences extends BaseReferences<
    _$AppDatabase, $PhrasebookEntriesTable, PhrasebookEntry> {
  $$PhrasebookEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.phrasebookEntries.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhrasebookEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PhrasebookEntriesTable> {
  $$PhrasebookEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phrase => $composableBuilder(
      column: $table.phrase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhrasebookEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PhrasebookEntriesTable> {
  $$PhrasebookEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phrase => $composableBuilder(
      column: $table.phrase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhrasebookEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhrasebookEntriesTable> {
  $$PhrasebookEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhrasebookEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhrasebookEntriesTable,
    PhrasebookEntry,
    $$PhrasebookEntriesTableFilterComposer,
    $$PhrasebookEntriesTableOrderingComposer,
    $$PhrasebookEntriesTableAnnotationComposer,
    $$PhrasebookEntriesTableCreateCompanionBuilder,
    $$PhrasebookEntriesTableUpdateCompanionBuilder,
    (PhrasebookEntry, $$PhrasebookEntriesTableReferences),
    PhrasebookEntry,
    PrefetchHooks Function({bool profileId})> {
  $$PhrasebookEntriesTableTableManager(
      _$AppDatabase db, $PhrasebookEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhrasebookEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhrasebookEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhrasebookEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> phrase = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PhrasebookEntriesCompanion(
            id: id,
            profileId: profileId,
            phrase: phrase,
            category: category,
            usageCount: usageCount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required String phrase,
            Value<String?> category = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PhrasebookEntriesCompanion.insert(
            id: id,
            profileId: profileId,
            phrase: phrase,
            category: category,
            usageCount: usageCount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PhrasebookEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$PhrasebookEntriesTableReferences._profileIdTable(db),
                    referencedColumn: $$PhrasebookEntriesTableReferences
                        ._profileIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhrasebookEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhrasebookEntriesTable,
    PhrasebookEntry,
    $$PhrasebookEntriesTableFilterComposer,
    $$PhrasebookEntriesTableOrderingComposer,
    $$PhrasebookEntriesTableAnnotationComposer,
    $$PhrasebookEntriesTableCreateCompanionBuilder,
    $$PhrasebookEntriesTableUpdateCompanionBuilder,
    (PhrasebookEntry, $$PhrasebookEntriesTableReferences),
    PhrasebookEntry,
    PrefetchHooks Function({bool profileId})>;
typedef $$PersonalProfilesTableCreateCompanionBuilder
    = PersonalProfilesCompanion Function({
  required String profileId,
  Value<String> preferredLanguage,
  Value<String> secondaryLanguages,
  Value<double> minConfidenceThreshold,
  Value<bool> enablePersonalVocabulary,
  Value<bool> enablePhraseBiasing,
  Value<bool> enableCorrectionMemory,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$PersonalProfilesTableUpdateCompanionBuilder
    = PersonalProfilesCompanion Function({
  Value<String> profileId,
  Value<String> preferredLanguage,
  Value<String> secondaryLanguages,
  Value<double> minConfidenceThreshold,
  Value<bool> enablePersonalVocabulary,
  Value<bool> enablePhraseBiasing,
  Value<bool> enableCorrectionMemory,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PersonalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalProfilesTable> {
  $$PersonalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondaryLanguages => $composableBuilder(
      column: $table.secondaryLanguages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minConfidenceThreshold => $composableBuilder(
      column: $table.minConfidenceThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enablePersonalVocabulary => $composableBuilder(
      column: $table.enablePersonalVocabulary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enablePhraseBiasing => $composableBuilder(
      column: $table.enablePhraseBiasing,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableCorrectionMemory => $composableBuilder(
      column: $table.enableCorrectionMemory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PersonalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalProfilesTable> {
  $$PersonalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondaryLanguages => $composableBuilder(
      column: $table.secondaryLanguages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minConfidenceThreshold => $composableBuilder(
      column: $table.minConfidenceThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enablePersonalVocabulary => $composableBuilder(
      column: $table.enablePersonalVocabulary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enablePhraseBiasing => $composableBuilder(
      column: $table.enablePhraseBiasing,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableCorrectionMemory => $composableBuilder(
      column: $table.enableCorrectionMemory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PersonalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalProfilesTable> {
  $$PersonalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get preferredLanguage => $composableBuilder(
      column: $table.preferredLanguage, builder: (column) => column);

  GeneratedColumn<String> get secondaryLanguages => $composableBuilder(
      column: $table.secondaryLanguages, builder: (column) => column);

  GeneratedColumn<double> get minConfidenceThreshold => $composableBuilder(
      column: $table.minConfidenceThreshold, builder: (column) => column);

  GeneratedColumn<bool> get enablePersonalVocabulary => $composableBuilder(
      column: $table.enablePersonalVocabulary, builder: (column) => column);

  GeneratedColumn<bool> get enablePhraseBiasing => $composableBuilder(
      column: $table.enablePhraseBiasing, builder: (column) => column);

  GeneratedColumn<bool> get enableCorrectionMemory => $composableBuilder(
      column: $table.enableCorrectionMemory, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PersonalProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonalProfilesTable,
    PersonalProfileEntity,
    $$PersonalProfilesTableFilterComposer,
    $$PersonalProfilesTableOrderingComposer,
    $$PersonalProfilesTableAnnotationComposer,
    $$PersonalProfilesTableCreateCompanionBuilder,
    $$PersonalProfilesTableUpdateCompanionBuilder,
    (
      PersonalProfileEntity,
      BaseReferences<_$AppDatabase, $PersonalProfilesTable,
          PersonalProfileEntity>
    ),
    PersonalProfileEntity,
    PrefetchHooks Function()> {
  $$PersonalProfilesTableTableManager(
      _$AppDatabase db, $PersonalProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> profileId = const Value.absent(),
            Value<String> preferredLanguage = const Value.absent(),
            Value<String> secondaryLanguages = const Value.absent(),
            Value<double> minConfidenceThreshold = const Value.absent(),
            Value<bool> enablePersonalVocabulary = const Value.absent(),
            Value<bool> enablePhraseBiasing = const Value.absent(),
            Value<bool> enableCorrectionMemory = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonalProfilesCompanion(
            profileId: profileId,
            preferredLanguage: preferredLanguage,
            secondaryLanguages: secondaryLanguages,
            minConfidenceThreshold: minConfidenceThreshold,
            enablePersonalVocabulary: enablePersonalVocabulary,
            enablePhraseBiasing: enablePhraseBiasing,
            enableCorrectionMemory: enableCorrectionMemory,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String profileId,
            Value<String> preferredLanguage = const Value.absent(),
            Value<String> secondaryLanguages = const Value.absent(),
            Value<double> minConfidenceThreshold = const Value.absent(),
            Value<bool> enablePersonalVocabulary = const Value.absent(),
            Value<bool> enablePhraseBiasing = const Value.absent(),
            Value<bool> enableCorrectionMemory = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonalProfilesCompanion.insert(
            profileId: profileId,
            preferredLanguage: preferredLanguage,
            secondaryLanguages: secondaryLanguages,
            minConfidenceThreshold: minConfidenceThreshold,
            enablePersonalVocabulary: enablePersonalVocabulary,
            enablePhraseBiasing: enablePhraseBiasing,
            enableCorrectionMemory: enableCorrectionMemory,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonalProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonalProfilesTable,
    PersonalProfileEntity,
    $$PersonalProfilesTableFilterComposer,
    $$PersonalProfilesTableOrderingComposer,
    $$PersonalProfilesTableAnnotationComposer,
    $$PersonalProfilesTableCreateCompanionBuilder,
    $$PersonalProfilesTableUpdateCompanionBuilder,
    (
      PersonalProfileEntity,
      BaseReferences<_$AppDatabase, $PersonalProfilesTable,
          PersonalProfileEntity>
    ),
    PersonalProfileEntity,
    PrefetchHooks Function()>;
typedef $$PersonalVocabularyTableCreateCompanionBuilder
    = PersonalVocabularyCompanion Function({
  Value<int> id,
  required String profileId,
  required String word,
  Value<String> language,
  Value<String> category,
  Value<String?> pronunciationHint,
  Value<double> biasWeight,
  Value<bool> enabled,
  Value<DateTime> createdAt,
});
typedef $$PersonalVocabularyTableUpdateCompanionBuilder
    = PersonalVocabularyCompanion Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> word,
  Value<String> language,
  Value<String> category,
  Value<String?> pronunciationHint,
  Value<double> biasWeight,
  Value<bool> enabled,
  Value<DateTime> createdAt,
});

class $$PersonalVocabularyTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalVocabularyTable> {
  $$PersonalVocabularyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pronunciationHint => $composableBuilder(
      column: $table.pronunciationHint,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get biasWeight => $composableBuilder(
      column: $table.biasWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PersonalVocabularyTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalVocabularyTable> {
  $$PersonalVocabularyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pronunciationHint => $composableBuilder(
      column: $table.pronunciationHint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get biasWeight => $composableBuilder(
      column: $table.biasWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PersonalVocabularyTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalVocabularyTable> {
  $$PersonalVocabularyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get pronunciationHint => $composableBuilder(
      column: $table.pronunciationHint, builder: (column) => column);

  GeneratedColumn<double> get biasWeight => $composableBuilder(
      column: $table.biasWeight, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PersonalVocabularyTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonalVocabularyTable,
    PersonalVocabularyEntity,
    $$PersonalVocabularyTableFilterComposer,
    $$PersonalVocabularyTableOrderingComposer,
    $$PersonalVocabularyTableAnnotationComposer,
    $$PersonalVocabularyTableCreateCompanionBuilder,
    $$PersonalVocabularyTableUpdateCompanionBuilder,
    (
      PersonalVocabularyEntity,
      BaseReferences<_$AppDatabase, $PersonalVocabularyTable,
          PersonalVocabularyEntity>
    ),
    PersonalVocabularyEntity,
    PrefetchHooks Function()> {
  $$PersonalVocabularyTableTableManager(
      _$AppDatabase db, $PersonalVocabularyTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalVocabularyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalVocabularyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalVocabularyTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> pronunciationHint = const Value.absent(),
            Value<double> biasWeight = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PersonalVocabularyCompanion(
            id: id,
            profileId: profileId,
            word: word,
            language: language,
            category: category,
            pronunciationHint: pronunciationHint,
            biasWeight: biasWeight,
            enabled: enabled,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String word,
            Value<String> language = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> pronunciationHint = const Value.absent(),
            Value<double> biasWeight = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PersonalVocabularyCompanion.insert(
            id: id,
            profileId: profileId,
            word: word,
            language: language,
            category: category,
            pronunciationHint: pronunciationHint,
            biasWeight: biasWeight,
            enabled: enabled,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonalVocabularyTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonalVocabularyTable,
    PersonalVocabularyEntity,
    $$PersonalVocabularyTableFilterComposer,
    $$PersonalVocabularyTableOrderingComposer,
    $$PersonalVocabularyTableAnnotationComposer,
    $$PersonalVocabularyTableCreateCompanionBuilder,
    $$PersonalVocabularyTableUpdateCompanionBuilder,
    (
      PersonalVocabularyEntity,
      BaseReferences<_$AppDatabase, $PersonalVocabularyTable,
          PersonalVocabularyEntity>
    ),
    PersonalVocabularyEntity,
    PrefetchHooks Function()>;
typedef $$PersonalPhrasesTableCreateCompanionBuilder = PersonalPhrasesCompanion
    Function({
  Value<int> id,
  required String profileId,
  required String phrase,
  Value<String> language,
  Value<String> category,
  Value<String> priority,
  Value<int> usageCount,
  Value<bool> enabled,
  Value<DateTime> createdAt,
});
typedef $$PersonalPhrasesTableUpdateCompanionBuilder = PersonalPhrasesCompanion
    Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> phrase,
  Value<String> language,
  Value<String> category,
  Value<String> priority,
  Value<int> usageCount,
  Value<bool> enabled,
  Value<DateTime> createdAt,
});

class $$PersonalPhrasesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalPhrasesTable> {
  $$PersonalPhrasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phrase => $composableBuilder(
      column: $table.phrase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PersonalPhrasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalPhrasesTable> {
  $$PersonalPhrasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phrase => $composableBuilder(
      column: $table.phrase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PersonalPhrasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalPhrasesTable> {
  $$PersonalPhrasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PersonalPhrasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonalPhrasesTable,
    PersonalPhraseEntity,
    $$PersonalPhrasesTableFilterComposer,
    $$PersonalPhrasesTableOrderingComposer,
    $$PersonalPhrasesTableAnnotationComposer,
    $$PersonalPhrasesTableCreateCompanionBuilder,
    $$PersonalPhrasesTableUpdateCompanionBuilder,
    (
      PersonalPhraseEntity,
      BaseReferences<_$AppDatabase, $PersonalPhrasesTable, PersonalPhraseEntity>
    ),
    PersonalPhraseEntity,
    PrefetchHooks Function()> {
  $$PersonalPhrasesTableTableManager(
      _$AppDatabase db, $PersonalPhrasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalPhrasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalPhrasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalPhrasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> phrase = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PersonalPhrasesCompanion(
            id: id,
            profileId: profileId,
            phrase: phrase,
            language: language,
            category: category,
            priority: priority,
            usageCount: usageCount,
            enabled: enabled,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String phrase,
            Value<String> language = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PersonalPhrasesCompanion.insert(
            id: id,
            profileId: profileId,
            phrase: phrase,
            language: language,
            category: category,
            priority: priority,
            usageCount: usageCount,
            enabled: enabled,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonalPhrasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonalPhrasesTable,
    PersonalPhraseEntity,
    $$PersonalPhrasesTableFilterComposer,
    $$PersonalPhrasesTableOrderingComposer,
    $$PersonalPhrasesTableAnnotationComposer,
    $$PersonalPhrasesTableCreateCompanionBuilder,
    $$PersonalPhrasesTableUpdateCompanionBuilder,
    (
      PersonalPhraseEntity,
      BaseReferences<_$AppDatabase, $PersonalPhrasesTable, PersonalPhraseEntity>
    ),
    PersonalPhraseEntity,
    PrefetchHooks Function()>;
typedef $$WordCorrectionsTableCreateCompanionBuilder = WordCorrectionsCompanion
    Function({
  Value<int> id,
  required String profileId,
  required String observed,
  required String intended,
  Value<String> language,
  Value<String> context,
  Value<int> frequency,
  Value<double> confidence,
  Value<DateTime> lastCorrectedAt,
});
typedef $$WordCorrectionsTableUpdateCompanionBuilder = WordCorrectionsCompanion
    Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> observed,
  Value<String> intended,
  Value<String> language,
  Value<String> context,
  Value<int> frequency,
  Value<double> confidence,
  Value<DateTime> lastCorrectedAt,
});

class $$WordCorrectionsTableFilterComposer
    extends Composer<_$AppDatabase, $WordCorrectionsTable> {
  $$WordCorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observed => $composableBuilder(
      column: $table.observed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intended => $composableBuilder(
      column: $table.intended, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCorrectedAt => $composableBuilder(
      column: $table.lastCorrectedAt,
      builder: (column) => ColumnFilters(column));
}

class $$WordCorrectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordCorrectionsTable> {
  $$WordCorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observed => $composableBuilder(
      column: $table.observed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intended => $composableBuilder(
      column: $table.intended, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCorrectedAt => $composableBuilder(
      column: $table.lastCorrectedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$WordCorrectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordCorrectionsTable> {
  $$WordCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get observed =>
      $composableBuilder(column: $table.observed, builder: (column) => column);

  GeneratedColumn<String> get intended =>
      $composableBuilder(column: $table.intended, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCorrectedAt => $composableBuilder(
      column: $table.lastCorrectedAt, builder: (column) => column);
}

class $$WordCorrectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordCorrectionsTable,
    WordCorrectionEntity,
    $$WordCorrectionsTableFilterComposer,
    $$WordCorrectionsTableOrderingComposer,
    $$WordCorrectionsTableAnnotationComposer,
    $$WordCorrectionsTableCreateCompanionBuilder,
    $$WordCorrectionsTableUpdateCompanionBuilder,
    (
      WordCorrectionEntity,
      BaseReferences<_$AppDatabase, $WordCorrectionsTable, WordCorrectionEntity>
    ),
    WordCorrectionEntity,
    PrefetchHooks Function()> {
  $$WordCorrectionsTableTableManager(
      _$AppDatabase db, $WordCorrectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordCorrectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> observed = const Value.absent(),
            Value<String> intended = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<DateTime> lastCorrectedAt = const Value.absent(),
          }) =>
              WordCorrectionsCompanion(
            id: id,
            profileId: profileId,
            observed: observed,
            intended: intended,
            language: language,
            context: context,
            frequency: frequency,
            confidence: confidence,
            lastCorrectedAt: lastCorrectedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String observed,
            required String intended,
            Value<String> language = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<DateTime> lastCorrectedAt = const Value.absent(),
          }) =>
              WordCorrectionsCompanion.insert(
            id: id,
            profileId: profileId,
            observed: observed,
            intended: intended,
            language: language,
            context: context,
            frequency: frequency,
            confidence: confidence,
            lastCorrectedAt: lastCorrectedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WordCorrectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordCorrectionsTable,
    WordCorrectionEntity,
    $$WordCorrectionsTableFilterComposer,
    $$WordCorrectionsTableOrderingComposer,
    $$WordCorrectionsTableAnnotationComposer,
    $$WordCorrectionsTableCreateCompanionBuilder,
    $$WordCorrectionsTableUpdateCompanionBuilder,
    (
      WordCorrectionEntity,
      BaseReferences<_$AppDatabase, $WordCorrectionsTable, WordCorrectionEntity>
    ),
    WordCorrectionEntity,
    PrefetchHooks Function()>;
typedef $$PhraseCorrectionsTableCreateCompanionBuilder
    = PhraseCorrectionsCompanion Function({
  Value<int> id,
  required String profileId,
  required String observedPhrase,
  required String intendedPhrase,
  Value<String> language,
  Value<String> context,
  Value<int> frequency,
  Value<double> confidence,
  Value<DateTime> lastCorrectedAt,
});
typedef $$PhraseCorrectionsTableUpdateCompanionBuilder
    = PhraseCorrectionsCompanion Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> observedPhrase,
  Value<String> intendedPhrase,
  Value<String> language,
  Value<String> context,
  Value<int> frequency,
  Value<double> confidence,
  Value<DateTime> lastCorrectedAt,
});

class $$PhraseCorrectionsTableFilterComposer
    extends Composer<_$AppDatabase, $PhraseCorrectionsTable> {
  $$PhraseCorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observedPhrase => $composableBuilder(
      column: $table.observedPhrase,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intendedPhrase => $composableBuilder(
      column: $table.intendedPhrase,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCorrectedAt => $composableBuilder(
      column: $table.lastCorrectedAt,
      builder: (column) => ColumnFilters(column));
}

class $$PhraseCorrectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhraseCorrectionsTable> {
  $$PhraseCorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observedPhrase => $composableBuilder(
      column: $table.observedPhrase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intendedPhrase => $composableBuilder(
      column: $table.intendedPhrase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCorrectedAt => $composableBuilder(
      column: $table.lastCorrectedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$PhraseCorrectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhraseCorrectionsTable> {
  $$PhraseCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get observedPhrase => $composableBuilder(
      column: $table.observedPhrase, builder: (column) => column);

  GeneratedColumn<String> get intendedPhrase => $composableBuilder(
      column: $table.intendedPhrase, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCorrectedAt => $composableBuilder(
      column: $table.lastCorrectedAt, builder: (column) => column);
}

class $$PhraseCorrectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhraseCorrectionsTable,
    PhraseCorrectionEntity,
    $$PhraseCorrectionsTableFilterComposer,
    $$PhraseCorrectionsTableOrderingComposer,
    $$PhraseCorrectionsTableAnnotationComposer,
    $$PhraseCorrectionsTableCreateCompanionBuilder,
    $$PhraseCorrectionsTableUpdateCompanionBuilder,
    (
      PhraseCorrectionEntity,
      BaseReferences<_$AppDatabase, $PhraseCorrectionsTable,
          PhraseCorrectionEntity>
    ),
    PhraseCorrectionEntity,
    PrefetchHooks Function()> {
  $$PhraseCorrectionsTableTableManager(
      _$AppDatabase db, $PhraseCorrectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhraseCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhraseCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhraseCorrectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> observedPhrase = const Value.absent(),
            Value<String> intendedPhrase = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<DateTime> lastCorrectedAt = const Value.absent(),
          }) =>
              PhraseCorrectionsCompanion(
            id: id,
            profileId: profileId,
            observedPhrase: observedPhrase,
            intendedPhrase: intendedPhrase,
            language: language,
            context: context,
            frequency: frequency,
            confidence: confidence,
            lastCorrectedAt: lastCorrectedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String observedPhrase,
            required String intendedPhrase,
            Value<String> language = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<DateTime> lastCorrectedAt = const Value.absent(),
          }) =>
              PhraseCorrectionsCompanion.insert(
            id: id,
            profileId: profileId,
            observedPhrase: observedPhrase,
            intendedPhrase: intendedPhrase,
            language: language,
            context: context,
            frequency: frequency,
            confidence: confidence,
            lastCorrectedAt: lastCorrectedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PhraseCorrectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhraseCorrectionsTable,
    PhraseCorrectionEntity,
    $$PhraseCorrectionsTableFilterComposer,
    $$PhraseCorrectionsTableOrderingComposer,
    $$PhraseCorrectionsTableAnnotationComposer,
    $$PhraseCorrectionsTableCreateCompanionBuilder,
    $$PhraseCorrectionsTableUpdateCompanionBuilder,
    (
      PhraseCorrectionEntity,
      BaseReferences<_$AppDatabase, $PhraseCorrectionsTable,
          PhraseCorrectionEntity>
    ),
    PhraseCorrectionEntity,
    PrefetchHooks Function()>;
typedef $$RecognitionEventsTableCreateCompanionBuilder
    = RecognitionEventsCompanion Function({
  Value<int> id,
  required String profileId,
  required String rawTranscript,
  required String personalizedTranscript,
  Value<double?> confidence,
  Value<String> context,
  Value<bool> wasCorrected,
  Value<DateTime> timestamp,
});
typedef $$RecognitionEventsTableUpdateCompanionBuilder
    = RecognitionEventsCompanion Function({
  Value<int> id,
  Value<String> profileId,
  Value<String> rawTranscript,
  Value<String> personalizedTranscript,
  Value<double?> confidence,
  Value<String> context,
  Value<bool> wasCorrected,
  Value<DateTime> timestamp,
});

class $$RecognitionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $RecognitionEventsTable> {
  $$RecognitionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawTranscript => $composableBuilder(
      column: $table.rawTranscript, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personalizedTranscript => $composableBuilder(
      column: $table.personalizedTranscript,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasCorrected => $composableBuilder(
      column: $table.wasCorrected, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$RecognitionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecognitionEventsTable> {
  $$RecognitionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawTranscript => $composableBuilder(
      column: $table.rawTranscript,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personalizedTranscript => $composableBuilder(
      column: $table.personalizedTranscript,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasCorrected => $composableBuilder(
      column: $table.wasCorrected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$RecognitionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecognitionEventsTable> {
  $$RecognitionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get rawTranscript => $composableBuilder(
      column: $table.rawTranscript, builder: (column) => column);

  GeneratedColumn<String> get personalizedTranscript => $composableBuilder(
      column: $table.personalizedTranscript, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<bool> get wasCorrected => $composableBuilder(
      column: $table.wasCorrected, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$RecognitionEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecognitionEventsTable,
    RecognitionEventEntity,
    $$RecognitionEventsTableFilterComposer,
    $$RecognitionEventsTableOrderingComposer,
    $$RecognitionEventsTableAnnotationComposer,
    $$RecognitionEventsTableCreateCompanionBuilder,
    $$RecognitionEventsTableUpdateCompanionBuilder,
    (
      RecognitionEventEntity,
      BaseReferences<_$AppDatabase, $RecognitionEventsTable,
          RecognitionEventEntity>
    ),
    RecognitionEventEntity,
    PrefetchHooks Function()> {
  $$RecognitionEventsTableTableManager(
      _$AppDatabase db, $RecognitionEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecognitionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecognitionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecognitionEventsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> rawTranscript = const Value.absent(),
            Value<String> personalizedTranscript = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<bool> wasCorrected = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              RecognitionEventsCompanion(
            id: id,
            profileId: profileId,
            rawTranscript: rawTranscript,
            personalizedTranscript: personalizedTranscript,
            confidence: confidence,
            context: context,
            wasCorrected: wasCorrected,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String profileId,
            required String rawTranscript,
            required String personalizedTranscript,
            Value<double?> confidence = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<bool> wasCorrected = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              RecognitionEventsCompanion.insert(
            id: id,
            profileId: profileId,
            rawTranscript: rawTranscript,
            personalizedTranscript: personalizedTranscript,
            confidence: confidence,
            context: context,
            wasCorrected: wasCorrected,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecognitionEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecognitionEventsTable,
    RecognitionEventEntity,
    $$RecognitionEventsTableFilterComposer,
    $$RecognitionEventsTableOrderingComposer,
    $$RecognitionEventsTableAnnotationComposer,
    $$RecognitionEventsTableCreateCompanionBuilder,
    $$RecognitionEventsTableUpdateCompanionBuilder,
    (
      RecognitionEventEntity,
      BaseReferences<_$AppDatabase, $RecognitionEventsTable,
          RecognitionEventEntity>
    ),
    RecognitionEventEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SpeechCorrectionsTableTableManager get speechCorrections =>
      $$SpeechCorrectionsTableTableManager(_db, _db.speechCorrections);
  $$PhrasebookEntriesTableTableManager get phrasebookEntries =>
      $$PhrasebookEntriesTableTableManager(_db, _db.phrasebookEntries);
  $$PersonalProfilesTableTableManager get personalProfiles =>
      $$PersonalProfilesTableTableManager(_db, _db.personalProfiles);
  $$PersonalVocabularyTableTableManager get personalVocabulary =>
      $$PersonalVocabularyTableTableManager(_db, _db.personalVocabulary);
  $$PersonalPhrasesTableTableManager get personalPhrases =>
      $$PersonalPhrasesTableTableManager(_db, _db.personalPhrases);
  $$WordCorrectionsTableTableManager get wordCorrections =>
      $$WordCorrectionsTableTableManager(_db, _db.wordCorrections);
  $$PhraseCorrectionsTableTableManager get phraseCorrections =>
      $$PhraseCorrectionsTableTableManager(_db, _db.phraseCorrections);
  $$RecognitionEventsTableTableManager get recognitionEvents =>
      $$RecognitionEventsTableTableManager(_db, _db.recognitionEvents);
}
