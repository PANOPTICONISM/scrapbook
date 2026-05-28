// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PagesTableTable extends PagesTable
    with TableInfo<$PagesTableTable, PagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDatabaseMeta = const VerificationMeta(
    'isDatabase',
  );
  @override
  late final GeneratedColumn<bool> isDatabase = GeneratedColumn<bool>(
    'is_database',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_database" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isNewMeta = const VerificationMeta('isNew');
  @override
  late final GeneratedColumn<bool> isNew = GeneratedColumn<bool>(
    'is_new',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_new" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    title,
    icon,
    cover,
    isDatabase,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
    isNew,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pages_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('is_database')) {
      context.handle(
        _isDatabaseMeta,
        isDatabase.isAcceptableOrUnknown(data['is_database']!, _isDatabaseMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_new')) {
      context.handle(
        _isNewMeta,
        isNew.isAcceptableOrUnknown(data['is_new']!, _isNewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PagesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PagesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      ),
      isDatabase: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_database'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isNew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_new'],
      )!,
    );
  }

  @override
  $PagesTableTable createAlias(String alias) {
    return $PagesTableTable(attachedDatabase, alias);
  }
}

class PagesTableData extends DataClass implements Insertable<PagesTableData> {
  final String id;
  final String? parentId;
  final String title;
  final String? icon;
  final String? cover;
  final bool isDatabase;
  final double position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final bool isNew;
  const PagesTableData({
    required this.id,
    this.parentId,
    required this.title,
    this.icon,
    this.cover,
    required this.isDatabase,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
    required this.isNew,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    map['is_database'] = Variable<bool>(isDatabase);
    map['position'] = Variable<double>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_new'] = Variable<bool>(isNew);
    return map;
  }

  PagesTableCompanion toCompanion(bool nullToAbsent) {
    return PagesTableCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      title: Value(title),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      isDatabase: Value(isDatabase),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      isNew: Value(isNew),
    );
  }

  factory PagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PagesTableData(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      title: serializer.fromJson<String>(json['title']),
      icon: serializer.fromJson<String?>(json['icon']),
      cover: serializer.fromJson<String?>(json['cover']),
      isDatabase: serializer.fromJson<bool>(json['isDatabase']),
      position: serializer.fromJson<double>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isNew: serializer.fromJson<bool>(json['isNew']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'title': serializer.toJson<String>(title),
      'icon': serializer.toJson<String?>(icon),
      'cover': serializer.toJson<String?>(cover),
      'isDatabase': serializer.toJson<bool>(isDatabase),
      'position': serializer.toJson<double>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isNew': serializer.toJson<bool>(isNew),
    };
  }

