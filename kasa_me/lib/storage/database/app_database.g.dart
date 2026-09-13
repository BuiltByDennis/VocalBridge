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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SpeechCorrectionsTable speechCorrections =
      $SpeechCorrectionsTable(this);
  late final $PhrasebookEntriesTable phrasebookEntries =
      $PhrasebookEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [profiles, speechCorrections, phrasebookEntries];
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
            .filter((f) => f.profileId.id($_item.id));

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
            .filter((f) => f.profileId.id($_item.id));

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
                    await $_getPrefetchedData(
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
                    await $_getPrefetchedData(
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
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId));
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
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId));
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SpeechCorrectionsTableTableManager get speechCorrections =>
      $$SpeechCorrectionsTableTableManager(_db, _db.speechCorrections);
  $$PhrasebookEntriesTableTableManager get phrasebookEntries =>
      $$PhrasebookEntriesTableTableManager(_db, _db.phrasebookEntries);
}
