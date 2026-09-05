// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Aspirant'),
  );
  static const VerificationMeta _targetRoleMeta = const VerificationMeta(
    'targetRole',
  );
  @override
  late final GeneratedColumn<String> targetRole = GeneratedColumn<String>(
    'target_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('product'),
  );
  static const VerificationMeta _targetCompaniesMeta = const VerificationMeta(
    'targetCompanies',
  );
  @override
  late final GeneratedColumn<String> targetCompanies = GeneratedColumn<String>(
    'target_companies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _skillLevelMeta = const VerificationMeta(
    'skillLevel',
  );
  @override
  late final GeneratedColumn<String> skillLevel = GeneratedColumn<String>(
    'skill_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('beginner'),
  );
  static const VerificationMeta _dailyGoalMinutesMeta = const VerificationMeta(
    'dailyGoalMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMinutes = GeneratedColumn<int>(
    'daily_goal_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    targetRole,
    targetCompanies,
    skillLevel,
    dailyGoalMinutes,
    targetDate,
    xp,
    onboarded,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('target_role')) {
      context.handle(
        _targetRoleMeta,
        targetRole.isAcceptableOrUnknown(data['target_role']!, _targetRoleMeta),
      );
    }
    if (data.containsKey('target_companies')) {
      context.handle(
        _targetCompaniesMeta,
        targetCompanies.isAcceptableOrUnknown(
          data['target_companies']!,
          _targetCompaniesMeta,
        ),
      );
    }
    if (data.containsKey('skill_level')) {
      context.handle(
        _skillLevelMeta,
        skillLevel.isAcceptableOrUnknown(data['skill_level']!, _skillLevelMeta),
      );
    }
    if (data.containsKey('daily_goal_minutes')) {
      context.handle(
        _dailyGoalMinutesMeta,
        dailyGoalMinutes.isAcceptableOrUnknown(
          data['daily_goal_minutes']!,
          _dailyGoalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
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
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_role'],
      )!,
      targetCompanies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_companies'],
      )!,
      skillLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_level'],
      )!,
      dailyGoalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_minutes'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String name;
  final String targetRole;
  final String targetCompanies;
  final String skillLevel;

  /// The daily study budget. This is the planner's capacity and the bar a day
  /// must clear to count towards the streak. (A separate "problems per day"
  /// goal was retired in v7 — items differ too much in effort for a raw count
  /// to be meaningful.)
  final int dailyGoalMinutes;
  final DateTime? targetDate;
  final int xp;
  final bool onboarded;
  final DateTime createdAt;
  const UserProfile({
    required this.id,
    required this.name,
    required this.targetRole,
    required this.targetCompanies,
    required this.skillLevel,
    required this.dailyGoalMinutes,
    this.targetDate,
    required this.xp,
    required this.onboarded,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_role'] = Variable<String>(targetRole);
    map['target_companies'] = Variable<String>(targetCompanies);
    map['skill_level'] = Variable<String>(skillLevel);
    map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['xp'] = Variable<int>(xp);
    map['onboarded'] = Variable<bool>(onboarded);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      targetRole: Value(targetRole),
      targetCompanies: Value(targetCompanies),
      skillLevel: Value(skillLevel),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      xp: Value(xp),
      onboarded: Value(onboarded),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetRole: serializer.fromJson<String>(json['targetRole']),
      targetCompanies: serializer.fromJson<String>(json['targetCompanies']),
      skillLevel: serializer.fromJson<String>(json['skillLevel']),
      dailyGoalMinutes: serializer.fromJson<int>(json['dailyGoalMinutes']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      xp: serializer.fromJson<int>(json['xp']),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetRole': serializer.toJson<String>(targetRole),
      'targetCompanies': serializer.toJson<String>(targetCompanies),
      'skillLevel': serializer.toJson<String>(skillLevel),
      'dailyGoalMinutes': serializer.toJson<int>(dailyGoalMinutes),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'xp': serializer.toJson<int>(xp),
      'onboarded': serializer.toJson<bool>(onboarded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? targetRole,
    String? targetCompanies,
    String? skillLevel,
    int? dailyGoalMinutes,
    Value<DateTime?> targetDate = const Value.absent(),
    int? xp,
    bool? onboarded,
    DateTime? createdAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    targetRole: targetRole ?? this.targetRole,
    targetCompanies: targetCompanies ?? this.targetCompanies,
    skillLevel: skillLevel ?? this.skillLevel,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    xp: xp ?? this.xp,
    onboarded: onboarded ?? this.onboarded,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetRole: data.targetRole.present
          ? data.targetRole.value
          : this.targetRole,
      targetCompanies: data.targetCompanies.present
          ? data.targetCompanies.value
          : this.targetCompanies,
      skillLevel: data.skillLevel.present
          ? data.skillLevel.value
          : this.skillLevel,
      dailyGoalMinutes: data.dailyGoalMinutes.present
          ? data.dailyGoalMinutes.value
          : this.dailyGoalMinutes,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      xp: data.xp.present ? data.xp.value : this.xp,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetRole: $targetRole, ')
          ..write('targetCompanies: $targetCompanies, ')
          ..write('skillLevel: $skillLevel, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('targetDate: $targetDate, ')
          ..write('xp: $xp, ')
          ..write('onboarded: $onboarded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetRole,
    targetCompanies,
    skillLevel,
    dailyGoalMinutes,
    targetDate,
    xp,
    onboarded,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetRole == this.targetRole &&
          other.targetCompanies == this.targetCompanies &&
          other.skillLevel == this.skillLevel &&
          other.dailyGoalMinutes == this.dailyGoalMinutes &&
          other.targetDate == this.targetDate &&
          other.xp == this.xp &&
          other.onboarded == this.onboarded &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> targetRole;
  final Value<String> targetCompanies;
  final Value<String> skillLevel;
  final Value<int> dailyGoalMinutes;
  final Value<DateTime?> targetDate;
  final Value<int> xp;
  final Value<bool> onboarded;
  final Value<DateTime> createdAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetRole = const Value.absent(),
    this.targetCompanies = const Value.absent(),
    this.skillLevel = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.xp = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetRole = const Value.absent(),
    this.targetCompanies = const Value.absent(),
    this.skillLevel = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.xp = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? targetRole,
    Expression<String>? targetCompanies,
    Expression<String>? skillLevel,
    Expression<int>? dailyGoalMinutes,
    Expression<DateTime>? targetDate,
    Expression<int>? xp,
    Expression<bool>? onboarded,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetRole != null) 'target_role': targetRole,
      if (targetCompanies != null) 'target_companies': targetCompanies,
      if (skillLevel != null) 'skill_level': skillLevel,
      if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
      if (targetDate != null) 'target_date': targetDate,
      if (xp != null) 'xp': xp,
      if (onboarded != null) 'onboarded': onboarded,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? targetRole,
    Value<String>? targetCompanies,
    Value<String>? skillLevel,
    Value<int>? dailyGoalMinutes,
    Value<DateTime?>? targetDate,
    Value<int>? xp,
    Value<bool>? onboarded,
    Value<DateTime>? createdAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetRole: targetRole ?? this.targetRole,
      targetCompanies: targetCompanies ?? this.targetCompanies,
      skillLevel: skillLevel ?? this.skillLevel,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      targetDate: targetDate ?? this.targetDate,
      xp: xp ?? this.xp,
      onboarded: onboarded ?? this.onboarded,
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
    if (targetRole.present) {
      map['target_role'] = Variable<String>(targetRole.value);
    }
    if (targetCompanies.present) {
      map['target_companies'] = Variable<String>(targetCompanies.value);
    }
    if (skillLevel.present) {
      map['skill_level'] = Variable<String>(skillLevel.value);
    }
    if (dailyGoalMinutes.present) {
      map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetRole: $targetRole, ')
          ..write('targetCompanies: $targetCompanies, ')
          ..write('skillLevel: $skillLevel, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('targetDate: $targetDate, ')
          ..write('xp: $xp, ')
          ..write('onboarded: $onboarded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SheetsTable extends Sheets with TableInfo<$SheetsTable, Sheet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SheetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    title,
    category,
    description,
    source,
    orderIndex,
    isBuiltIn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sheets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sheet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sheet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sheet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
    );
  }

  @override
  $SheetsTable createAlias(String alias) {
    return $SheetsTable(attachedDatabase, alias);
  }
}

class Sheet extends DataClass implements Insertable<Sheet> {
  final int id;
  final String slug;
  final String title;
  final String category;
  final String description;
  final String source;
  final int orderIndex;
  final bool isBuiltIn;
  const Sheet({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.description,
    required this.source,
    required this.orderIndex,
    required this.isBuiltIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['source'] = Variable<String>(source);
    map['order_index'] = Variable<int>(orderIndex);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    return map;
  }

  SheetsCompanion toCompanion(bool nullToAbsent) {
    return SheetsCompanion(
      id: Value(id),
      slug: Value(slug),
      title: Value(title),
      category: Value(category),
      description: Value(description),
      source: Value(source),
      orderIndex: Value(orderIndex),
      isBuiltIn: Value(isBuiltIn),
    );
  }

  factory Sheet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sheet(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      source: serializer.fromJson<String>(json['source']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'source': serializer.toJson<String>(source),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
    };
  }

  Sheet copyWith({
    int? id,
    String? slug,
    String? title,
    String? category,
    String? description,
    String? source,
    int? orderIndex,
    bool? isBuiltIn,
  }) => Sheet(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    title: title ?? this.title,
    category: category ?? this.category,
    description: description ?? this.description,
    source: source ?? this.source,
    orderIndex: orderIndex ?? this.orderIndex,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );
  Sheet copyWithCompanion(SheetsCompanion data) {
    return Sheet(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      source: data.source.present ? data.source.value : this.source,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sheet(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('source: $source, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    title,
    category,
    description,
    source,
    orderIndex,
    isBuiltIn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sheet &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.title == this.title &&
          other.category == this.category &&
          other.description == this.description &&
          other.source == this.source &&
          other.orderIndex == this.orderIndex &&
          other.isBuiltIn == this.isBuiltIn);
}

class SheetsCompanion extends UpdateCompanion<Sheet> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> title;
  final Value<String> category;
  final Value<String> description;
  final Value<String> source;
  final Value<int> orderIndex;
  final Value<bool> isBuiltIn;
  const SheetsCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.source = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
  });
  SheetsCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String title,
    required String category,
    this.description = const Value.absent(),
    this.source = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
  }) : slug = Value(slug),
       title = Value(title),
       category = Value(category);
  static Insertable<Sheet> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? source,
    Expression<int>? orderIndex,
    Expression<bool>? isBuiltIn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (source != null) 'source': source,
      if (orderIndex != null) 'order_index': orderIndex,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
    });
  }

  SheetsCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? title,
    Value<String>? category,
    Value<String>? description,
    Value<String>? source,
    Value<int>? orderIndex,
    Value<bool>? isBuiltIn,
  }) {
    return SheetsCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      source: source ?? this.source,
      orderIndex: orderIndex ?? this.orderIndex,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SheetsCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('source: $source, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }
}

class $NodesTable extends Nodes with TableInfo<$NodesTable, Node> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('leaf'),
  );
  static const VerificationMeta _leafTypeMeta = const VerificationMeta(
    'leafType',
  );
  @override
  late final GeneratedColumn<String> leafType = GeneratedColumn<String>(
    'leaf_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('problem'),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _companiesMeta = const VerificationMeta(
    'companies',
  );
  @override
  late final GeneratedColumn<String> companies = GeneratedColumn<String>(
    'companies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _canonMeta = const VerificationMeta('canon');
  @override
  late final GeneratedColumn<String> canon = GeneratedColumn<String>(
    'canon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<int> depth = GeneratedColumn<int>(
    'depth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    sheetId,
    parentId,
    slug,
    title,
    kind,
    leafType,
    difficulty,
    url,
    platform,
    resourceUrl,
    tags,
    companies,
    canon,
    depth,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Node> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('leaf_type')) {
      context.handle(
        _leafTypeMeta,
        leafType.isAcceptableOrUnknown(data['leaf_type']!, _leafTypeMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('companies')) {
      context.handle(
        _companiesMeta,
        companies.isAcceptableOrUnknown(data['companies']!, _companiesMeta),
      );
    }
    if (data.containsKey('canon')) {
      context.handle(
        _canonMeta,
        canon.isAcceptableOrUnknown(data['canon']!, _canonMeta),
      );
    }
    if (data.containsKey('depth')) {
      context.handle(
        _depthMeta,
        depth.isAcceptableOrUnknown(data['depth']!, _depthMeta),
      );
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
  Node map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Node(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      leafType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaf_type'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      companies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}companies'],
      )!,
      canon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canon'],
      )!,
      depth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depth'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $NodesTable createAlias(String alias) {
    return $NodesTable(attachedDatabase, alias);
  }
}