  PagesTableData copyWith({
    String? id,
    Value<String?> parentId = const Value.absent(),
    String? title,
    Value<String?> icon = const Value.absent(),
    Value<String?> cover = const Value.absent(),
    bool? isDatabase,
    double? position,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
    bool? isNew,
  }) => PagesTableData(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    title: title ?? this.title,
    icon: icon.present ? icon.value : this.icon,
    cover: cover.present ? cover.value : this.cover,
    isDatabase: isDatabase ?? this.isDatabase,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
    isNew: isNew ?? this.isNew,
  );
  PagesTableData copyWithCompanion(PagesTableCompanion data) {
    return PagesTableData(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      icon: data.icon.present ? data.icon.value : this.icon,
      cover: data.cover.present ? data.cover.value : this.cover,
      isDatabase: data.isDatabase.present
          ? data.isDatabase.value
          : this.isDatabase,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isNew: data.isNew.present ? data.isNew.value : this.isNew,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PagesTableData(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('icon: $icon, ')
          ..write('cover: $cover, ')
          ..write('isDatabase: $isDatabase, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isNew: $isNew')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    title,
    icon,
    cover,
    isDatabase,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
    isNew,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PagesTableData &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.icon == this.icon &&
          other.cover == this.cover &&
          other.isDatabase == this.isDatabase &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.isNew == this.isNew);
}

class PagesTableCompanion extends UpdateCompanion<PagesTableData> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> title;
  final Value<String?> icon;
  final Value<String?> cover;
  final Value<bool> isDatabase;
  final Value<double> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<bool> isNew;
  final Value<int> rowid;
  const PagesTableCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.icon = const Value.absent(),
    this.cover = const Value.absent(),
    this.isDatabase = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isNew = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagesTableCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.icon = const Value.absent(),
    this.cover = const Value.absent(),
    this.isDatabase = const Value.absent(),
    this.position = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isNew = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PagesTableData> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? title,
    Expression<String>? icon,
    Expression<String>? cover,
    Expression<bool>? isDatabase,
    Expression<double>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<bool>? isNew,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (icon != null) 'icon': icon,
      if (cover != null) 'cover': cover,
      if (isDatabase != null) 'is_database': isDatabase,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isNew != null) 'is_new': isNew,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagesTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? parentId,
    Value<String>? title,
    Value<String?>? icon,
    Value<String?>? cover,
    Value<bool>? isDatabase,
    Value<double>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<bool>? isNew,
    Value<int>? rowid,
  }) {
    return PagesTableCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      cover: cover ?? this.cover,
      isDatabase: isDatabase ?? this.isDatabase,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      isNew: isNew ?? this.isNew,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (isDatabase.present) {
      map['is_database'] = Variable<bool>(isDatabase.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isNew.present) {
      map['is_new'] = Variable<bool>(isNew.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesTableCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('icon: $icon, ')
          ..write('cover: $cover, ')
          ..write('isDatabase: $isDatabase, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isNew: $isNew, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlocksTableTable extends BlocksTable
    with TableInfo<$BlocksTableTable, BlocksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlocksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pages_table (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('markdown'),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isNewMeta = const VerificationMeta('isNew');
  @override
  late final GeneratedColumn<bool> isNew = GeneratedColumn<bool>(
    'is_new',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_new" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    type,
    content,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
    isNew,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blocks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlocksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('is_new')) {
      context.handle(
        _isNewMeta,
        isNew.isAcceptableOrUnknown(data['is_new']!, _isNewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlocksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlocksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      isNew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_new'],
      )!,
    );
  }

  @override
  $BlocksTableTable createAlias(String alias) {
    return $BlocksTableTable(attachedDatabase, alias);
  }
}

class BlocksTableData extends DataClass implements Insertable<BlocksTableData> {
  final String id;
  final String pageId;
  final String type;
  final String content;
  final double position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final bool isNew;
  const BlocksTableData({
    required this.id,
    required this.pageId,
    required this.type,
    required this.content,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
    required this.isNew,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['page_id'] = Variable<String>(pageId);
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    map['position'] = Variable<double>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_new'] = Variable<bool>(isNew);
    return map;
  }

  BlocksTableCompanion toCompanion(bool nullToAbsent) {
    return BlocksTableCompanion(
      id: Value(id),
      pageId: Value(pageId),
      type: Value(type),
      content: Value(content),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      isNew: Value(isNew),
    );
  }

  factory BlocksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlocksTableData(
      id: serializer.fromJson<String>(json['id']),
      pageId: serializer.fromJson<String>(json['pageId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      position: serializer.fromJson<double>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isNew: serializer.fromJson<bool>(json['isNew']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pageId': serializer.toJson<String>(pageId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'position': serializer.toJson<double>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isNew': serializer.toJson<bool>(isNew),
    };
  }

  BlocksTableData copyWith({
    String? id,
    String? pageId,
    String? type,
    String? content,
    double? position,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
    bool? isNew,
  }) => BlocksTableData(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    type: type ?? this.type,
    content: content ?? this.content,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
    isNew: isNew ?? this.isNew,
  );
  BlocksTableData copyWithCompanion(BlocksTableCompanion data) {
    return BlocksTableData(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isNew: data.isNew.present ? data.isNew.value : this.isNew,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlocksTableData(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isNew: $isNew')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pageId,
    type,
    content,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
    isNew,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlocksTableData &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.type == this.type &&
          other.content == this.content &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.isNew == this.isNew);
}

class BlocksTableCompanion extends UpdateCompanion<BlocksTableData> {
  final Value<String> id;
  final Value<String> pageId;
  final Value<String> type;
  final Value<String> content;
  final Value<double> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<bool> isNew;
  final Value<int> rowid;
  const BlocksTableCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isNew = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlocksTableCompanion.insert({
    required String id,
    required String pageId,
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.position = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isNew = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pageId = Value(pageId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BlocksTableData> custom({
    Expression<String>? id,
    Expression<String>? pageId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<double>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<bool>? isNew,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isNew != null) 'is_new': isNew,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlocksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? pageId,
    Value<String>? type,
    Value<String>? content,
    Value<double>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<bool>? isNew,
    Value<int>? rowid,
  }) {
    return BlocksTableCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      isNew: isNew ?? this.isNew,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isNew.present) {
      map['is_new'] = Variable<bool>(isNew.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlocksTableCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('isNew: $isNew, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatabasePropertiesTableTable extends DatabasePropertiesTable
    with TableInfo<$DatabasePropertiesTableTable, DatabasePropertiesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabasePropertiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _databaseIdMeta = const VerificationMeta(
    'databaseId',
  );
  @override
  late final GeneratedColumn<String> databaseId = GeneratedColumn<String>(
    'database_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pages_table (id)',
    ),
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    databaseId,
    name,
    type,
    options,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'database_properties_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabasePropertiesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('database_id')) {
      context.handle(
        _databaseIdMeta,
        databaseId.isAcceptableOrUnknown(data['database_id']!, _databaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_databaseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatabasePropertiesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabasePropertiesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      databaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}database_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $DatabasePropertiesTableTable createAlias(String alias) {
    return $DatabasePropertiesTableTable(attachedDatabase, alias);
  }
}

class DatabasePropertiesTableData extends DataClass
    implements Insertable<DatabasePropertiesTableData> {
  final String id;
  final String databaseId;
  final String name;
  final String type;
  final String? options;
  final double position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  const DatabasePropertiesTableData({
    required this.id,
    required this.databaseId,
    required this.name,
    required this.type,
    this.options,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['database_id'] = Variable<String>(databaseId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['position'] = Variable<double>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  DatabasePropertiesTableCompanion toCompanion(bool nullToAbsent) {
    return DatabasePropertiesTableCompanion(
      id: Value(id),
      databaseId: Value(databaseId),
      name: Value(name),
      type: Value(type),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory DatabasePropertiesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabasePropertiesTableData(
      id: serializer.fromJson<String>(json['id']),
      databaseId: serializer.fromJson<String>(json['databaseId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      options: serializer.fromJson<String?>(json['options']),
      position: serializer.fromJson<double>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'databaseId': serializer.toJson<String>(databaseId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'options': serializer.toJson<String?>(options),
      'position': serializer.toJson<double>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  DatabasePropertiesTableData copyWith({
    String? id,
    String? databaseId,
    String? name,
    String? type,
    Value<String?> options = const Value.absent(),
    double? position,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
  }) => DatabasePropertiesTableData(
    id: id ?? this.id,
    databaseId: databaseId ?? this.databaseId,
    name: name ?? this.name,
    type: type ?? this.type,
    options: options.present ? options.value : this.options,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  DatabasePropertiesTableData copyWithCompanion(
    DatabasePropertiesTableCompanion data,
  ) {
    return DatabasePropertiesTableData(
      id: data.id.present ? data.id.value : this.id,
      databaseId: data.databaseId.present
          ? data.databaseId.value
          : this.databaseId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      options: data.options.present ? data.options.value : this.options,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabasePropertiesTableData(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('options: $options, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    databaseId,
    name,
    type,
    options,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabasePropertiesTableData &&
          other.id == this.id &&
          other.databaseId == this.databaseId &&
          other.name == this.name &&
          other.type == this.type &&
          other.options == this.options &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class DatabasePropertiesTableCompanion
    extends UpdateCompanion<DatabasePropertiesTableData> {
  final Value<String> id;
  final Value<String> databaseId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> options;
  final Value<double> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const DatabasePropertiesTableCompanion({
    this.id = const Value.absent(),
    this.databaseId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.options = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatabasePropertiesTableCompanion.insert({
    required String id,
    required String databaseId,
    required String name,
    required String type,
    this.options = const Value.absent(),
    this.position = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       databaseId = Value(databaseId),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DatabasePropertiesTableData> custom({
    Expression<String>? id,
    Expression<String>? databaseId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? options,
    Expression<double>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (databaseId != null) 'database_id': databaseId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (options != null) 'options': options,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DatabasePropertiesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? databaseId,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? options,
    Value<double>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return DatabasePropertiesTableCompanion(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      name: name ?? this.name,
      type: type ?? this.type,
      options: options ?? this.options,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (databaseId.present) {
      map['database_id'] = Variable<String>(databaseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatabasePropertiesTableCompanion(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('options: $options, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatabaseRowsTableTable extends DatabaseRowsTable
    with TableInfo<$DatabaseRowsTableTable, DatabaseRowsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabaseRowsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _databaseIdMeta = const VerificationMeta(
    'databaseId',
  );
  @override
  late final GeneratedColumn<String> databaseId = GeneratedColumn<String>(
    'database_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pages_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pages_table (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    databaseId,
    pageId,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'database_rows_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabaseRowsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('database_id')) {
      context.handle(
        _databaseIdMeta,
        databaseId.isAcceptableOrUnknown(data['database_id']!, _databaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_databaseIdMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatabaseRowsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseRowsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      databaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}database_id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $DatabaseRowsTableTable createAlias(String alias) {
    return $DatabaseRowsTableTable(attachedDatabase, alias);
  }
}

class DatabaseRowsTableData extends DataClass
    implements Insertable<DatabaseRowsTableData> {
  final String id;
  final String databaseId;
  final String pageId;
  final double position;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  const DatabaseRowsTableData({
    required this.id,
    required this.databaseId,
    required this.pageId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['database_id'] = Variable<String>(databaseId);
    map['page_id'] = Variable<String>(pageId);
    map['position'] = Variable<double>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  DatabaseRowsTableCompanion toCompanion(bool nullToAbsent) {
    return DatabaseRowsTableCompanion(
      id: Value(id),
      databaseId: Value(databaseId),
      pageId: Value(pageId),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory DatabaseRowsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseRowsTableData(
      id: serializer.fromJson<String>(json['id']),
      databaseId: serializer.fromJson<String>(json['databaseId']),
      pageId: serializer.fromJson<String>(json['pageId']),
      position: serializer.fromJson<double>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'databaseId': serializer.toJson<String>(databaseId),
      'pageId': serializer.toJson<String>(pageId),
      'position': serializer.toJson<double>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  DatabaseRowsTableData copyWith({
    String? id,
    String? databaseId,
    String? pageId,
    double? position,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
  }) => DatabaseRowsTableData(
    id: id ?? this.id,
    databaseId: databaseId ?? this.databaseId,
    pageId: pageId ?? this.pageId,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  DatabaseRowsTableData copyWithCompanion(DatabaseRowsTableCompanion data) {
    return DatabaseRowsTableData(
      id: data.id.present ? data.id.value : this.id,
      databaseId: data.databaseId.present
          ? data.databaseId.value
          : this.databaseId,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseRowsTableData(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('pageId: $pageId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    databaseId,
    pageId,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseRowsTableData &&
          other.id == this.id &&
          other.databaseId == this.databaseId &&
          other.pageId == this.pageId &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class DatabaseRowsTableCompanion
    extends UpdateCompanion<DatabaseRowsTableData> {
  final Value<String> id;
  final Value<String> databaseId;
  final Value<String> pageId;
  final Value<double> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const DatabaseRowsTableCompanion({
    this.id = const Value.absent(),
    this.databaseId = const Value.absent(),
    this.pageId = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatabaseRowsTableCompanion.insert({
    required String id,
    required String databaseId,
    required String pageId,
    this.position = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       databaseId = Value(databaseId),
       pageId = Value(pageId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DatabaseRowsTableData> custom({
    Expression<String>? id,
    Expression<String>? databaseId,
    Expression<String>? pageId,
    Expression<double>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (databaseId != null) 'database_id': databaseId,
      if (pageId != null) 'page_id': pageId,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DatabaseRowsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? databaseId,
    Value<String>? pageId,
    Value<double>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return DatabaseRowsTableCompanion(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      pageId: pageId ?? this.pageId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (databaseId.present) {
      map['database_id'] = Variable<String>(databaseId.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseRowsTableCompanion(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('pageId: $pageId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatabasePropertyValuesTableTable extends DatabasePropertyValuesTable
    with
        TableInfo<
          $DatabasePropertyValuesTableTable,
          DatabasePropertyValuesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabasePropertyValuesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES database_rows_table (id)',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES database_properties_table (id)',
    ),
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta(
    'valueText',
  );
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueNumberMeta = const VerificationMeta(
    'valueNumber',
  );
  @override
  late final GeneratedColumn<double> valueNumber = GeneratedColumn<double>(
    'value_number',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueDateMeta = const VerificationMeta(
    'valueDate',
  );
  @override
  late final GeneratedColumn<int> valueDate = GeneratedColumn<int>(
    'value_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueBoolMeta = const VerificationMeta(
    'valueBool',
  );
  @override
  late final GeneratedColumn<bool> valueBool = GeneratedColumn<bool>(
    'value_bool',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("value_bool" IN (0, 1))',
    ),
  );
  static const VerificationMeta _valueSelectMeta = const VerificationMeta(
    'valueSelect',
  );
  @override
  late final GeneratedColumn<String> valueSelect = GeneratedColumn<String>(
    'value_select',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rowId,
    propertyId,
    valueText,
    valueNumber,
    valueDate,
    valueBool,
    valueSelect,
    createdAt,
    updatedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'database_property_values_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabasePropertyValuesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('value_text')) {
      context.handle(
        _valueTextMeta,
        valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta),
      );
    }
    if (data.containsKey('value_number')) {
      context.handle(
        _valueNumberMeta,
        valueNumber.isAcceptableOrUnknown(
          data['value_number']!,
          _valueNumberMeta,
        ),
      );
    }
    if (data.containsKey('value_date')) {
      context.handle(
        _valueDateMeta,
        valueDate.isAcceptableOrUnknown(data['value_date']!, _valueDateMeta),
      );
    }
    if (data.containsKey('value_bool')) {
      context.handle(
        _valueBoolMeta,
        valueBool.isAcceptableOrUnknown(data['value_bool']!, _valueBoolMeta),
      );
    }
    if (data.containsKey('value_select')) {
      context.handle(
        _valueSelectMeta,
        valueSelect.isAcceptableOrUnknown(
          data['value_select']!,
          _valueSelectMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatabasePropertyValuesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabasePropertyValuesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      )!,
      valueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_text'],
      ),
      valueNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_number'],
      ),
      valueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_date'],
      ),
      valueBool: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}value_bool'],
      ),
      valueSelect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_select'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $DatabasePropertyValuesTableTable createAlias(String alias) {
    return $DatabasePropertyValuesTableTable(attachedDatabase, alias);
  }
}

class DatabasePropertyValuesTableData extends DataClass
    implements Insertable<DatabasePropertyValuesTableData> {
  final String id;
  final String rowId;
  final String propertyId;
  final String? valueText;
  final double? valueNumber;
  final int? valueDate;
  final bool? valueBool;
  final String? valueSelect;
  final int createdAt;
  final int updatedAt;
  final bool isDirty;
  const DatabasePropertyValuesTableData({
    required this.id,
    required this.rowId,
    required this.propertyId,
    this.valueText,
    this.valueNumber,
    this.valueDate,
    this.valueBool,
    this.valueSelect,
    required this.createdAt,
    required this.updatedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['row_id'] = Variable<String>(rowId);
    map['property_id'] = Variable<String>(propertyId);
    if (!nullToAbsent || valueText != null) {
      map['value_text'] = Variable<String>(valueText);
    }
    if (!nullToAbsent || valueNumber != null) {
      map['value_number'] = Variable<double>(valueNumber);
    }
    if (!nullToAbsent || valueDate != null) {
      map['value_date'] = Variable<int>(valueDate);
    }
    if (!nullToAbsent || valueBool != null) {
      map['value_bool'] = Variable<bool>(valueBool);
    }
    if (!nullToAbsent || valueSelect != null) {
      map['value_select'] = Variable<String>(valueSelect);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  DatabasePropertyValuesTableCompanion toCompanion(bool nullToAbsent) {
    return DatabasePropertyValuesTableCompanion(
      id: Value(id),
      rowId: Value(rowId),
      propertyId: Value(propertyId),
      valueText: valueText == null && nullToAbsent
          ? const Value.absent()
          : Value(valueText),
      valueNumber: valueNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(valueNumber),
      valueDate: valueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(valueDate),
      valueBool: valueBool == null && nullToAbsent
          ? const Value.absent()
          : Value(valueBool),
      valueSelect: valueSelect == null && nullToAbsent
          ? const Value.absent()
          : Value(valueSelect),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDirty: Value(isDirty),
    );
  }

  factory DatabasePropertyValuesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabasePropertyValuesTableData(
      id: serializer.fromJson<String>(json['id']),
      rowId: serializer.fromJson<String>(json['rowId']),
      propertyId: serializer.fromJson<String>(json['propertyId']),
      valueText: serializer.fromJson<String?>(json['valueText']),
      valueNumber: serializer.fromJson<double?>(json['valueNumber']),
      valueDate: serializer.fromJson<int?>(json['valueDate']),
      valueBool: serializer.fromJson<bool?>(json['valueBool']),
      valueSelect: serializer.fromJson<String?>(json['valueSelect']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rowId': serializer.toJson<String>(rowId),
      'propertyId': serializer.toJson<String>(propertyId),
      'valueText': serializer.toJson<String?>(valueText),
      'valueNumber': serializer.toJson<double?>(valueNumber),
      'valueDate': serializer.toJson<int?>(valueDate),
      'valueBool': serializer.toJson<bool?>(valueBool),
      'valueSelect': serializer.toJson<String?>(valueSelect),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  DatabasePropertyValuesTableData copyWith({
    String? id,
    String? rowId,
    String? propertyId,
    Value<String?> valueText = const Value.absent(),
    Value<double?> valueNumber = const Value.absent(),
    Value<int?> valueDate = const Value.absent(),
    Value<bool?> valueBool = const Value.absent(),
    Value<String?> valueSelect = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    bool? isDirty,
  }) => DatabasePropertyValuesTableData(
    id: id ?? this.id,
    rowId: rowId ?? this.rowId,
    propertyId: propertyId ?? this.propertyId,
    valueText: valueText.present ? valueText.value : this.valueText,
    valueNumber: valueNumber.present ? valueNumber.value : this.valueNumber,
    valueDate: valueDate.present ? valueDate.value : this.valueDate,
    valueBool: valueBool.present ? valueBool.value : this.valueBool,
    valueSelect: valueSelect.present ? valueSelect.value : this.valueSelect,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  DatabasePropertyValuesTableData copyWithCompanion(
    DatabasePropertyValuesTableCompanion data,
  ) {
    return DatabasePropertyValuesTableData(
      id: data.id.present ? data.id.value : this.id,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
      valueNumber: data.valueNumber.present
          ? data.valueNumber.value
          : this.valueNumber,
      valueDate: data.valueDate.present ? data.valueDate.value : this.valueDate,
      valueBool: data.valueBool.present ? data.valueBool.value : this.valueBool,
      valueSelect: data.valueSelect.present
          ? data.valueSelect.value
          : this.valueSelect,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabasePropertyValuesTableData(')
          ..write('id: $id, ')
          ..write('rowId: $rowId, ')
          ..write('propertyId: $propertyId, ')
          ..write('valueText: $valueText, ')
          ..write('valueNumber: $valueNumber, ')
          ..write('valueDate: $valueDate, ')
          ..write('valueBool: $valueBool, ')
          ..write('valueSelect: $valueSelect, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rowId,
    propertyId,
    valueText,
    valueNumber,
    valueDate,
    valueBool,
    valueSelect,
    createdAt,
    updatedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabasePropertyValuesTableData &&
          other.id == this.id &&
          other.rowId == this.rowId &&
          other.propertyId == this.propertyId &&
          other.valueText == this.valueText &&
          other.valueNumber == this.valueNumber &&
          other.valueDate == this.valueDate &&
          other.valueBool == this.valueBool &&
          other.valueSelect == this.valueSelect &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDirty == this.isDirty);
}

class DatabasePropertyValuesTableCompanion
    extends UpdateCompanion<DatabasePropertyValuesTableData> {
  final Value<String> id;
  final Value<String> rowId;
  final Value<String> propertyId;
  final Value<String?> valueText;
  final Value<double?> valueNumber;
  final Value<int?> valueDate;
  final Value<bool?> valueBool;
  final Value<String?> valueSelect;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const DatabasePropertyValuesTableCompanion({
    this.id = const Value.absent(),
    this.rowId = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.valueText = const Value.absent(),
    this.valueNumber = const Value.absent(),
    this.valueDate = const Value.absent(),
    this.valueBool = const Value.absent(),
    this.valueSelect = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatabasePropertyValuesTableCompanion.insert({
    required String id,
    required String rowId,
    required String propertyId,
    this.valueText = const Value.absent(),
    this.valueNumber = const Value.absent(),
    this.valueDate = const Value.absent(),
    this.valueBool = const Value.absent(),
    this.valueSelect = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rowId = Value(rowId),
       propertyId = Value(propertyId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DatabasePropertyValuesTableData> custom({
    Expression<String>? id,
    Expression<String>? rowId,
    Expression<String>? propertyId,
    Expression<String>? valueText,
    Expression<double>? valueNumber,
    Expression<int>? valueDate,
    Expression<bool>? valueBool,
    Expression<String>? valueSelect,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowId != null) 'row_id': rowId,
      if (propertyId != null) 'property_id': propertyId,
      if (valueText != null) 'value_text': valueText,
      if (valueNumber != null) 'value_number': valueNumber,
      if (valueDate != null) 'value_date': valueDate,
      if (valueBool != null) 'value_bool': valueBool,
      if (valueSelect != null) 'value_select': valueSelect,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DatabasePropertyValuesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? rowId,
    Value<String>? propertyId,
    Value<String?>? valueText,
    Value<double?>? valueNumber,
    Value<int?>? valueDate,
    Value<bool?>? valueBool,
    Value<String?>? valueSelect,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return DatabasePropertyValuesTableCompanion(
      id: id ?? this.id,
      rowId: rowId ?? this.rowId,
      propertyId: propertyId ?? this.propertyId,
      valueText: valueText ?? this.valueText,
      valueNumber: valueNumber ?? this.valueNumber,
      valueDate: valueDate ?? this.valueDate,
      valueBool: valueBool ?? this.valueBool,
      valueSelect: valueSelect ?? this.valueSelect,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (valueNumber.present) {
      map['value_number'] = Variable<double>(valueNumber.value);
    }
    if (valueDate.present) {
      map['value_date'] = Variable<int>(valueDate.value);
    }
    if (valueBool.present) {
      map['value_bool'] = Variable<bool>(valueBool.value);
    }
    if (valueSelect.present) {
      map['value_select'] = Variable<String>(valueSelect.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatabasePropertyValuesTableCompanion(')
          ..write('id: $id, ')
          ..write('rowId: $rowId, ')
          ..write('propertyId: $propertyId, ')
          ..write('valueText: $valueText, ')
          ..write('valueNumber: $valueNumber, ')
          ..write('valueDate: $valueDate, ')
          ..write('valueBool: $valueBool, ')
          ..write('valueSelect: $valueSelect, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PagesTableTable pagesTable = $PagesTableTable(this);
  late final $BlocksTableTable blocksTable = $BlocksTableTable(this);
  late final $DatabasePropertiesTableTable databasePropertiesTable =
      $DatabasePropertiesTableTable(this);
  late final $DatabaseRowsTableTable databaseRowsTable =
      $DatabaseRowsTableTable(this);
  late final $DatabasePropertyValuesTableTable databasePropertyValuesTable =
      $DatabasePropertyValuesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pagesTable,
    blocksTable,
    databasePropertiesTable,
    databaseRowsTable,
    databasePropertyValuesTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pages_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('database_rows_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PagesTableTableCreateCompanionBuilder =
    PagesTableCompanion Function({
      required String id,
      Value<String?> parentId,
      Value<String> title,
      Value<String?> icon,
      Value<String?> cover,
      Value<bool> isDatabase,
      Value<double> position,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<bool> isNew,
      Value<int> rowid,
    });
typedef $$PagesTableTableUpdateCompanionBuilder =
    PagesTableCompanion Function({
      Value<String> id,
      Value<String?> parentId,
      Value<String> title,
      Value<String?> icon,
      Value<String?> cover,
      Value<bool> isDatabase,
      Value<double> position,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<bool> isNew,
      Value<int> rowid,
    });

final class $$PagesTableTableReferences
    extends BaseReferences<_$AppDatabase, $PagesTableTable, PagesTableData> {
  $$PagesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BlocksTableTable, List<BlocksTableData>>
  _blocksTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.blocksTable,
    aliasName: $_aliasNameGenerator(db.pagesTable.id, db.blocksTable.pageId),
  );

  $$BlocksTableTableProcessedTableManager get blocksTableRefs {
    final manager = $$BlocksTableTableTableManager(
      $_db,
      $_db.blocksTable,
    ).filter((f) => f.pageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_blocksTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DatabasePropertiesTableTable,
    List<DatabasePropertiesTableData>
  >
  _databasePropertiesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.databasePropertiesTable,
        aliasName: $_aliasNameGenerator(
          db.pagesTable.id,
          db.databasePropertiesTable.databaseId,
        ),
      );

  $$DatabasePropertiesTableTableProcessedTableManager
  get databasePropertiesTableRefs {
    final manager = $$DatabasePropertiesTableTableTableManager(
      $_db,
      $_db.databasePropertiesTable,
    ).filter((f) => f.databaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _databasePropertiesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DatabaseRowsTableTable,
    List<DatabaseRowsTableData>
  >
  _databaseRowsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.databaseRowsTable,
        aliasName: $_aliasNameGenerator(
          db.pagesTable.id,
          db.databaseRowsTable.databaseId,
        ),
      );

  $$DatabaseRowsTableTableProcessedTableManager get databaseRowsTableRefs {
    final manager = $$DatabaseRowsTableTableTableManager(
      $_db,
      $_db.databaseRowsTable,
    ).filter((f) => f.databaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _databaseRowsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DatabaseRowsTableTable,
    List<DatabaseRowsTableData>
  >
  _rowPageTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.databaseRowsTable,
    aliasName: $_aliasNameGenerator(
      db.pagesTable.id,
      db.databaseRowsTable.pageId,
    ),
  );

  $$DatabaseRowsTableTableProcessedTableManager get rowPage {
    final manager = $$DatabaseRowsTableTableTableManager(
      $_db,
      $_db.databaseRowsTable,
    ).filter((f) => f.pageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rowPageTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PagesTableTable> {
  $$PagesTableTableFilterComposer({
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

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDatabase => $composableBuilder(
    column: $table.isDatabase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> blocksTableRefs(
    Expression<bool> Function($$BlocksTableTableFilterComposer f) f,
  ) {
    final $$BlocksTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blocksTable,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlocksTableTableFilterComposer(
            $db: $db,
            $table: $db.blocksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> databasePropertiesTableRefs(
    Expression<bool> Function($$DatabasePropertiesTableTableFilterComposer f) f,
  ) {
    final $$DatabasePropertiesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databasePropertiesTable,
          getReferencedColumn: (t) => t.databaseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertiesTableTableFilterComposer(
                $db: $db,
                $table: $db.databasePropertiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> databaseRowsTableRefs(
    Expression<bool> Function($$DatabaseRowsTableTableFilterComposer f) f,
  ) {
    final $$DatabaseRowsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.databaseRowsTable,
      getReferencedColumn: (t) => t.databaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DatabaseRowsTableTableFilterComposer(
            $db: $db,
            $table: $db.databaseRowsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rowPage(
    Expression<bool> Function($$DatabaseRowsTableTableFilterComposer f) f,
  ) {
    final $$DatabaseRowsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.databaseRowsTable,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DatabaseRowsTableTableFilterComposer(
            $db: $db,
            $table: $db.databaseRowsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PagesTableTable> {
  $$PagesTableTableOrderingComposer({
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

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDatabase => $composableBuilder(
    column: $table.isDatabase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagesTableTable> {
  $$PagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<bool> get isDatabase => $composableBuilder(
    column: $table.isDatabase,
    builder: (column) => column,
  );

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isNew =>
      $composableBuilder(column: $table.isNew, builder: (column) => column);

  Expression<T> blocksTableRefs<T extends Object>(
    Expression<T> Function($$BlocksTableTableAnnotationComposer a) f,
  ) {
    final $$BlocksTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blocksTable,
      getReferencedColumn: (t) => t.pageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlocksTableTableAnnotationComposer(
            $db: $db,
            $table: $db.blocksTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> databasePropertiesTableRefs<T extends Object>(
    Expression<T> Function($$DatabasePropertiesTableTableAnnotationComposer a)
    f,
  ) {
    final $$DatabasePropertiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databasePropertiesTable,
          getReferencedColumn: (t) => t.databaseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertiesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.databasePropertiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> databaseRowsTableRefs<T extends Object>(
    Expression<T> Function($$DatabaseRowsTableTableAnnotationComposer a) f,
  ) {
    final $$DatabaseRowsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databaseRowsTable,
          getReferencedColumn: (t) => t.databaseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabaseRowsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.databaseRowsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> rowPage<T extends Object>(
    Expression<T> Function($$DatabaseRowsTableTableAnnotationComposer a) f,
  ) {
    final $$DatabaseRowsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databaseRowsTable,
          getReferencedColumn: (t) => t.pageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabaseRowsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.databaseRowsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagesTableTable,
          PagesTableData,
          $$PagesTableTableFilterComposer,
          $$PagesTableTableOrderingComposer,
          $$PagesTableTableAnnotationComposer,
          $$PagesTableTableCreateCompanionBuilder,
          $$PagesTableTableUpdateCompanionBuilder,
          (PagesTableData, $$PagesTableTableReferences),
          PagesTableData,
          PrefetchHooks Function({
            bool blocksTableRefs,
            bool databasePropertiesTableRefs,
            bool databaseRowsTableRefs,
            bool rowPage,
          })
        > {
  $$PagesTableTableTableManager(_$AppDatabase db, $PagesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<bool> isDatabase = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isNew = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagesTableCompanion(
                id: id,
                parentId: parentId,
                title: title,
                icon: icon,
                cover: cover,
                isDatabase: isDatabase,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                isNew: isNew,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> parentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<bool> isDatabase = const Value.absent(),
                Value<double> position = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isNew = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagesTableCompanion.insert(
                id: id,
                parentId: parentId,
                title: title,
                icon: icon,
                cover: cover,
                isDatabase: isDatabase,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                isNew: isNew,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PagesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                blocksTableRefs = false,
                databasePropertiesTableRefs = false,
                databaseRowsTableRefs = false,
                rowPage = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (blocksTableRefs) db.blocksTable,
                    if (databasePropertiesTableRefs) db.databasePropertiesTable,
                    if (databaseRowsTableRefs) db.databaseRowsTable,
                    if (rowPage) db.databaseRowsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (blocksTableRefs)
                        await $_getPrefetchedData<
                          PagesTableData,
                          $PagesTableTable,
                          BlocksTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PagesTableTableReferences
                              ._blocksTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).blocksTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (databasePropertiesTableRefs)
                        await $_getPrefetchedData<
                          PagesTableData,
                          $PagesTableTable,
                          DatabasePropertiesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PagesTableTableReferences
                              ._databasePropertiesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).databasePropertiesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.databaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (databaseRowsTableRefs)
                        await $_getPrefetchedData<
                          PagesTableData,
                          $PagesTableTable,
                          DatabaseRowsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PagesTableTableReferences
                              ._databaseRowsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).databaseRowsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.databaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rowPage)
                        await $_getPrefetchedData<
                          PagesTableData,
                          $PagesTableTable,
                          DatabaseRowsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PagesTableTableReferences
                              ._rowPageTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PagesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).rowPage,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pageId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagesTableTable,
      PagesTableData,
      $$PagesTableTableFilterComposer,
      $$PagesTableTableOrderingComposer,
      $$PagesTableTableAnnotationComposer,
      $$PagesTableTableCreateCompanionBuilder,
      $$PagesTableTableUpdateCompanionBuilder,
      (PagesTableData, $$PagesTableTableReferences),
      PagesTableData,
      PrefetchHooks Function({
        bool blocksTableRefs,
        bool databasePropertiesTableRefs,
        bool databaseRowsTableRefs,
        bool rowPage,
      })
    >;
typedef $$BlocksTableTableCreateCompanionBuilder =
    BlocksTableCompanion Function({
      required String id,
      required String pageId,
      Value<String> type,
      Value<String> content,
      Value<double> position,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<bool> isNew,
      Value<int> rowid,
    });
typedef $$BlocksTableTableUpdateCompanionBuilder =
    BlocksTableCompanion Function({
      Value<String> id,
      Value<String> pageId,
      Value<String> type,
      Value<String> content,
      Value<double> position,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<bool> isNew,
      Value<int> rowid,
    });

final class $$BlocksTableTableReferences
    extends BaseReferences<_$AppDatabase, $BlocksTableTable, BlocksTableData> {
  $$BlocksTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PagesTableTable _pageIdTable(_$AppDatabase db) =>
      db.pagesTable.createAlias(
        $_aliasNameGenerator(db.blocksTable.pageId, db.pagesTable.id),
      );

  $$PagesTableTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<String>('page_id')!;

    final manager = $$PagesTableTableTableManager(
      $_db,
      $_db.pagesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BlocksTableTableFilterComposer
    extends Composer<_$AppDatabase, $BlocksTableTable> {
  $$BlocksTableTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnFilters(column),
  );

  $$PagesTableTableFilterComposer get pageId {
    final $$PagesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableFilterComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlocksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BlocksTableTable> {
  $$BlocksTableTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNew => $composableBuilder(
    column: $table.isNew,
    builder: (column) => ColumnOrderings(column),
  );

  $$PagesTableTableOrderingComposer get pageId {
    final $$PagesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableOrderingComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlocksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlocksTableTable> {
  $$BlocksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isNew =>
      $composableBuilder(column: $table.isNew, builder: (column) => column);

  $$PagesTableTableAnnotationComposer get pageId {
    final $$PagesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlocksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlocksTableTable,
          BlocksTableData,
          $$BlocksTableTableFilterComposer,
          $$BlocksTableTableOrderingComposer,
          $$BlocksTableTableAnnotationComposer,
          $$BlocksTableTableCreateCompanionBuilder,
          $$BlocksTableTableUpdateCompanionBuilder,
          (BlocksTableData, $$BlocksTableTableReferences),
          BlocksTableData,
          PrefetchHooks Function({bool pageId})
        > {
  $$BlocksTableTableTableManager(_$AppDatabase db, $BlocksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlocksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlocksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlocksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pageId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isNew = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlocksTableCompanion(
                id: id,
                pageId: pageId,
                type: type,
                content: content,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                isNew: isNew,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pageId,
                Value<String> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<double> position = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<bool> isNew = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlocksTableCompanion.insert(
                id: id,
                pageId: pageId,
                type: type,
                content: content,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                isNew: isNew,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BlocksTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pageId = false}) {
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
                    if (pageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pageId,
                                referencedTable: $$BlocksTableTableReferences
                                    ._pageIdTable(db),
                                referencedColumn: $$BlocksTableTableReferences
                                    ._pageIdTable(db)
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

typedef $$BlocksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlocksTableTable,
      BlocksTableData,
      $$BlocksTableTableFilterComposer,
      $$BlocksTableTableOrderingComposer,
      $$BlocksTableTableAnnotationComposer,
      $$BlocksTableTableCreateCompanionBuilder,
      $$BlocksTableTableUpdateCompanionBuilder,
      (BlocksTableData, $$BlocksTableTableReferences),
      BlocksTableData,
      PrefetchHooks Function({bool pageId})
    >;
typedef $$DatabasePropertiesTableTableCreateCompanionBuilder =
    DatabasePropertiesTableCompanion Function({
      required String id,
      required String databaseId,
      required String name,
      required String type,
      Value<String?> options,
      Value<double> position,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$DatabasePropertiesTableTableUpdateCompanionBuilder =
    DatabasePropertiesTableCompanion Function({
      Value<String> id,
      Value<String> databaseId,
      Value<String> name,
      Value<String> type,
      Value<String?> options,
      Value<double> position,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$DatabasePropertiesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DatabasePropertiesTableTable,
          DatabasePropertiesTableData
        > {
  $$DatabasePropertiesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PagesTableTable _databaseIdTable(_$AppDatabase db) =>
      db.pagesTable.createAlias(
        $_aliasNameGenerator(
          db.databasePropertiesTable.databaseId,
          db.pagesTable.id,
        ),
      );

  $$PagesTableTableProcessedTableManager get databaseId {
    final $_column = $_itemColumn<String>('database_id')!;

    final manager = $$PagesTableTableTableManager(
      $_db,
      $_db.pagesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_databaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $DatabasePropertyValuesTableTable,
    List<DatabasePropertyValuesTableData>
  >
  _databasePropertyValuesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.databasePropertyValuesTable,
        aliasName: $_aliasNameGenerator(
          db.databasePropertiesTable.id,
          db.databasePropertyValuesTable.propertyId,
        ),
      );

  $$DatabasePropertyValuesTableTableProcessedTableManager
  get databasePropertyValuesTableRefs {
    final manager = $$DatabasePropertyValuesTableTableTableManager(
      $_db,
      $_db.databasePropertyValuesTable,
    ).filter((f) => f.propertyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _databasePropertyValuesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DatabasePropertiesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DatabasePropertiesTableTable> {
  $$DatabasePropertiesTableTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$PagesTableTableFilterComposer get databaseId {
    final $$PagesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableFilterComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> databasePropertyValuesTableRefs(
    Expression<bool> Function(
      $$DatabasePropertyValuesTableTableFilterComposer f,
    )
    f,
  ) {
    final $$DatabasePropertyValuesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databasePropertyValuesTable,
          getReferencedColumn: (t) => t.propertyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertyValuesTableTableFilterComposer(
                $db: $db,
                $table: $db.databasePropertyValuesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DatabasePropertiesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DatabasePropertiesTableTable> {
  $$DatabasePropertiesTableTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$PagesTableTableOrderingComposer get databaseId {
    final $$PagesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableOrderingComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DatabasePropertiesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatabasePropertiesTableTable> {
  $$DatabasePropertiesTableTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$PagesTableTableAnnotationComposer get databaseId {
    final $$PagesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> databasePropertyValuesTableRefs<T extends Object>(
    Expression<T> Function(
      $$DatabasePropertyValuesTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$DatabasePropertyValuesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databasePropertyValuesTable,
          getReferencedColumn: (t) => t.propertyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertyValuesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.databasePropertyValuesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DatabasePropertiesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatabasePropertiesTableTable,
          DatabasePropertiesTableData,
          $$DatabasePropertiesTableTableFilterComposer,
          $$DatabasePropertiesTableTableOrderingComposer,
          $$DatabasePropertiesTableTableAnnotationComposer,
          $$DatabasePropertiesTableTableCreateCompanionBuilder,
          $$DatabasePropertiesTableTableUpdateCompanionBuilder,
          (
            DatabasePropertiesTableData,
            $$DatabasePropertiesTableTableReferences,
          ),
          DatabasePropertiesTableData,
          PrefetchHooks Function({
            bool databaseId,
            bool databasePropertyValuesTableRefs,
          })
        > {
  $$DatabasePropertiesTableTableTableManager(
    _$AppDatabase db,
    $DatabasePropertiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabasePropertiesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DatabasePropertiesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DatabasePropertiesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> databaseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> options = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatabasePropertiesTableCompanion(
                id: id,
                databaseId: databaseId,
                name: name,
                type: type,
                options: options,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String databaseId,
                required String name,
                required String type,
                Value<String?> options = const Value.absent(),
                Value<double> position = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatabasePropertiesTableCompanion.insert(
                id: id,
                databaseId: databaseId,
                name: name,
                type: type,
                options: options,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DatabasePropertiesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({databaseId = false, databasePropertyValuesTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (databasePropertyValuesTableRefs)
                      db.databasePropertyValuesTable,
                  ],
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
                        if (databaseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.databaseId,
                                    referencedTable:
                                        $$DatabasePropertiesTableTableReferences
                                            ._databaseIdTable(db),
                                    referencedColumn:
                                        $$DatabasePropertiesTableTableReferences
                                            ._databaseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (databasePropertyValuesTableRefs)
                        await $_getPrefetchedData<
                          DatabasePropertiesTableData,
                          $DatabasePropertiesTableTable,
                          DatabasePropertyValuesTableData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$DatabasePropertiesTableTableReferences
                                  ._databasePropertyValuesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DatabasePropertiesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).databasePropertyValuesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.propertyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DatabasePropertiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatabasePropertiesTableTable,
      DatabasePropertiesTableData,
      $$DatabasePropertiesTableTableFilterComposer,
      $$DatabasePropertiesTableTableOrderingComposer,
      $$DatabasePropertiesTableTableAnnotationComposer,
      $$DatabasePropertiesTableTableCreateCompanionBuilder,
      $$DatabasePropertiesTableTableUpdateCompanionBuilder,
      (DatabasePropertiesTableData, $$DatabasePropertiesTableTableReferences),
      DatabasePropertiesTableData,
      PrefetchHooks Function({
        bool databaseId,
        bool databasePropertyValuesTableRefs,
      })
    >;
typedef $$DatabaseRowsTableTableCreateCompanionBuilder =
    DatabaseRowsTableCompanion Function({
      required String id,
      required String databaseId,
      required String pageId,
      Value<double> position,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$DatabaseRowsTableTableUpdateCompanionBuilder =
    DatabaseRowsTableCompanion Function({
      Value<String> id,
      Value<String> databaseId,
      Value<String> pageId,
      Value<double> position,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$DatabaseRowsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DatabaseRowsTableTable,
          DatabaseRowsTableData
        > {
  $$DatabaseRowsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PagesTableTable _databaseIdTable(_$AppDatabase db) =>
      db.pagesTable.createAlias(
        $_aliasNameGenerator(db.databaseRowsTable.databaseId, db.pagesTable.id),
      );

  $$PagesTableTableProcessedTableManager get databaseId {
    final $_column = $_itemColumn<String>('database_id')!;

    final manager = $$PagesTableTableTableManager(
      $_db,
      $_db.pagesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_databaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PagesTableTable _pageIdTable(_$AppDatabase db) =>
      db.pagesTable.createAlias(
        $_aliasNameGenerator(db.databaseRowsTable.pageId, db.pagesTable.id),
      );

  $$PagesTableTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<String>('page_id')!;

    final manager = $$PagesTableTableTableManager(
      $_db,
      $_db.pagesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $DatabasePropertyValuesTableTable,
    List<DatabasePropertyValuesTableData>
  >
  _databasePropertyValuesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.databasePropertyValuesTable,
        aliasName: $_aliasNameGenerator(
          db.databaseRowsTable.id,
          db.databasePropertyValuesTable.rowId,
        ),
      );

  $$DatabasePropertyValuesTableTableProcessedTableManager
  get databasePropertyValuesTableRefs {
    final manager = $$DatabasePropertyValuesTableTableTableManager(
      $_db,
      $_db.databasePropertyValuesTable,
    ).filter((f) => f.rowId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _databasePropertyValuesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DatabaseRowsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DatabaseRowsTableTable> {
  $$DatabaseRowsTableTableFilterComposer({
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

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$PagesTableTableFilterComposer get databaseId {
    final $$PagesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableFilterComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PagesTableTableFilterComposer get pageId {
    final $$PagesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableFilterComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> databasePropertyValuesTableRefs(
    Expression<bool> Function(
      $$DatabasePropertyValuesTableTableFilterComposer f,
    )
    f,
  ) {
    final $$DatabasePropertyValuesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databasePropertyValuesTable,
          getReferencedColumn: (t) => t.rowId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertyValuesTableTableFilterComposer(
                $db: $db,
                $table: $db.databasePropertyValuesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DatabaseRowsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DatabaseRowsTableTable> {
  $$DatabaseRowsTableTableOrderingComposer({
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

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$PagesTableTableOrderingComposer get databaseId {
    final $$PagesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableOrderingComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PagesTableTableOrderingComposer get pageId {
    final $$PagesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableOrderingComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DatabaseRowsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatabaseRowsTableTable> {
  $$DatabaseRowsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$PagesTableTableAnnotationComposer get databaseId {
    final $$PagesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PagesTableTableAnnotationComposer get pageId {
    final $$PagesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pageId,
      referencedTable: $db.pagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.pagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> databasePropertyValuesTableRefs<T extends Object>(
    Expression<T> Function(
      $$DatabasePropertyValuesTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$DatabasePropertyValuesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.databasePropertyValuesTable,
          getReferencedColumn: (t) => t.rowId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertyValuesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.databasePropertyValuesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DatabaseRowsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatabaseRowsTableTable,
          DatabaseRowsTableData,
          $$DatabaseRowsTableTableFilterComposer,
          $$DatabaseRowsTableTableOrderingComposer,
          $$DatabaseRowsTableTableAnnotationComposer,
          $$DatabaseRowsTableTableCreateCompanionBuilder,
          $$DatabaseRowsTableTableUpdateCompanionBuilder,
          (DatabaseRowsTableData, $$DatabaseRowsTableTableReferences),
          DatabaseRowsTableData,
          PrefetchHooks Function({
            bool databaseId,
            bool pageId,
            bool databasePropertyValuesTableRefs,
          })
        > {
  $$DatabaseRowsTableTableTableManager(
    _$AppDatabase db,
    $DatabaseRowsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabaseRowsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DatabaseRowsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DatabaseRowsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> databaseId = const Value.absent(),
                Value<String> pageId = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatabaseRowsTableCompanion(
                id: id,
                databaseId: databaseId,
                pageId: pageId,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String databaseId,
                required String pageId,
                Value<double> position = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatabaseRowsTableCompanion.insert(
                id: id,
                databaseId: databaseId,
                pageId: pageId,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DatabaseRowsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                databaseId = false,
                pageId = false,
                databasePropertyValuesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (databasePropertyValuesTableRefs)
                      db.databasePropertyValuesTable,
                  ],
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
                        if (databaseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.databaseId,
                                    referencedTable:
                                        $$DatabaseRowsTableTableReferences
                                            ._databaseIdTable(db),
                                    referencedColumn:
                                        $$DatabaseRowsTableTableReferences
                                            ._databaseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (pageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pageId,
                                    referencedTable:
                                        $$DatabaseRowsTableTableReferences
                                            ._pageIdTable(db),
                                    referencedColumn:
                                        $$DatabaseRowsTableTableReferences
                                            ._pageIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (databasePropertyValuesTableRefs)
                        await $_getPrefetchedData<
                          DatabaseRowsTableData,
                          $DatabaseRowsTableTable,
                          DatabasePropertyValuesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DatabaseRowsTableTableReferences
                              ._databasePropertyValuesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DatabaseRowsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).databasePropertyValuesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rowId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DatabaseRowsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatabaseRowsTableTable,
      DatabaseRowsTableData,
      $$DatabaseRowsTableTableFilterComposer,
      $$DatabaseRowsTableTableOrderingComposer,
      $$DatabaseRowsTableTableAnnotationComposer,
      $$DatabaseRowsTableTableCreateCompanionBuilder,
      $$DatabaseRowsTableTableUpdateCompanionBuilder,
      (DatabaseRowsTableData, $$DatabaseRowsTableTableReferences),
      DatabaseRowsTableData,
      PrefetchHooks Function({
        bool databaseId,
        bool pageId,
        bool databasePropertyValuesTableRefs,
      })
    >;
typedef $$DatabasePropertyValuesTableTableCreateCompanionBuilder =
    DatabasePropertyValuesTableCompanion Function({
      required String id,
      required String rowId,
      required String propertyId,
      Value<String?> valueText,
      Value<double?> valueNumber,
      Value<int?> valueDate,
      Value<bool?> valueBool,
      Value<String?> valueSelect,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$DatabasePropertyValuesTableTableUpdateCompanionBuilder =
    DatabasePropertyValuesTableCompanion Function({
      Value<String> id,
      Value<String> rowId,
      Value<String> propertyId,
      Value<String?> valueText,
      Value<double?> valueNumber,
      Value<int?> valueDate,
      Value<bool?> valueBool,
      Value<String?> valueSelect,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$DatabasePropertyValuesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DatabasePropertyValuesTableTable,
          DatabasePropertyValuesTableData
        > {
  $$DatabasePropertyValuesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DatabaseRowsTableTable _rowIdTable(_$AppDatabase db) =>
      db.databaseRowsTable.createAlias(
        $_aliasNameGenerator(
          db.databasePropertyValuesTable.rowId,
          db.databaseRowsTable.id,
        ),
      );

  $$DatabaseRowsTableTableProcessedTableManager get rowId {
    final $_column = $_itemColumn<String>('row_id')!;

    final manager = $$DatabaseRowsTableTableTableManager(
      $_db,
      $_db.databaseRowsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rowIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DatabasePropertiesTableTable _propertyIdTable(_$AppDatabase db) =>
      db.databasePropertiesTable.createAlias(
        $_aliasNameGenerator(
          db.databasePropertyValuesTable.propertyId,
          db.databasePropertiesTable.id,
        ),
      );

  $$DatabasePropertiesTableTableProcessedTableManager get propertyId {
    final $_column = $_itemColumn<String>('property_id')!;

    final manager = $$DatabasePropertiesTableTableTableManager(
      $_db,
      $_db.databasePropertiesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_propertyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DatabasePropertyValuesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DatabasePropertyValuesTableTable> {
  $$DatabasePropertyValuesTableTableFilterComposer({
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

  ColumnFilters<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueNumber => $composableBuilder(
    column: $table.valueNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valueDate => $composableBuilder(
    column: $table.valueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get valueBool => $composableBuilder(
    column: $table.valueBool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueSelect => $composableBuilder(
    column: $table.valueSelect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$DatabaseRowsTableTableFilterComposer get rowId {
    final $$DatabaseRowsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rowId,
      referencedTable: $db.databaseRowsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DatabaseRowsTableTableFilterComposer(
            $db: $db,
            $table: $db.databaseRowsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DatabasePropertiesTableTableFilterComposer get propertyId {
    final $$DatabasePropertiesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.propertyId,
          referencedTable: $db.databasePropertiesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertiesTableTableFilterComposer(
                $db: $db,
                $table: $db.databasePropertiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DatabasePropertyValuesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DatabasePropertyValuesTableTable> {
  $$DatabasePropertyValuesTableTableOrderingComposer({
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

  ColumnOrderings<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueNumber => $composableBuilder(
    column: $table.valueNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueDate => $composableBuilder(
    column: $table.valueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get valueBool => $composableBuilder(
    column: $table.valueBool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueSelect => $composableBuilder(
    column: $table.valueSelect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$DatabaseRowsTableTableOrderingComposer get rowId {
    final $$DatabaseRowsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rowId,
      referencedTable: $db.databaseRowsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DatabaseRowsTableTableOrderingComposer(
            $db: $db,
            $table: $db.databaseRowsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DatabasePropertiesTableTableOrderingComposer get propertyId {
    final $$DatabasePropertiesTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.propertyId,
          referencedTable: $db.databasePropertiesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertiesTableTableOrderingComposer(
                $db: $db,
                $table: $db.databasePropertiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DatabasePropertyValuesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatabasePropertyValuesTableTable> {
  $$DatabasePropertyValuesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get valueText =>
      $composableBuilder(column: $table.valueText, builder: (column) => column);

  GeneratedColumn<double> get valueNumber => $composableBuilder(
    column: $table.valueNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valueDate =>
      $composableBuilder(column: $table.valueDate, builder: (column) => column);

  GeneratedColumn<bool> get valueBool =>
      $composableBuilder(column: $table.valueBool, builder: (column) => column);

  GeneratedColumn<String> get valueSelect => $composableBuilder(
    column: $table.valueSelect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$DatabaseRowsTableTableAnnotationComposer get rowId {
    final $$DatabaseRowsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.rowId,
          referencedTable: $db.databaseRowsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabaseRowsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.databaseRowsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$DatabasePropertiesTableTableAnnotationComposer get propertyId {
    final $$DatabasePropertiesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.propertyId,
          referencedTable: $db.databasePropertiesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DatabasePropertiesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.databasePropertiesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DatabasePropertyValuesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatabasePropertyValuesTableTable,
          DatabasePropertyValuesTableData,
          $$DatabasePropertyValuesTableTableFilterComposer,
          $$DatabasePropertyValuesTableTableOrderingComposer,
          $$DatabasePropertyValuesTableTableAnnotationComposer,
          $$DatabasePropertyValuesTableTableCreateCompanionBuilder,
          $$DatabasePropertyValuesTableTableUpdateCompanionBuilder,
          (
            DatabasePropertyValuesTableData,
            $$DatabasePropertyValuesTableTableReferences,
          ),
          DatabasePropertyValuesTableData,
          PrefetchHooks Function({bool rowId, bool propertyId})
        > {
  $$DatabasePropertyValuesTableTableTableManager(
    _$AppDatabase db,
    $DatabasePropertyValuesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabasePropertyValuesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DatabasePropertyValuesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DatabasePropertyValuesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> propertyId = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<double?> valueNumber = const Value.absent(),
                Value<int?> valueDate = const Value.absent(),
                Value<bool?> valueBool = const Value.absent(),
                Value<String?> valueSelect = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatabasePropertyValuesTableCompanion(
                id: id,
                rowId: rowId,
                propertyId: propertyId,
                valueText: valueText,
                valueNumber: valueNumber,
                valueDate: valueDate,
                valueBool: valueBool,
                valueSelect: valueSelect,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String rowId,
                required String propertyId,
                Value<String?> valueText = const Value.absent(),
                Value<double?> valueNumber = const Value.absent(),
                Value<int?> valueDate = const Value.absent(),
                Value<bool?> valueBool = const Value.absent(),
                Value<String?> valueSelect = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatabasePropertyValuesTableCompanion.insert(
                id: id,
                rowId: rowId,
                propertyId: propertyId,
                valueText: valueText,
                valueNumber: valueNumber,
                valueDate: valueDate,
                valueBool: valueBool,
                valueSelect: valueSelect,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DatabasePropertyValuesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rowId = false, propertyId = false}) {
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
                    if (rowId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rowId,
                                referencedTable:
                                    $$DatabasePropertyValuesTableTableReferences
                                        ._rowIdTable(db),
                                referencedColumn:
                                    $$DatabasePropertyValuesTableTableReferences
                                        ._rowIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (propertyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.propertyId,
                                referencedTable:
                                    $$DatabasePropertyValuesTableTableReferences
                                        ._propertyIdTable(db),
                                referencedColumn:
                                    $$DatabasePropertyValuesTableTableReferences
                                        ._propertyIdTable(db)
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

typedef $$DatabasePropertyValuesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatabasePropertyValuesTableTable,
      DatabasePropertyValuesTableData,
      $$DatabasePropertyValuesTableTableFilterComposer,
      $$DatabasePropertyValuesTableTableOrderingComposer,
      $$DatabasePropertyValuesTableTableAnnotationComposer,
      $$DatabasePropertyValuesTableTableCreateCompanionBuilder,
      $$DatabasePropertyValuesTableTableUpdateCompanionBuilder,
      (
        DatabasePropertyValuesTableData,
        $$DatabasePropertyValuesTableTableReferences,
      ),
      DatabasePropertyValuesTableData,
      PrefetchHooks Function({bool rowId, bool propertyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PagesTableTableTableManager get pagesTable =>
      $$PagesTableTableTableManager(_db, _db.pagesTable);
  $$BlocksTableTableTableManager get blocksTable =>
      $$BlocksTableTableTableManager(_db, _db.blocksTable);
  $$DatabasePropertiesTableTableTableManager get databasePropertiesTable =>
      $$DatabasePropertiesTableTableTableManager(
        _db,
        _db.databasePropertiesTable,
      );
  $$DatabaseRowsTableTableTableManager get databaseRowsTable =>
      $$DatabaseRowsTableTableTableManager(_db, _db.databaseRowsTable);
  $$DatabasePropertyValuesTableTableTableManager
  get databasePropertyValuesTable =>
      $$DatabasePropertyValuesTableTableTableManager(
        _db,
        _db.databasePropertyValuesTable,
      );
}