class Node extends DataClass implements Insertable<Node> {
  final int id;
  final int sheetId;
  final int? parentId;
  final String slug;
  final String title;
  final String kind;
  final String leafType;
  final String difficulty;
  final String url;
  final String platform;
  final String resourceUrl;
  final String tags;
  final String companies;

  /// Canonical dedup key for leaves (e.g. `lc:two-sum`); `u:slug` when unique.
  final String canon;
  final int depth;
  final int orderIndex;
  const Node({
    required this.id,
    required this.sheetId,
    this.parentId,
    required this.slug,
    required this.title,
    required this.kind,
    required this.leafType,
    required this.difficulty,
    required this.url,
    required this.platform,
    required this.resourceUrl,
    required this.tags,
    required this.companies,
    required this.canon,
    required this.depth,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sheet_id'] = Variable<int>(sheetId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['slug'] = Variable<String>(slug);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    map['leaf_type'] = Variable<String>(leafType);
    map['difficulty'] = Variable<String>(difficulty);
    map['url'] = Variable<String>(url);
    map['platform'] = Variable<String>(platform);
    map['resource_url'] = Variable<String>(resourceUrl);
    map['tags'] = Variable<String>(tags);
    map['companies'] = Variable<String>(companies);
    map['canon'] = Variable<String>(canon);
    map['depth'] = Variable<int>(depth);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  NodesCompanion toCompanion(bool nullToAbsent) {
    return NodesCompanion(
      id: Value(id),
      sheetId: Value(sheetId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      slug: Value(slug),
      title: Value(title),
      kind: Value(kind),
      leafType: Value(leafType),
      difficulty: Value(difficulty),
      url: Value(url),
      platform: Value(platform),
      resourceUrl: Value(resourceUrl),
      tags: Value(tags),
      companies: Value(companies),
      canon: Value(canon),
      depth: Value(depth),
      orderIndex: Value(orderIndex),
    );
  }

  factory Node.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Node(
      id: serializer.fromJson<int>(json['id']),
      sheetId: serializer.fromJson<int>(json['sheetId']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      slug: serializer.fromJson<String>(json['slug']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      leafType: serializer.fromJson<String>(json['leafType']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      url: serializer.fromJson<String>(json['url']),
      platform: serializer.fromJson<String>(json['platform']),
      resourceUrl: serializer.fromJson<String>(json['resourceUrl']),
      tags: serializer.fromJson<String>(json['tags']),
      companies: serializer.fromJson<String>(json['companies']),
      canon: serializer.fromJson<String>(json['canon']),
      depth: serializer.fromJson<int>(json['depth']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sheetId': serializer.toJson<int>(sheetId),
      'parentId': serializer.toJson<int?>(parentId),
      'slug': serializer.toJson<String>(slug),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'leafType': serializer.toJson<String>(leafType),
      'difficulty': serializer.toJson<String>(difficulty),
      'url': serializer.toJson<String>(url),
      'platform': serializer.toJson<String>(platform),
      'resourceUrl': serializer.toJson<String>(resourceUrl),
      'tags': serializer.toJson<String>(tags),
      'companies': serializer.toJson<String>(companies),
      'canon': serializer.toJson<String>(canon),
      'depth': serializer.toJson<int>(depth),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Node copyWith({
    int? id,
    int? sheetId,
    Value<int?> parentId = const Value.absent(),
    String? slug,
    String? title,
    String? kind,
    String? leafType,
    String? difficulty,
    String? url,
    String? platform,
    String? resourceUrl,
    String? tags,
    String? companies,
    String? canon,
    int? depth,
    int? orderIndex,
  }) => Node(
    id: id ?? this.id,
    sheetId: sheetId ?? this.sheetId,
    parentId: parentId.present ? parentId.value : this.parentId,
    slug: slug ?? this.slug,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    leafType: leafType ?? this.leafType,
    difficulty: difficulty ?? this.difficulty,
    url: url ?? this.url,
    platform: platform ?? this.platform,
    resourceUrl: resourceUrl ?? this.resourceUrl,
    tags: tags ?? this.tags,
    companies: companies ?? this.companies,
    canon: canon ?? this.canon,
    depth: depth ?? this.depth,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  Node copyWithCompanion(NodesCompanion data) {
    return Node(
      id: data.id.present ? data.id.value : this.id,
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      slug: data.slug.present ? data.slug.value : this.slug,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      leafType: data.leafType.present ? data.leafType.value : this.leafType,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      url: data.url.present ? data.url.value : this.url,
      platform: data.platform.present ? data.platform.value : this.platform,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      tags: data.tags.present ? data.tags.value : this.tags,
      companies: data.companies.present ? data.companies.value : this.companies,
      canon: data.canon.present ? data.canon.value : this.canon,
      depth: data.depth.present ? data.depth.value : this.depth,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Node(')
          ..write('id: $id, ')
          ..write('sheetId: $sheetId, ')
          ..write('parentId: $parentId, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('leafType: $leafType, ')
          ..write('difficulty: $difficulty, ')
          ..write('url: $url, ')
          ..write('platform: $platform, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('tags: $tags, ')
          ..write('companies: $companies, ')
          ..write('canon: $canon, ')
          ..write('depth: $depth, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sheetId,
    parentId,
    slug,
    title,
    kind,
    leafType,
    difficulty,
    url,
    platform,
    resourceUrl,
    tags,
    companies,
    canon,
    depth,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Node &&
          other.id == this.id &&
          other.sheetId == this.sheetId &&
          other.parentId == this.parentId &&
          other.slug == this.slug &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.leafType == this.leafType &&
          other.difficulty == this.difficulty &&
          other.url == this.url &&
          other.platform == this.platform &&
          other.resourceUrl == this.resourceUrl &&
          other.tags == this.tags &&
          other.companies == this.companies &&
          other.canon == this.canon &&
          other.depth == this.depth &&
          other.orderIndex == this.orderIndex);
}

class NodesCompanion extends UpdateCompanion<Node> {
  final Value<int> id;
  final Value<int> sheetId;
  final Value<int?> parentId;
  final Value<String> slug;
  final Value<String> title;
  final Value<String> kind;
  final Value<String> leafType;
  final Value<String> difficulty;
  final Value<String> url;
  final Value<String> platform;
  final Value<String> resourceUrl;
  final Value<String> tags;
  final Value<String> companies;
  final Value<String> canon;
  final Value<int> depth;
  final Value<int> orderIndex;
  const NodesCompanion({
    this.id = const Value.absent(),
    this.sheetId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.slug = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.leafType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.url = const Value.absent(),
    this.platform = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.tags = const Value.absent(),
    this.companies = const Value.absent(),
    this.canon = const Value.absent(),
    this.depth = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  NodesCompanion.insert({
    this.id = const Value.absent(),
    required int sheetId,
    this.parentId = const Value.absent(),
    required String slug,
    required String title,
    this.kind = const Value.absent(),
    this.leafType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.url = const Value.absent(),
    this.platform = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.tags = const Value.absent(),
    this.companies = const Value.absent(),
    this.canon = const Value.absent(),
    this.depth = const Value.absent(),
    this.orderIndex = const Value.absent(),
  }) : sheetId = Value(sheetId),
       slug = Value(slug),
       title = Value(title);
  static Insertable<Node> custom({
    Expression<int>? id,
    Expression<int>? sheetId,
    Expression<int>? parentId,
    Expression<String>? slug,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<String>? leafType,
    Expression<String>? difficulty,
    Expression<String>? url,
    Expression<String>? platform,
    Expression<String>? resourceUrl,
    Expression<String>? tags,
    Expression<String>? companies,
    Expression<String>? canon,
    Expression<int>? depth,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sheetId != null) 'sheet_id': sheetId,
      if (parentId != null) 'parent_id': parentId,
      if (slug != null) 'slug': slug,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (leafType != null) 'leaf_type': leafType,
      if (difficulty != null) 'difficulty': difficulty,
      if (url != null) 'url': url,
      if (platform != null) 'platform': platform,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (tags != null) 'tags': tags,
      if (companies != null) 'companies': companies,
      if (canon != null) 'canon': canon,
      if (depth != null) 'depth': depth,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  NodesCompanion copyWith({
    Value<int>? id,
    Value<int>? sheetId,
    Value<int?>? parentId,
    Value<String>? slug,
    Value<String>? title,
    Value<String>? kind,
    Value<String>? leafType,
    Value<String>? difficulty,
    Value<String>? url,
    Value<String>? platform,
    Value<String>? resourceUrl,
    Value<String>? tags,
    Value<String>? companies,
    Value<String>? canon,
    Value<int>? depth,
    Value<int>? orderIndex,
  }) {
    return NodesCompanion(
      id: id ?? this.id,
      sheetId: sheetId ?? this.sheetId,
      parentId: parentId ?? this.parentId,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      leafType: leafType ?? this.leafType,
      difficulty: difficulty ?? this.difficulty,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      tags: tags ?? this.tags,
      companies: companies ?? this.companies,
      canon: canon ?? this.canon,
      depth: depth ?? this.depth,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (leafType.present) {
      map['leaf_type'] = Variable<String>(leafType.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (companies.present) {
      map['companies'] = Variable<String>(companies.value);
    }
    if (canon.present) {
      map['canon'] = Variable<String>(canon.value);
    }
    if (depth.present) {
      map['depth'] = Variable<int>(depth.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NodesCompanion(')
          ..write('id: $id, ')
          ..write('sheetId: $sheetId, ')
          ..write('parentId: $parentId, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('leafType: $leafType, ')
          ..write('difficulty: $difficulty, ')
          ..write('url: $url, ')
          ..write('platform: $platform, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('tags: $tags, ')
          ..write('companies: $companies, ')
          ..write('canon: $canon, ')
          ..write('depth: $depth, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $UserSheetsTable extends UserSheets
    with TableInfo<$UserSheetsTable, UserSheet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSheetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, active, isPrimary, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_sheets';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSheet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId};
  @override
  UserSheet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSheet(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $UserSheetsTable createAlias(String alias) {
    return $UserSheetsTable(attachedDatabase, alias);
  }
}

class UserSheet extends DataClass implements Insertable<UserSheet> {
  final int sheetId;
  final bool active;
  final bool isPrimary;
  final DateTime addedAt;
  const UserSheet({
    required this.sheetId,
    required this.active,
    required this.isPrimary,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['active'] = Variable<bool>(active);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  UserSheetsCompanion toCompanion(bool nullToAbsent) {
    return UserSheetsCompanion(
      sheetId: Value(sheetId),
      active: Value(active),
      isPrimary: Value(isPrimary),
      addedAt: Value(addedAt),
    );
  }

  factory UserSheet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSheet(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      active: serializer.fromJson<bool>(json['active']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'active': serializer.toJson<bool>(active),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  UserSheet copyWith({
    int? sheetId,
    bool? active,
    bool? isPrimary,
    DateTime? addedAt,
  }) => UserSheet(
    sheetId: sheetId ?? this.sheetId,
    active: active ?? this.active,
    isPrimary: isPrimary ?? this.isPrimary,
    addedAt: addedAt ?? this.addedAt,
  );
  UserSheet copyWithCompanion(UserSheetsCompanion data) {
    return UserSheet(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      active: data.active.present ? data.active.value : this.active,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSheet(')
          ..write('sheetId: $sheetId, ')
          ..write('active: $active, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, active, isPrimary, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSheet &&
          other.sheetId == this.sheetId &&
          other.active == this.active &&
          other.isPrimary == this.isPrimary &&
          other.addedAt == this.addedAt);
}

class UserSheetsCompanion extends UpdateCompanion<UserSheet> {
  final Value<int> sheetId;
  final Value<bool> active;
  final Value<bool> isPrimary;
  final Value<DateTime> addedAt;
  const UserSheetsCompanion({
    this.sheetId = const Value.absent(),
    this.active = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  UserSheetsCompanion.insert({
    this.sheetId = const Value.absent(),
    this.active = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  static Insertable<UserSheet> custom({
    Expression<int>? sheetId,
    Expression<bool>? active,
    Expression<bool>? isPrimary,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (active != null) 'active': active,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  UserSheetsCompanion copyWith({
    Value<int>? sheetId,
    Value<bool>? active,
    Value<bool>? isPrimary,
    Value<DateTime>? addedAt,
  }) {
    return UserSheetsCompanion(
      sheetId: sheetId ?? this.sheetId,
      active: active ?? this.active,
      isPrimary: isPrimary ?? this.isPrimary,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSheetsCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('active: $active, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $LeafProgressTable extends LeafProgress
    with TableInfo<$LeafProgressTable, LeafProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeafProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _canonMeta = const VerificationMeta('canon');
  @override
  late final GeneratedColumn<String> canon = GeneratedColumn<String>(
    'canon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('todo'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _timeSpentMinutesMeta = const VerificationMeta(
    'timeSpentMinutes',
  );
  @override
  late final GeneratedColumn<int> timeSpentMinutes = GeneratedColumn<int>(
    'time_spent_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bookmarkedMeta = const VerificationMeta(
    'bookmarked',
  );
  @override
  late final GeneratedColumn<bool> bookmarked = GeneratedColumn<bool>(
    'bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _solvedAtMeta = const VerificationMeta(
    'solvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> solvedAt = GeneratedColumn<DateTime>(
    'solved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewIntervalMeta = const VerificationMeta(
    'reviewInterval',
  );
  @override
  late final GeneratedColumn<int> reviewInterval = GeneratedColumn<int>(
    'review_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    canon,
    status,
    note,
    timeSpentMinutes,
    bookmarked,
    solvedAt,
    nextReviewAt,
    reviewInterval,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaf_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeafProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('canon')) {
      context.handle(
        _canonMeta,
        canon.isAcceptableOrUnknown(data['canon']!, _canonMeta),
      );
    } else if (isInserting) {
      context.missing(_canonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('time_spent_minutes')) {
      context.handle(
        _timeSpentMinutesMeta,
        timeSpentMinutes.isAcceptableOrUnknown(
          data['time_spent_minutes']!,
          _timeSpentMinutesMeta,
        ),
      );
    }
    if (data.containsKey('bookmarked')) {
      context.handle(
        _bookmarkedMeta,
        bookmarked.isAcceptableOrUnknown(data['bookmarked']!, _bookmarkedMeta),
      );
    }
    if (data.containsKey('solved_at')) {
      context.handle(
        _solvedAtMeta,
        solvedAt.isAcceptableOrUnknown(data['solved_at']!, _solvedAtMeta),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('review_interval')) {
      context.handle(
        _reviewIntervalMeta,
        reviewInterval.isAcceptableOrUnknown(
          data['review_interval']!,
          _reviewIntervalMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {canon};
  @override
  LeafProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeafProgressData(
      canon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canon'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      timeSpentMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_spent_minutes'],
      )!,
      bookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bookmarked'],
      )!,
      solvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}solved_at'],
      ),
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
      reviewInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_interval'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LeafProgressTable createAlias(String alias) {
    return $LeafProgressTable(attachedDatabase, alias);
  }
}

class LeafProgressData extends DataClass
    implements Insertable<LeafProgressData> {
  final String canon;
  final String status;
  final String note;
  final int timeSpentMinutes;
  final bool bookmarked;
  final DateTime? solvedAt;
  final DateTime? nextReviewAt;
  final int reviewInterval;
  final DateTime updatedAt;
  const LeafProgressData({
    required this.canon,
    required this.status,
    required this.note,
    required this.timeSpentMinutes,
    required this.bookmarked,
    this.solvedAt,
    this.nextReviewAt,
    required this.reviewInterval,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['canon'] = Variable<String>(canon);
    map['status'] = Variable<String>(status);
    map['note'] = Variable<String>(note);
    map['time_spent_minutes'] = Variable<int>(timeSpentMinutes);
    map['bookmarked'] = Variable<bool>(bookmarked);
    if (!nullToAbsent || solvedAt != null) {
      map['solved_at'] = Variable<DateTime>(solvedAt);
    }
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    map['review_interval'] = Variable<int>(reviewInterval);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LeafProgressCompanion toCompanion(bool nullToAbsent) {
    return LeafProgressCompanion(
      canon: Value(canon),
      status: Value(status),
      note: Value(note),
      timeSpentMinutes: Value(timeSpentMinutes),
      bookmarked: Value(bookmarked),
      solvedAt: solvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(solvedAt),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      reviewInterval: Value(reviewInterval),
      updatedAt: Value(updatedAt),
    );
  }

  factory LeafProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeafProgressData(
      canon: serializer.fromJson<String>(json['canon']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String>(json['note']),
      timeSpentMinutes: serializer.fromJson<int>(json['timeSpentMinutes']),
      bookmarked: serializer.fromJson<bool>(json['bookmarked']),
      solvedAt: serializer.fromJson<DateTime?>(json['solvedAt']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      reviewInterval: serializer.fromJson<int>(json['reviewInterval']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'canon': serializer.toJson<String>(canon),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String>(note),
      'timeSpentMinutes': serializer.toJson<int>(timeSpentMinutes),
      'bookmarked': serializer.toJson<bool>(bookmarked),
      'solvedAt': serializer.toJson<DateTime?>(solvedAt),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'reviewInterval': serializer.toJson<int>(reviewInterval),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LeafProgressData copyWith({
    String? canon,
    String? status,
    String? note,
    int? timeSpentMinutes,
    bool? bookmarked,
    Value<DateTime?> solvedAt = const Value.absent(),
    Value<DateTime?> nextReviewAt = const Value.absent(),
    int? reviewInterval,
    DateTime? updatedAt,
  }) => LeafProgressData(
    canon: canon ?? this.canon,
    status: status ?? this.status,
    note: note ?? this.note,
    timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
    bookmarked: bookmarked ?? this.bookmarked,
    solvedAt: solvedAt.present ? solvedAt.value : this.solvedAt,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    reviewInterval: reviewInterval ?? this.reviewInterval,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LeafProgressData copyWithCompanion(LeafProgressCompanion data) {
    return LeafProgressData(
      canon: data.canon.present ? data.canon.value : this.canon,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      timeSpentMinutes: data.timeSpentMinutes.present
          ? data.timeSpentMinutes.value
          : this.timeSpentMinutes,
      bookmarked: data.bookmarked.present
          ? data.bookmarked.value
          : this.bookmarked,
      solvedAt: data.solvedAt.present ? data.solvedAt.value : this.solvedAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      reviewInterval: data.reviewInterval.present
          ? data.reviewInterval.value
          : this.reviewInterval,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeafProgressData(')
          ..write('canon: $canon, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('timeSpentMinutes: $timeSpentMinutes, ')
          ..write('bookmarked: $bookmarked, ')
          ..write('solvedAt: $solvedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('reviewInterval: $reviewInterval, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    canon,
    status,
    note,
    timeSpentMinutes,
    bookmarked,
    solvedAt,
    nextReviewAt,
    reviewInterval,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeafProgressData &&
          other.canon == this.canon &&
          other.status == this.status &&
          other.note == this.note &&
          other.timeSpentMinutes == this.timeSpentMinutes &&
          other.bookmarked == this.bookmarked &&
          other.solvedAt == this.solvedAt &&
          other.nextReviewAt == this.nextReviewAt &&
          other.reviewInterval == this.reviewInterval &&
          other.updatedAt == this.updatedAt);
}

class LeafProgressCompanion extends UpdateCompanion<LeafProgressData> {
  final Value<String> canon;
  final Value<String> status;
  final Value<String> note;
  final Value<int> timeSpentMinutes;
  final Value<bool> bookmarked;
  final Value<DateTime?> solvedAt;
  final Value<DateTime?> nextReviewAt;
  final Value<int> reviewInterval;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LeafProgressCompanion({
    this.canon = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.timeSpentMinutes = const Value.absent(),
    this.bookmarked = const Value.absent(),
    this.solvedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.reviewInterval = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeafProgressCompanion.insert({
    required String canon,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.timeSpentMinutes = const Value.absent(),
    this.bookmarked = const Value.absent(),
    this.solvedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.reviewInterval = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : canon = Value(canon);
  static Insertable<LeafProgressData> custom({
    Expression<String>? canon,
    Expression<String>? status,
    Expression<String>? note,
    Expression<int>? timeSpentMinutes,
    Expression<bool>? bookmarked,
    Expression<DateTime>? solvedAt,
    Expression<DateTime>? nextReviewAt,
    Expression<int>? reviewInterval,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (canon != null) 'canon': canon,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (timeSpentMinutes != null) 'time_spent_minutes': timeSpentMinutes,
      if (bookmarked != null) 'bookmarked': bookmarked,
      if (solvedAt != null) 'solved_at': solvedAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (reviewInterval != null) 'review_interval': reviewInterval,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeafProgressCompanion copyWith({
    Value<String>? canon,
    Value<String>? status,
    Value<String>? note,
    Value<int>? timeSpentMinutes,
    Value<bool>? bookmarked,
    Value<DateTime?>? solvedAt,
    Value<DateTime?>? nextReviewAt,
    Value<int>? reviewInterval,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LeafProgressCompanion(
      canon: canon ?? this.canon,
      status: status ?? this.status,
      note: note ?? this.note,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      bookmarked: bookmarked ?? this.bookmarked,
      solvedAt: solvedAt ?? this.solvedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      reviewInterval: reviewInterval ?? this.reviewInterval,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (canon.present) {
      map['canon'] = Variable<String>(canon.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (timeSpentMinutes.present) {
      map['time_spent_minutes'] = Variable<int>(timeSpentMinutes.value);
    }
    if (bookmarked.present) {
      map['bookmarked'] = Variable<bool>(bookmarked.value);
    }
    if (solvedAt.present) {
      map['solved_at'] = Variable<DateTime>(solvedAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (reviewInterval.present) {
      map['review_interval'] = Variable<int>(reviewInterval.value);
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
    return (StringBuffer('LeafProgressCompanion(')
          ..write('canon: $canon, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('timeSpentMinutes: $timeSpentMinutes, ')
          ..write('bookmarked: $bookmarked, ')
          ..write('solvedAt: $solvedAt, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('reviewInterval: $reviewInterval, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dsa'),
  );
  static const VerificationMeta _problemsSolvedMeta = const VerificationMeta(
    'problemsSolved',
  );
  @override
  late final GeneratedColumn<int> problemsSolved = GeneratedColumn<int>(
    'problems_solved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    durationMinutes,
    category,
    problemsSolved,
    note,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('problems_solved')) {
      context.handle(
        _problemsSolvedMeta,
        problemsSolved.isAcceptableOrUnknown(
          data['problems_solved']!,
          _problemsSolvedMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      problemsSolved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}problems_solved'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final int id;
  final DateTime startedAt;
  final int durationMinutes;
  final String category;
  final int problemsSolved;
  final String note;
  final String source;
  const StudySession({
    required this.id,
    required this.startedAt,
    required this.durationMinutes,
    required this.category,
    required this.problemsSolved,
    required this.note,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['category'] = Variable<String>(category);
    map['problems_solved'] = Variable<int>(problemsSolved);
    map['note'] = Variable<String>(note);
    map['source'] = Variable<String>(source);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      durationMinutes: Value(durationMinutes),
      category: Value(category),
      problemsSolved: Value(problemsSolved),
      note: Value(note),
      source: Value(source),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      category: serializer.fromJson<String>(json['category']),
      problemsSolved: serializer.fromJson<int>(json['problemsSolved']),
      note: serializer.fromJson<String>(json['note']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'category': serializer.toJson<String>(category),
      'problemsSolved': serializer.toJson<int>(problemsSolved),
      'note': serializer.toJson<String>(note),
      'source': serializer.toJson<String>(source),
    };
  }

  StudySession copyWith({
    int? id,
    DateTime? startedAt,
    int? durationMinutes,
    String? category,
    int? problemsSolved,
    String? note,
    String? source,
  }) => StudySession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    category: category ?? this.category,
    problemsSolved: problemsSolved ?? this.problemsSolved,
    note: note ?? this.note,
    source: source ?? this.source,
  );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      category: data.category.present ? data.category.value : this.category,
      problemsSolved: data.problemsSolved.present
          ? data.problemsSolved.value
          : this.problemsSolved,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('category: $category, ')
          ..write('problemsSolved: $problemsSolved, ')
          ..write('note: $note, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    durationMinutes,
    category,
    problemsSolved,
    note,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.category == this.category &&
          other.problemsSolved == this.problemsSolved &&
          other.note == this.note &&
          other.source == this.source);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<int> durationMinutes;
  final Value<String> category;
  final Value<int> problemsSolved;
  final Value<String> note;
  final Value<String> source;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.category = const Value.absent(),
    this.problemsSolved = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required int durationMinutes,
    this.category = const Value.absent(),
    this.problemsSolved = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
  }) : startedAt = Value(startedAt),
       durationMinutes = Value(durationMinutes);
  static Insertable<StudySession> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<int>? durationMinutes,
    Expression<String>? category,
    Expression<int>? problemsSolved,
    Expression<String>? note,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (category != null) 'category': category,
      if (problemsSolved != null) 'problems_solved': problemsSolved,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
    });
  }

  StudySessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<int>? durationMinutes,
    Value<String>? category,
    Value<int>? problemsSolved,
    Value<String>? note,
    Value<String>? source,
  }) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      problemsSolved: problemsSolved ?? this.problemsSolved,
      note: note ?? this.note,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (problemsSolved.present) {
      map['problems_solved'] = Variable<int>(problemsSolved.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('category: $category, ')
          ..write('problemsSolved: $problemsSolved, ')
          ..write('note: $note, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $ActivityDaysTable extends ActivityDays
    with TableInfo<$ActivityDaysTable, ActivityDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _problemsSolvedMeta = const VerificationMeta(
    'problemsSolved',
  );
  @override
  late final GeneratedColumn<int> problemsSolved = GeneratedColumn<int>(
    'problems_solved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _goalMetMeta = const VerificationMeta(
    'goalMet',
  );
  @override
  late final GeneratedColumn<bool> goalMet = GeneratedColumn<bool>(
    'goal_met',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_met" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    minutes,
    problemsSolved,
    xpEarned,
    goalMet,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    if (data.containsKey('problems_solved')) {
      context.handle(
        _problemsSolvedMeta,
        problemsSolved.isAcceptableOrUnknown(
          data['problems_solved']!,
          _problemsSolvedMeta,
        ),
      );
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    }
    if (data.containsKey('goal_met')) {
      context.handle(
        _goalMetMeta,
        goalMet.isAcceptableOrUnknown(data['goal_met']!, _goalMetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  ActivityDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityDay(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      problemsSolved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}problems_solved'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      goalMet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_met'],
      )!,
    );
  }

  @override
  $ActivityDaysTable createAlias(String alias) {
    return $ActivityDaysTable(attachedDatabase, alias);
  }
}

class ActivityDay extends DataClass implements Insertable<ActivityDay> {
  final int day;
  final int minutes;
  final int problemsSolved;
  final int xpEarned;
  final bool goalMet;
  const ActivityDay({
    required this.day,
    required this.minutes,
    required this.problemsSolved,
    required this.xpEarned,
    required this.goalMet,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    map['minutes'] = Variable<int>(minutes);
    map['problems_solved'] = Variable<int>(problemsSolved);
    map['xp_earned'] = Variable<int>(xpEarned);
    map['goal_met'] = Variable<bool>(goalMet);
    return map;
  }

  ActivityDaysCompanion toCompanion(bool nullToAbsent) {
    return ActivityDaysCompanion(
      day: Value(day),
      minutes: Value(minutes),
      problemsSolved: Value(problemsSolved),
      xpEarned: Value(xpEarned),
      goalMet: Value(goalMet),
    );
  }

  factory ActivityDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityDay(
      day: serializer.fromJson<int>(json['day']),
      minutes: serializer.fromJson<int>(json['minutes']),
      problemsSolved: serializer.fromJson<int>(json['problemsSolved']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      goalMet: serializer.fromJson<bool>(json['goalMet']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'minutes': serializer.toJson<int>(minutes),
      'problemsSolved': serializer.toJson<int>(problemsSolved),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'goalMet': serializer.toJson<bool>(goalMet),
    };
  }

  ActivityDay copyWith({
    int? day,
    int? minutes,
    int? problemsSolved,
    int? xpEarned,
    bool? goalMet,
  }) => ActivityDay(
    day: day ?? this.day,
    minutes: minutes ?? this.minutes,
    problemsSolved: problemsSolved ?? this.problemsSolved,
    xpEarned: xpEarned ?? this.xpEarned,
    goalMet: goalMet ?? this.goalMet,
  );
  ActivityDay copyWithCompanion(ActivityDaysCompanion data) {
    return ActivityDay(
      day: data.day.present ? data.day.value : this.day,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      problemsSolved: data.problemsSolved.present
          ? data.problemsSolved.value
          : this.problemsSolved,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      goalMet: data.goalMet.present ? data.goalMet.value : this.goalMet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityDay(')
          ..write('day: $day, ')
          ..write('minutes: $minutes, ')
          ..write('problemsSolved: $problemsSolved, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('goalMet: $goalMet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(day, minutes, problemsSolved, xpEarned, goalMet);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityDay &&
          other.day == this.day &&
          other.minutes == this.minutes &&
          other.problemsSolved == this.problemsSolved &&
          other.xpEarned == this.xpEarned &&
          other.goalMet == this.goalMet);
}

class ActivityDaysCompanion extends UpdateCompanion<ActivityDay> {
  final Value<int> day;
  final Value<int> minutes;
  final Value<int> problemsSolved;
  final Value<int> xpEarned;
  final Value<bool> goalMet;
  const ActivityDaysCompanion({
    this.day = const Value.absent(),
    this.minutes = const Value.absent(),
    this.problemsSolved = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.goalMet = const Value.absent(),
  });
  ActivityDaysCompanion.insert({
    this.day = const Value.absent(),
    this.minutes = const Value.absent(),
    this.problemsSolved = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.goalMet = const Value.absent(),
  });
  static Insertable<ActivityDay> custom({
    Expression<int>? day,
    Expression<int>? minutes,
    Expression<int>? problemsSolved,
    Expression<int>? xpEarned,
    Expression<bool>? goalMet,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (minutes != null) 'minutes': minutes,
      if (problemsSolved != null) 'problems_solved': problemsSolved,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (goalMet != null) 'goal_met': goalMet,
    });
  }

  ActivityDaysCompanion copyWith({
    Value<int>? day,
    Value<int>? minutes,
    Value<int>? problemsSolved,
    Value<int>? xpEarned,
    Value<bool>? goalMet,
  }) {
    return ActivityDaysCompanion(
      day: day ?? this.day,
      minutes: minutes ?? this.minutes,
      problemsSolved: problemsSolved ?? this.problemsSolved,
      xpEarned: xpEarned ?? this.xpEarned,
      goalMet: goalMet ?? this.goalMet,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (problemsSolved.present) {
      map['problems_solved'] = Variable<int>(problemsSolved.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (goalMet.present) {
      map['goal_met'] = Variable<bool>(goalMet.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityDaysCompanion(')
          ..write('day: $day, ')
          ..write('minutes: $minutes, ')
          ..write('problemsSolved: $problemsSolved, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('goalMet: $goalMet')
          ..write(')'))
        .toString();
  }
}

class $ResourcesTable extends Resources
    with TableInfo<$ResourcesTable, Resource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _affiliateUrlMeta = const VerificationMeta(
    'affiliateUrl',
  );
  @override
  late final GeneratedColumn<String> affiliateUrl = GeneratedColumn<String>(
    'affiliate_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('link'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
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
    slug,
    title,
    provider,
    description,
    url,
    affiliateUrl,
    type,
    category,
    tier,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Resource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('affiliate_url')) {
      context.handle(
        _affiliateUrlMeta,
        affiliateUrl.isAcceptableOrUnknown(
          data['affiliate_url']!,
          _affiliateUrlMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
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
  Resource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Resource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      affiliateUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}affiliate_url'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $ResourcesTable createAlias(String alias) {
    return $ResourcesTable(attachedDatabase, alias);
  }
}

class Resource extends DataClass implements Insertable<Resource> {
  final int id;
  final String slug;
  final String title;
  final String provider;
  final String description;
  final String url;
  final String affiliateUrl;
  final String type;
  final String category;
  final String tier;
  final int orderIndex;
  const Resource({
    required this.id,
    required this.slug,
    required this.title,
    required this.provider,
    required this.description,
    required this.url,
    required this.affiliateUrl,
    required this.type,
    required this.category,
    required this.tier,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['title'] = Variable<String>(title);
    map['provider'] = Variable<String>(provider);
    map['description'] = Variable<String>(description);
    map['url'] = Variable<String>(url);
    map['affiliate_url'] = Variable<String>(affiliateUrl);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['tier'] = Variable<String>(tier);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  ResourcesCompanion toCompanion(bool nullToAbsent) {
    return ResourcesCompanion(
      id: Value(id),
      slug: Value(slug),
      title: Value(title),
      provider: Value(provider),
      description: Value(description),
      url: Value(url),
      affiliateUrl: Value(affiliateUrl),
      type: Value(type),
      category: Value(category),
      tier: Value(tier),
      orderIndex: Value(orderIndex),
    );
  }

  factory Resource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Resource(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      title: serializer.fromJson<String>(json['title']),
      provider: serializer.fromJson<String>(json['provider']),
      description: serializer.fromJson<String>(json['description']),
      url: serializer.fromJson<String>(json['url']),
      affiliateUrl: serializer.fromJson<String>(json['affiliateUrl']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      tier: serializer.fromJson<String>(json['tier']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'title': serializer.toJson<String>(title),
      'provider': serializer.toJson<String>(provider),
      'description': serializer.toJson<String>(description),
      'url': serializer.toJson<String>(url),
      'affiliateUrl': serializer.toJson<String>(affiliateUrl),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'tier': serializer.toJson<String>(tier),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Resource copyWith({
    int? id,
    String? slug,
    String? title,
    String? provider,
    String? description,
    String? url,
    String? affiliateUrl,
    String? type,
    String? category,
    String? tier,
    int? orderIndex,
  }) => Resource(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    title: title ?? this.title,
    provider: provider ?? this.provider,
    description: description ?? this.description,
    url: url ?? this.url,
    affiliateUrl: affiliateUrl ?? this.affiliateUrl,
    type: type ?? this.type,
    category: category ?? this.category,
    tier: tier ?? this.tier,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  Resource copyWithCompanion(ResourcesCompanion data) {
    return Resource(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      title: data.title.present ? data.title.value : this.title,
      provider: data.provider.present ? data.provider.value : this.provider,
      description: data.description.present
          ? data.description.value
          : this.description,
      url: data.url.present ? data.url.value : this.url,
      affiliateUrl: data.affiliateUrl.present
          ? data.affiliateUrl.value
          : this.affiliateUrl,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      tier: data.tier.present ? data.tier.value : this.tier,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Resource(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('provider: $provider, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('affiliateUrl: $affiliateUrl, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('tier: $tier, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    title,
    provider,
    description,
    url,
    affiliateUrl,
    type,
    category,
    tier,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Resource &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.title == this.title &&
          other.provider == this.provider &&
          other.description == this.description &&
          other.url == this.url &&
          other.affiliateUrl == this.affiliateUrl &&
          other.type == this.type &&
          other.category == this.category &&
          other.tier == this.tier &&
          other.orderIndex == this.orderIndex);
}

class ResourcesCompanion extends UpdateCompanion<Resource> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> title;
  final Value<String> provider;
  final Value<String> description;
  final Value<String> url;
  final Value<String> affiliateUrl;
  final Value<String> type;
  final Value<String> category;
  final Value<String> tier;
  final Value<int> orderIndex;
  const ResourcesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.title = const Value.absent(),
    this.provider = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.affiliateUrl = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.tier = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  ResourcesCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String title,
    this.provider = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
    this.affiliateUrl = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.tier = const Value.absent(),
    this.orderIndex = const Value.absent(),
  }) : slug = Value(slug),
       title = Value(title);
  static Insertable<Resource> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? title,
    Expression<String>? provider,
    Expression<String>? description,
    Expression<String>? url,
    Expression<String>? affiliateUrl,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? tier,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (title != null) 'title': title,
      if (provider != null) 'provider': provider,
      if (description != null) 'description': description,
      if (url != null) 'url': url,
      if (affiliateUrl != null) 'affiliate_url': affiliateUrl,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (tier != null) 'tier': tier,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  ResourcesCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? title,
    Value<String>? provider,
    Value<String>? description,
    Value<String>? url,
    Value<String>? affiliateUrl,
    Value<String>? type,
    Value<String>? category,
    Value<String>? tier,
    Value<int>? orderIndex,
  }) {
    return ResourcesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      description: description ?? this.description,
      url: url ?? this.url,
      affiliateUrl: affiliateUrl ?? this.affiliateUrl,
      type: type ?? this.type,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (affiliateUrl.present) {
      map['affiliate_url'] = Variable<String>(affiliateUrl.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourcesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('provider: $provider, ')
          ..write('description: $description, ')
          ..write('url: $url, ')
          ..write('affiliateUrl: $affiliateUrl, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('tier: $tier, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String key;
  final DateTime unlockedAt;
  const Achievement({required this.key, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      key: Value(key),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      key: serializer.fromJson<String>(json['key']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  Achievement copyWith({String? key, DateTime? unlockedAt}) => Achievement(
    key: key ?? this.key,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      key: data.key.present ? data.key.value : this.key,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('key: $key, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.key == this.key &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> key;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.key = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String key,
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Achievement> custom({
    Expression<String>? key,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? key,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      key: key ?? this.key,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('key: $key, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimetableBlocksTable extends TimetableBlocks
    with TableInfo<$TimetableBlocksTable, TimetableBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _daysMaskMeta = const VerificationMeta(
    'daysMask',
  );
  @override
  late final GeneratedColumn<int> daysMask = GeneratedColumn<int>(
    'days_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _reminderMeta = const VerificationMeta(
    'reminder',
  );
  @override
  late final GeneratedColumn<bool> reminder = GeneratedColumn<bool>(
    'reminder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _leadMinutesMeta = const VerificationMeta(
    'leadMinutes',
  );
  @override
  late final GeneratedColumn<int> leadMinutes = GeneratedColumn<int>(
    'lead_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    startMinute,
    durationMinutes,
    daysMask,
    reminder,
    leadMinutes,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetableBlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('days_mask')) {
      context.handle(
        _daysMaskMeta,
        daysMask.isAcceptableOrUnknown(data['days_mask']!, _daysMaskMeta),
      );
    }
    if (data.containsKey('reminder')) {
      context.handle(
        _reminderMeta,
        reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta),
      );
    }
    if (data.containsKey('lead_minutes')) {
      context.handle(
        _leadMinutesMeta,
        leadMinutes.isAcceptableOrUnknown(
          data['lead_minutes']!,
          _leadMinutesMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetableBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableBlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      daysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_mask'],
      )!,
      reminder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder'],
      )!,
      leadMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lead_minutes'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $TimetableBlocksTable createAlias(String alias) {
    return $TimetableBlocksTable(attachedDatabase, alias);
  }
}

class TimetableBlock extends DataClass implements Insertable<TimetableBlock> {
  final int id;
  final String title;

  /// A [PrepCategory] name to tie the block to a subject, or '' for a free-form
  /// habit block (gym, revision, sleep…).
  final String category;

  /// Start time as minutes from midnight (e.g. 7:30 => 450). Stored this way so
  /// it sorts and compares trivially and has no timezone baggage.
  final int startMinute;
  final int durationMinutes;

  /// Which weekdays it repeats on, as a bitmask: bit 0 = Monday … bit 6 =
  /// Sunday. 127 = every day.
  final int daysMask;

  /// Whether to fire a reminder, and how many minutes before the start.
  final bool reminder;
  final int leadMinutes;
  final bool enabled;
  const TimetableBlock({
    required this.id,
    required this.title,
    required this.category,
    required this.startMinute,
    required this.durationMinutes,
    required this.daysMask,
    required this.reminder,
    required this.leadMinutes,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['start_minute'] = Variable<int>(startMinute);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['days_mask'] = Variable<int>(daysMask);
    map['reminder'] = Variable<bool>(reminder);
    map['lead_minutes'] = Variable<int>(leadMinutes);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  TimetableBlocksCompanion toCompanion(bool nullToAbsent) {
    return TimetableBlocksCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      startMinute: Value(startMinute),
      durationMinutes: Value(durationMinutes),
      daysMask: Value(daysMask),
      reminder: Value(reminder),
      leadMinutes: Value(leadMinutes),
      enabled: Value(enabled),
    );
  }

  factory TimetableBlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableBlock(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      daysMask: serializer.fromJson<int>(json['daysMask']),
      reminder: serializer.fromJson<bool>(json['reminder']),
      leadMinutes: serializer.fromJson<int>(json['leadMinutes']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'startMinute': serializer.toJson<int>(startMinute),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'daysMask': serializer.toJson<int>(daysMask),
      'reminder': serializer.toJson<bool>(reminder),
      'leadMinutes': serializer.toJson<int>(leadMinutes),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  TimetableBlock copyWith({
    int? id,
    String? title,
    String? category,
    int? startMinute,
    int? durationMinutes,
    int? daysMask,
    bool? reminder,
    int? leadMinutes,
    bool? enabled,
  }) => TimetableBlock(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    startMinute: startMinute ?? this.startMinute,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    daysMask: daysMask ?? this.daysMask,
    reminder: reminder ?? this.reminder,
    leadMinutes: leadMinutes ?? this.leadMinutes,
    enabled: enabled ?? this.enabled,
  );
  TimetableBlock copyWithCompanion(TimetableBlocksCompanion data) {
    return TimetableBlock(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      daysMask: data.daysMask.present ? data.daysMask.value : this.daysMask,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
      leadMinutes: data.leadMinutes.present
          ? data.leadMinutes.value
          : this.leadMinutes,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableBlock(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('startMinute: $startMinute, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('daysMask: $daysMask, ')
          ..write('reminder: $reminder, ')
          ..write('leadMinutes: $leadMinutes, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    startMinute,
    durationMinutes,
    daysMask,
    reminder,
    leadMinutes,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableBlock &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.startMinute == this.startMinute &&
          other.durationMinutes == this.durationMinutes &&
          other.daysMask == this.daysMask &&
          other.reminder == this.reminder &&
          other.leadMinutes == this.leadMinutes &&
          other.enabled == this.enabled);
}

class TimetableBlocksCompanion extends UpdateCompanion<TimetableBlock> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> category;
  final Value<int> startMinute;
  final Value<int> durationMinutes;
  final Value<int> daysMask;
  final Value<bool> reminder;
  final Value<int> leadMinutes;
  final Value<bool> enabled;
  const TimetableBlocksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.daysMask = const Value.absent(),
    this.reminder = const Value.absent(),
    this.leadMinutes = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  TimetableBlocksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.category = const Value.absent(),
    required int startMinute,
    this.durationMinutes = const Value.absent(),
    this.daysMask = const Value.absent(),
    this.reminder = const Value.absent(),
    this.leadMinutes = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : title = Value(title),
       startMinute = Value(startMinute);
  static Insertable<TimetableBlock> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<int>? startMinute,
    Expression<int>? durationMinutes,
    Expression<int>? daysMask,
    Expression<bool>? reminder,
    Expression<int>? leadMinutes,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (startMinute != null) 'start_minute': startMinute,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (daysMask != null) 'days_mask': daysMask,
      if (reminder != null) 'reminder': reminder,
      if (leadMinutes != null) 'lead_minutes': leadMinutes,
      if (enabled != null) 'enabled': enabled,
    });
  }

  TimetableBlocksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? category,
    Value<int>? startMinute,
    Value<int>? durationMinutes,
    Value<int>? daysMask,
    Value<bool>? reminder,
    Value<int>? leadMinutes,
    Value<bool>? enabled,
  }) {
    return TimetableBlocksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startMinute: startMinute ?? this.startMinute,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      daysMask: daysMask ?? this.daysMask,
      reminder: reminder ?? this.reminder,
      leadMinutes: leadMinutes ?? this.leadMinutes,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (daysMask.present) {
      map['days_mask'] = Variable<int>(daysMask.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<bool>(reminder.value);
    }
    if (leadMinutes.present) {
      map['lead_minutes'] = Variable<int>(leadMinutes.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableBlocksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('startMinute: $startMinute, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('daysMask: $daysMask, ')
          ..write('reminder: $reminder, ')
          ..write('leadMinutes: $leadMinutes, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SheetsTable sheets = $SheetsTable(this);
  late final $NodesTable nodes = $NodesTable(this);
  late final $UserSheetsTable userSheets = $UserSheetsTable(this);
  late final $LeafProgressTable leafProgress = $LeafProgressTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $ActivityDaysTable activityDays = $ActivityDaysTable(this);
  late final $ResourcesTable resources = $ResourcesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $TimetableBlocksTable timetableBlocks = $TimetableBlocksTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    sheets,
    nodes,
    userSheets,
    leafProgress,
    studySessions,
    activityDays,
    resources,
    achievements,
    timetableBlocks,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sheets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('nodes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sheets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_sheets', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> targetRole,
      Value<String> targetCompanies,
      Value<String> skillLevel,
      Value<int> dailyGoalMinutes,
      Value<DateTime?> targetDate,
      Value<int> xp,
      Value<bool> onboarded,
      Value<DateTime> createdAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> targetRole,
      Value<String> targetCompanies,
      Value<String> skillLevel,
      Value<int> dailyGoalMinutes,
      Value<DateTime?> targetDate,
      Value<int> xp,
      Value<bool> onboarded,
      Value<DateTime> createdAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetRole => $composableBuilder(
    column: $table.targetRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetCompanies => $composableBuilder(
    column: $table.targetCompanies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skillLevel => $composableBuilder(
    column: $table.skillLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetRole => $composableBuilder(
    column: $table.targetRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetCompanies => $composableBuilder(
    column: $table.targetCompanies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skillLevel => $composableBuilder(
    column: $table.skillLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
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

  GeneratedColumn<String> get targetRole => $composableBuilder(
    column: $table.targetRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetCompanies => $composableBuilder(
    column: $table.targetCompanies,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skillLevel => $composableBuilder(
    column: $table.skillLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> targetRole = const Value.absent(),
                Value<String> targetCompanies = const Value.absent(),
                Value<String> skillLevel = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                targetRole: targetRole,
                targetCompanies: targetCompanies,
                skillLevel: skillLevel,
                dailyGoalMinutes: dailyGoalMinutes,
                targetDate: targetDate,
                xp: xp,
                onboarded: onboarded,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> targetRole = const Value.absent(),
                Value<String> targetCompanies = const Value.absent(),
                Value<String> skillLevel = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                targetRole: targetRole,
                targetCompanies: targetCompanies,
                skillLevel: skillLevel,
                dailyGoalMinutes: dailyGoalMinutes,
                targetDate: targetDate,
                xp: xp,
                onboarded: onboarded,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$SheetsTableCreateCompanionBuilder =
    SheetsCompanion Function({
      Value<int> id,
      required String slug,
      required String title,
      required String category,
      Value<String> description,
      Value<String> source,
      Value<int> orderIndex,
      Value<bool> isBuiltIn,
    });
typedef $$SheetsTableUpdateCompanionBuilder =
    SheetsCompanion Function({
      Value<int> id,
      Value<String> slug,
      Value<String> title,
      Value<String> category,
      Value<String> description,
      Value<String> source,
      Value<int> orderIndex,
      Value<bool> isBuiltIn,
    });

final class $$SheetsTableReferences
    extends BaseReferences<_$AppDatabase, $SheetsTable, Sheet> {
  $$SheetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NodesTable, List<Node>> _nodesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.nodes,
    aliasName: 'sheets__id__nodes__sheet_id',
  );

  $$NodesTableProcessedTableManager get nodesRefs {
    final manager = $$NodesTableTableManager(
      $_db,
      $_db.nodes,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_nodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserSheetsTable, List<UserSheet>>
  _userSheetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userSheets,
    aliasName: 'sheets__id__user_sheets__sheet_id',
  );

  $$UserSheetsTableProcessedTableManager get userSheetsRefs {
    final manager = $$UserSheetsTableTableManager(
      $_db,
      $_db.userSheets,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userSheetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SheetsTableFilterComposer
    extends Composer<_$AppDatabase, $SheetsTable> {
  $$SheetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> nodesRefs(
    Expression<bool> Function($$NodesTableFilterComposer f) f,
  ) {
    final $$NodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableFilterComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userSheetsRefs(
    Expression<bool> Function($$UserSheetsTableFilterComposer f) f,
  ) {
    final $$UserSheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSheets,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSheetsTableFilterComposer(
            $db: $db,
            $table: $db.userSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SheetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SheetsTable> {
  $$SheetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SheetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SheetsTable> {
  $$SheetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  Expression<T> nodesRefs<T extends Object>(
    Expression<T> Function($$NodesTableAnnotationComposer a) f,
  ) {
    final $$NodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableAnnotationComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userSheetsRefs<T extends Object>(
    Expression<T> Function($$UserSheetsTableAnnotationComposer a) f,
  ) {
    final $$UserSheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSheets,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.userSheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SheetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SheetsTable,
          Sheet,
          $$SheetsTableFilterComposer,
          $$SheetsTableOrderingComposer,
          $$SheetsTableAnnotationComposer,
          $$SheetsTableCreateCompanionBuilder,
          $$SheetsTableUpdateCompanionBuilder,
          (Sheet, $$SheetsTableReferences),
          Sheet,
          PrefetchHooks Function({bool nodesRefs, bool userSheetsRefs})
        > {
  $$SheetsTableTableManager(_$AppDatabase db, $SheetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SheetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SheetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SheetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
              }) => SheetsCompanion(
                id: id,
                slug: slug,
                title: title,
                category: category,
                description: description,
                source: source,
                orderIndex: orderIndex,
                isBuiltIn: isBuiltIn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String title,
                required String category,
                Value<String> description = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
              }) => SheetsCompanion.insert(
                id: id,
                slug: slug,
                title: title,
                category: category,
                description: description,
                source: source,
                orderIndex: orderIndex,
                isBuiltIn: isBuiltIn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SheetsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({nodesRefs = false, userSheetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (nodesRefs) db.nodes,
                if (userSheetsRefs) db.userSheets,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (nodesRefs)
                    await $_getPrefetchedData<Sheet, $SheetsTable, Node>(
                      currentTable: table,
                      referencedTable: $$SheetsTableReferences._nodesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SheetsTableReferences(db, table, p0).nodesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sheetId == item.id),
                      typedResults: items,
                    ),
                  if (userSheetsRefs)
                    await $_getPrefetchedData<Sheet, $SheetsTable, UserSheet>(
                      currentTable: table,
                      referencedTable: $$SheetsTableReferences
                          ._userSheetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SheetsTableReferences(db, table, p0).userSheetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sheetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SheetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SheetsTable,
      Sheet,
      $$SheetsTableFilterComposer,
      $$SheetsTableOrderingComposer,
      $$SheetsTableAnnotationComposer,
      $$SheetsTableCreateCompanionBuilder,
      $$SheetsTableUpdateCompanionBuilder,
      (Sheet, $$SheetsTableReferences),
      Sheet,
      PrefetchHooks Function({bool nodesRefs, bool userSheetsRefs})
    >;
typedef $$NodesTableCreateCompanionBuilder =
    NodesCompanion Function({
      Value<int> id,
      required int sheetId,
      Value<int?> parentId,
      required String slug,
      required String title,
      Value<String> kind,
      Value<String> leafType,
      Value<String> difficulty,
      Value<String> url,
      Value<String> platform,
      Value<String> resourceUrl,
      Value<String> tags,
      Value<String> companies,
      Value<String> canon,
      Value<int> depth,
      Value<int> orderIndex,
    });
typedef $$NodesTableUpdateCompanionBuilder =
    NodesCompanion Function({
      Value<int> id,
      Value<int> sheetId,
      Value<int?> parentId,
      Value<String> slug,
      Value<String> title,
      Value<String> kind,
      Value<String> leafType,
      Value<String> difficulty,
      Value<String> url,
      Value<String> platform,
      Value<String> resourceUrl,
      Value<String> tags,
      Value<String> companies,
      Value<String> canon,
      Value<int> depth,
      Value<int> orderIndex,
    });

final class $$NodesTableReferences
    extends BaseReferences<_$AppDatabase, $NodesTable, Node> {
  $$NodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SheetsTable _sheetIdTable(_$AppDatabase db) =>
      db.sheets.createAlias('nodes__sheet_id__sheets__id');

  $$SheetsTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetsTableTableManager(
      $_db,
      $_db.sheets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NodesTableFilterComposer extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leafType => $composableBuilder(
    column: $table.leafType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companies => $composableBuilder(
    column: $table.companies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canon => $composableBuilder(
    column: $table.canon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetsTableFilterComposer get sheetId {
    final $$SheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableFilterComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NodesTableOrderingComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leafType => $composableBuilder(
    column: $table.leafType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companies => $composableBuilder(
    column: $table.companies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canon => $composableBuilder(
    column: $table.canon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetsTableOrderingComposer get sheetId {
    final $$SheetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableOrderingComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get leafType =>
      $composableBuilder(column: $table.leafType, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get companies =>
      $composableBuilder(column: $table.companies, builder: (column) => column);

  GeneratedColumn<String> get canon =>
      $composableBuilder(column: $table.canon, builder: (column) => column);

  GeneratedColumn<int> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$SheetsTableAnnotationComposer get sheetId {
    final $$SheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NodesTable,
          Node,
          $$NodesTableFilterComposer,
          $$NodesTableOrderingComposer,
          $$NodesTableAnnotationComposer,
          $$NodesTableCreateCompanionBuilder,
          $$NodesTableUpdateCompanionBuilder,
          (Node, $$NodesTableReferences),
          Node,
          PrefetchHooks Function({bool sheetId})
        > {
  $$NodesTableTableManager(_$AppDatabase db, $NodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sheetId = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> leafType = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> resourceUrl = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> companies = const Value.absent(),
                Value<String> canon = const Value.absent(),
                Value<int> depth = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => NodesCompanion(
                id: id,
                sheetId: sheetId,
                parentId: parentId,
                slug: slug,
                title: title,
                kind: kind,
                leafType: leafType,
                difficulty: difficulty,
                url: url,
                platform: platform,
                resourceUrl: resourceUrl,
                tags: tags,
                companies: companies,
                canon: canon,
                depth: depth,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sheetId,
                Value<int?> parentId = const Value.absent(),
                required String slug,
                required String title,
                Value<String> kind = const Value.absent(),
                Value<String> leafType = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> resourceUrl = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> companies = const Value.absent(),
                Value<String> canon = const Value.absent(),
                Value<int> depth = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => NodesCompanion.insert(
                id: id,
                sheetId: sheetId,
                parentId: parentId,
                slug: slug,
                title: title,
                kind: kind,
                leafType: leafType,
                difficulty: difficulty,
                url: url,
                platform: platform,
                resourceUrl: resourceUrl,
                tags: tags,
                companies: companies,
                canon: canon,
                depth: depth,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NodesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$NodesTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$NodesTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NodesTable,
      Node,
      $$NodesTableFilterComposer,
      $$NodesTableOrderingComposer,
      $$NodesTableAnnotationComposer,
      $$NodesTableCreateCompanionBuilder,
      $$NodesTableUpdateCompanionBuilder,
      (Node, $$NodesTableReferences),
      Node,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$UserSheetsTableCreateCompanionBuilder =
    UserSheetsCompanion Function({
      Value<int> sheetId,
      Value<bool> active,
      Value<bool> isPrimary,
      Value<DateTime> addedAt,
    });
typedef $$UserSheetsTableUpdateCompanionBuilder =
    UserSheetsCompanion Function({
      Value<int> sheetId,
      Value<bool> active,
      Value<bool> isPrimary,
      Value<DateTime> addedAt,
    });

final class $$UserSheetsTableReferences
    extends BaseReferences<_$AppDatabase, $UserSheetsTable, UserSheet> {
  $$UserSheetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SheetsTable _sheetIdTable(_$AppDatabase db) =>
      db.sheets.createAlias('user_sheets__sheet_id__sheets__id');

  $$SheetsTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetsTableTableManager(
      $_db,
      $_db.sheets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserSheetsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSheetsTable> {
  $$UserSheetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetsTableFilterComposer get sheetId {
    final $$SheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableFilterComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSheetsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSheetsTable> {
  $$UserSheetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetsTableOrderingComposer get sheetId {
    final $$SheetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableOrderingComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSheetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSheetsTable> {
  $$UserSheetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$SheetsTableAnnotationComposer get sheetId {
    final $$SheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSheetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSheetsTable,
          UserSheet,
          $$UserSheetsTableFilterComposer,
          $$UserSheetsTableOrderingComposer,
          $$UserSheetsTableAnnotationComposer,
          $$UserSheetsTableCreateCompanionBuilder,
          $$UserSheetsTableUpdateCompanionBuilder,
          (UserSheet, $$UserSheetsTableReferences),
          UserSheet,
          PrefetchHooks Function({bool sheetId})
        > {
  $$UserSheetsTableTableManager(_$AppDatabase db, $UserSheetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSheetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSheetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSheetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => UserSheetsCompanion(
                sheetId: sheetId,
                active: active,
                isPrimary: isPrimary,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => UserSheetsCompanion.insert(
                sheetId: sheetId,
                active: active,
                isPrimary: isPrimary,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserSheetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$UserSheetsTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$UserSheetsTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserSheetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSheetsTable,
      UserSheet,
      $$UserSheetsTableFilterComposer,
      $$UserSheetsTableOrderingComposer,
      $$UserSheetsTableAnnotationComposer,
      $$UserSheetsTableCreateCompanionBuilder,
      $$UserSheetsTableUpdateCompanionBuilder,
      (UserSheet, $$UserSheetsTableReferences),
      UserSheet,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$LeafProgressTableCreateCompanionBuilder =
    LeafProgressCompanion Function({
      required String canon,
      Value<String> status,
      Value<String> note,
      Value<int> timeSpentMinutes,
      Value<bool> bookmarked,
      Value<DateTime?> solvedAt,
      Value<DateTime?> nextReviewAt,
      Value<int> reviewInterval,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LeafProgressTableUpdateCompanionBuilder =
    LeafProgressCompanion Function({
      Value<String> canon,
      Value<String> status,
      Value<String> note,
      Value<int> timeSpentMinutes,
      Value<bool> bookmarked,
      Value<DateTime?> solvedAt,
      Value<DateTime?> nextReviewAt,
      Value<int> reviewInterval,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LeafProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LeafProgressTable> {
  $$LeafProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get canon => $composableBuilder(
    column: $table.canon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSpentMinutes => $composableBuilder(
    column: $table.timeSpentMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bookmarked => $composableBuilder(
    column: $table.bookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get solvedAt => $composableBuilder(
    column: $table.solvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewInterval => $composableBuilder(
    column: $table.reviewInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeafProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LeafProgressTable> {
  $$LeafProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get canon => $composableBuilder(
    column: $table.canon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSpentMinutes => $composableBuilder(
    column: $table.timeSpentMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bookmarked => $composableBuilder(
    column: $table.bookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get solvedAt => $composableBuilder(
    column: $table.solvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewInterval => $composableBuilder(
    column: $table.reviewInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeafProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeafProgressTable> {
  $$LeafProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get canon =>
      $composableBuilder(column: $table.canon, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get timeSpentMinutes => $composableBuilder(
    column: $table.timeSpentMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bookmarked => $composableBuilder(
    column: $table.bookmarked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get solvedAt =>
      $composableBuilder(column: $table.solvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewInterval => $composableBuilder(
    column: $table.reviewInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LeafProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeafProgressTable,
          LeafProgressData,
          $$LeafProgressTableFilterComposer,
          $$LeafProgressTableOrderingComposer,
          $$LeafProgressTableAnnotationComposer,
          $$LeafProgressTableCreateCompanionBuilder,
          $$LeafProgressTableUpdateCompanionBuilder,
          (
            LeafProgressData,
            BaseReferences<_$AppDatabase, $LeafProgressTable, LeafProgressData>,
          ),
          LeafProgressData,
          PrefetchHooks Function()
        > {
  $$LeafProgressTableTableManager(_$AppDatabase db, $LeafProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeafProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeafProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeafProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> canon = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> timeSpentMinutes = const Value.absent(),
                Value<bool> bookmarked = const Value.absent(),
                Value<DateTime?> solvedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<int> reviewInterval = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeafProgressCompanion(
                canon: canon,
                status: status,
                note: note,
                timeSpentMinutes: timeSpentMinutes,
                bookmarked: bookmarked,
                solvedAt: solvedAt,
                nextReviewAt: nextReviewAt,
                reviewInterval: reviewInterval,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String canon,
                Value<String> status = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> timeSpentMinutes = const Value.absent(),
                Value<bool> bookmarked = const Value.absent(),
                Value<DateTime?> solvedAt = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<int> reviewInterval = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeafProgressCompanion.insert(
                canon: canon,
                status: status,
                note: note,
                timeSpentMinutes: timeSpentMinutes,
                bookmarked: bookmarked,
                solvedAt: solvedAt,
                nextReviewAt: nextReviewAt,
                reviewInterval: reviewInterval,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeafProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeafProgressTable,
      LeafProgressData,
      $$LeafProgressTableFilterComposer,
      $$LeafProgressTableOrderingComposer,
      $$LeafProgressTableAnnotationComposer,
      $$LeafProgressTableCreateCompanionBuilder,
      $$LeafProgressTableUpdateCompanionBuilder,
      (
        LeafProgressData,
        BaseReferences<_$AppDatabase, $LeafProgressTable, LeafProgressData>,
      ),
      LeafProgressData,
      PrefetchHooks Function()
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      required int durationMinutes,
      Value<String> category,
      Value<int> problemsSolved,
      Value<String> note,
      Value<String> source,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<int> durationMinutes,
      Value<String> category,
      Value<int> problemsSolved,
      Value<String> note,
      Value<String> source,
    });

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get problemsSolved => $composableBuilder(
    column: $table.problemsSolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get problemsSolved => $composableBuilder(
    column: $table.problemsSolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get problemsSolved => $composableBuilder(
    column: $table.problemsSolved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (
            StudySession,
            BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
          ),
          StudySession,
          PrefetchHooks Function()
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> problemsSolved = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => StudySessionsCompanion(
                id: id,
                startedAt: startedAt,
                durationMinutes: durationMinutes,
                category: category,
                problemsSolved: problemsSolved,
                note: note,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                required int durationMinutes,
                Value<String> category = const Value.absent(),
                Value<int> problemsSolved = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                durationMinutes: durationMinutes,
                category: category,
                problemsSolved: problemsSolved,
                note: note,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (
        StudySession,
        BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
      ),
      StudySession,
      PrefetchHooks Function()
    >;
typedef $$ActivityDaysTableCreateCompanionBuilder =
    ActivityDaysCompanion Function({
      Value<int> day,
      Value<int> minutes,
      Value<int> problemsSolved,
      Value<int> xpEarned,
      Value<bool> goalMet,
    });
typedef $$ActivityDaysTableUpdateCompanionBuilder =
    ActivityDaysCompanion Function({
      Value<int> day,
      Value<int> minutes,
      Value<int> problemsSolved,
      Value<int> xpEarned,
      Value<bool> goalMet,
    });

class $$ActivityDaysTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityDaysTable> {
  $$ActivityDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get problemsSolved => $composableBuilder(
    column: $table.problemsSolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalMet => $composableBuilder(
    column: $table.goalMet,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityDaysTable> {
  $$ActivityDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get problemsSolved => $composableBuilder(
    column: $table.problemsSolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalMet => $composableBuilder(
    column: $table.goalMet,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityDaysTable> {
  $$ActivityDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get problemsSolved => $composableBuilder(
    column: $table.problemsSolved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<bool> get goalMet =>
      $composableBuilder(column: $table.goalMet, builder: (column) => column);
}

class $$ActivityDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityDaysTable,
          ActivityDay,
          $$ActivityDaysTableFilterComposer,
          $$ActivityDaysTableOrderingComposer,
          $$ActivityDaysTableAnnotationComposer,
          $$ActivityDaysTableCreateCompanionBuilder,
          $$ActivityDaysTableUpdateCompanionBuilder,
          (
            ActivityDay,
            BaseReferences<_$AppDatabase, $ActivityDaysTable, ActivityDay>,
          ),
          ActivityDay,
          PrefetchHooks Function()
        > {
  $$ActivityDaysTableTableManager(_$AppDatabase db, $ActivityDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> problemsSolved = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<bool> goalMet = const Value.absent(),
              }) => ActivityDaysCompanion(
                day: day,
                minutes: minutes,
                problemsSolved: problemsSolved,
                xpEarned: xpEarned,
                goalMet: goalMet,
              ),
          createCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> problemsSolved = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<bool> goalMet = const Value.absent(),
              }) => ActivityDaysCompanion.insert(
                day: day,
                minutes: minutes,
                problemsSolved: problemsSolved,
                xpEarned: xpEarned,
                goalMet: goalMet,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityDaysTable,
      ActivityDay,
      $$ActivityDaysTableFilterComposer,
      $$ActivityDaysTableOrderingComposer,
      $$ActivityDaysTableAnnotationComposer,
      $$ActivityDaysTableCreateCompanionBuilder,
      $$ActivityDaysTableUpdateCompanionBuilder,
      (
        ActivityDay,
        BaseReferences<_$AppDatabase, $ActivityDaysTable, ActivityDay>,
      ),
      ActivityDay,
      PrefetchHooks Function()
    >;
typedef $$ResourcesTableCreateCompanionBuilder =
    ResourcesCompanion Function({
      Value<int> id,
      required String slug,
      required String title,
      Value<String> provider,
      Value<String> description,
      Value<String> url,
      Value<String> affiliateUrl,
      Value<String> type,
      Value<String> category,
      Value<String> tier,
      Value<int> orderIndex,
    });
typedef $$ResourcesTableUpdateCompanionBuilder =
    ResourcesCompanion Function({
      Value<int> id,
      Value<String> slug,
      Value<String> title,
      Value<String> provider,
      Value<String> description,
      Value<String> url,
      Value<String> affiliateUrl,
      Value<String> type,
      Value<String> category,
      Value<String> tier,
      Value<int> orderIndex,
    });

class $$ResourcesTableFilterComposer
    extends Composer<_$AppDatabase, $ResourcesTable> {
  $$ResourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get affiliateUrl => $composableBuilder(
    column: $table.affiliateUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourcesTable> {
  $$ResourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get affiliateUrl => $composableBuilder(
    column: $table.affiliateUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourcesTable> {
  $$ResourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get affiliateUrl => $composableBuilder(
    column: $table.affiliateUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$ResourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourcesTable,
          Resource,
          $$ResourcesTableFilterComposer,
          $$ResourcesTableOrderingComposer,
          $$ResourcesTableAnnotationComposer,
          $$ResourcesTableCreateCompanionBuilder,
          $$ResourcesTableUpdateCompanionBuilder,
          (Resource, BaseReferences<_$AppDatabase, $ResourcesTable, Resource>),
          Resource,
          PrefetchHooks Function()
        > {
  $$ResourcesTableTableManager(_$AppDatabase db, $ResourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> affiliateUrl = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => ResourcesCompanion(
                id: id,
                slug: slug,
                title: title,
                provider: provider,
                description: description,
                url: url,
                affiliateUrl: affiliateUrl,
                type: type,
                category: category,
                tier: tier,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String title,
                Value<String> provider = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> affiliateUrl = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => ResourcesCompanion.insert(
                id: id,
                slug: slug,
                title: title,
                provider: provider,
                description: description,
                url: url,
                affiliateUrl: affiliateUrl,
                type: type,
                category: category,
                tier: tier,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourcesTable,
      Resource,
      $$ResourcesTableFilterComposer,
      $$ResourcesTableOrderingComposer,
      $$ResourcesTableAnnotationComposer,
      $$ResourcesTableCreateCompanionBuilder,
      $$ResourcesTableUpdateCompanionBuilder,
      (Resource, BaseReferences<_$AppDatabase, $ResourcesTable, Resource>),
      Resource,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String key,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> key,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                key: key,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                key: key,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$TimetableBlocksTableCreateCompanionBuilder =
    TimetableBlocksCompanion Function({
      Value<int> id,
      required String title,
      Value<String> category,
      required int startMinute,
      Value<int> durationMinutes,
      Value<int> daysMask,
      Value<bool> reminder,
      Value<int> leadMinutes,
      Value<bool> enabled,
    });
typedef $$TimetableBlocksTableUpdateCompanionBuilder =
    TimetableBlocksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> category,
      Value<int> startMinute,
      Value<int> durationMinutes,
      Value<int> daysMask,
      Value<bool> reminder,
      Value<int> leadMinutes,
      Value<bool> enabled,
    });

class $$TimetableBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableBlocksTable> {
  $$TimetableBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysMask => $composableBuilder(
    column: $table.daysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leadMinutes => $composableBuilder(
    column: $table.leadMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimetableBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableBlocksTable> {
  $$TimetableBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysMask => $composableBuilder(
    column: $table.daysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leadMinutes => $composableBuilder(
    column: $table.leadMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimetableBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableBlocksTable> {
  $$TimetableBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysMask =>
      $composableBuilder(column: $table.daysMask, builder: (column) => column);

  GeneratedColumn<bool> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);

  GeneratedColumn<int> get leadMinutes => $composableBuilder(
    column: $table.leadMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$TimetableBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableBlocksTable,
          TimetableBlock,
          $$TimetableBlocksTableFilterComposer,
          $$TimetableBlocksTableOrderingComposer,
          $$TimetableBlocksTableAnnotationComposer,
          $$TimetableBlocksTableCreateCompanionBuilder,
          $$TimetableBlocksTableUpdateCompanionBuilder,
          (
            TimetableBlock,
            BaseReferences<
              _$AppDatabase,
              $TimetableBlocksTable,
              TimetableBlock
            >,
          ),
          TimetableBlock,
          PrefetchHooks Function()
        > {
  $$TimetableBlocksTableTableManager(
    _$AppDatabase db,
    $TimetableBlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> daysMask = const Value.absent(),
                Value<bool> reminder = const Value.absent(),
                Value<int> leadMinutes = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => TimetableBlocksCompanion(
                id: id,
                title: title,
                category: category,
                startMinute: startMinute,
                durationMinutes: durationMinutes,
                daysMask: daysMask,
                reminder: reminder,
                leadMinutes: leadMinutes,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> category = const Value.absent(),
                required int startMinute,
                Value<int> durationMinutes = const Value.absent(),
                Value<int> daysMask = const Value.absent(),
                Value<bool> reminder = const Value.absent(),
                Value<int> leadMinutes = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => TimetableBlocksCompanion.insert(
                id: id,
                title: title,
                category: category,
                startMinute: startMinute,
                durationMinutes: durationMinutes,
                daysMask: daysMask,
                reminder: reminder,
                leadMinutes: leadMinutes,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimetableBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableBlocksTable,
      TimetableBlock,
      $$TimetableBlocksTableFilterComposer,
      $$TimetableBlocksTableOrderingComposer,
      $$TimetableBlocksTableAnnotationComposer,
      $$TimetableBlocksTableCreateCompanionBuilder,
      $$TimetableBlocksTableUpdateCompanionBuilder,
      (
        TimetableBlock,
        BaseReferences<_$AppDatabase, $TimetableBlocksTable, TimetableBlock>,
      ),
      TimetableBlock,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SheetsTableTableManager get sheets =>
      $$SheetsTableTableManager(_db, _db.sheets);
  $$NodesTableTableManager get nodes =>
      $$NodesTableTableManager(_db, _db.nodes);
  $$UserSheetsTableTableManager get userSheets =>
      $$UserSheetsTableTableManager(_db, _db.userSheets);
  $$LeafProgressTableTableManager get leafProgress =>
      $$LeafProgressTableTableManager(_db, _db.leafProgress);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$ActivityDaysTableTableManager get activityDays =>
      $$ActivityDaysTableTableManager(_db, _db.activityDays);
  $$ResourcesTableTableManager get resources =>
      $$ResourcesTableTableManager(_db, _db.resources);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$TimetableBlocksTableTableManager get timetableBlocks =>
      $$TimetableBlocksTableTableManager(_db, _db.timetableBlocks);
}
