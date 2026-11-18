// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BudgetCategoriesTable extends BudgetCategories
    with TableInfo<$BudgetCategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetCategoriesTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
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
  static const VerificationMeta _includeInDailyMeta = const VerificationMeta(
    'includeInDaily',
  );
  @override
  late final GeneratedColumn<bool> includeInDaily = GeneratedColumn<bool>(
    'include_in_daily',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_in_daily" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showOnHomeMeta = const VerificationMeta(
    'showOnHome',
  );
  @override
  late final GeneratedColumn<bool> showOnHome = GeneratedColumn<bool>(
    'show_on_home',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_on_home" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
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
    orderIndex,
    includeInDaily,
    showOnHome,
    isDeleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
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
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('include_in_daily')) {
      context.handle(
        _includeInDailyMeta,
        includeInDaily.isAcceptableOrUnknown(
          data['include_in_daily']!,
          _includeInDailyMeta,
        ),
      );
    }
    if (data.containsKey('show_on_home')) {
      context.handle(
        _showOnHomeMeta,
        showOnHome.isAcceptableOrUnknown(
          data['show_on_home']!,
          _showOnHomeMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      includeInDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_in_daily'],
      )!,
      showOnHome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_on_home'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BudgetCategoriesTable createAlias(String alias) {
    return $BudgetCategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final String name;
  final int orderIndex;
  final bool includeInDaily;
  final bool showOnHome;
  final bool isDeleted;
  final DateTime createdAt;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.includeInDaily,
    required this.showOnHome,
    required this.isDeleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['order_index'] = Variable<int>(orderIndex);
    map['include_in_daily'] = Variable<bool>(includeInDaily);
    map['show_on_home'] = Variable<bool>(showOnHome);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetCategoriesCompanion toCompanion(bool nullToAbsent) {
    return BudgetCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      orderIndex: Value(orderIndex),
      includeInDaily: Value(includeInDaily),
      showOnHome: Value(showOnHome),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      includeInDaily: serializer.fromJson<bool>(json['includeInDaily']),
      showOnHome: serializer.fromJson<bool>(json['showOnHome']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'includeInDaily': serializer.toJson<bool>(includeInDaily),
      'showOnHome': serializer.toJson<bool>(showOnHome),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategoryRow copyWith({
    int? id,
    String? name,
    int? orderIndex,
    bool? includeInDaily,
    bool? showOnHome,
    bool? isDeleted,
    DateTime? createdAt,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    orderIndex: orderIndex ?? this.orderIndex,
    includeInDaily: includeInDaily ?? this.includeInDaily,
    showOnHome: showOnHome ?? this.showOnHome,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryRow copyWithCompanion(BudgetCategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      includeInDaily: data.includeInDaily.present
          ? data.includeInDaily.value
          : this.includeInDaily,
      showOnHome: data.showOnHome.present
          ? data.showOnHome.value
          : this.showOnHome,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('includeInDaily: $includeInDaily, ')
          ..write('showOnHome: $showOnHome, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    orderIndex,
    includeInDaily,
    showOnHome,
    isDeleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.orderIndex == this.orderIndex &&
          other.includeInDaily == this.includeInDaily &&
          other.showOnHome == this.showOnHome &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt);
}

class BudgetCategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> orderIndex;
  final Value<bool> includeInDaily;
  final Value<bool> showOnHome;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  const BudgetCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.includeInDaily = const Value.absent(),
    this.showOnHome = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BudgetCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int orderIndex,
    this.includeInDaily = const Value.absent(),
    this.showOnHome = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       orderIndex = Value(orderIndex);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? orderIndex,
    Expression<bool>? includeInDaily,
    Expression<bool>? showOnHome,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (orderIndex != null) 'order_index': orderIndex,
      if (includeInDaily != null) 'include_in_daily': includeInDaily,
      if (showOnHome != null) 'show_on_home': showOnHome,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BudgetCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? orderIndex,
    Value<bool>? includeInDaily,
    Value<bool>? showOnHome,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
  }) {
    return BudgetCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      includeInDaily: includeInDaily ?? this.includeInDaily,
      showOnHome: showOnHome ?? this.showOnHome,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (includeInDaily.present) {
      map['include_in_daily'] = Variable<bool>(includeInDaily.value);
    }
    if (showOnHome.present) {
      map['show_on_home'] = Variable<bool>(showOnHome.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('includeInDaily: $includeInDaily, ')
          ..write('showOnHome: $showOnHome, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RatioSetsTable extends RatioSets
    with TableInfo<$RatioSetsTable, RatioSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RatioSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _applyFromMeta = const VerificationMeta(
    'applyFrom',
  );
  @override
  late final GeneratedColumn<String> applyFrom = GeneratedColumn<String>(
    'apply_from',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingRatioMeta = const VerificationMeta(
    'savingRatio',
  );
  @override
  late final GeneratedColumn<int> savingRatio = GeneratedColumn<int>(
    'saving_ratio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _investRatioMeta = const VerificationMeta(
    'investRatio',
  );
  @override
  late final GeneratedColumn<int> investRatio = GeneratedColumn<int>(
    'invest_ratio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [applyFrom, savingRatio, investRatio];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ratio_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<RatioSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('apply_from')) {
      context.handle(
        _applyFromMeta,
        applyFrom.isAcceptableOrUnknown(data['apply_from']!, _applyFromMeta),
      );
    } else if (isInserting) {
      context.missing(_applyFromMeta);
    }
    if (data.containsKey('saving_ratio')) {
      context.handle(
        _savingRatioMeta,
        savingRatio.isAcceptableOrUnknown(
          data['saving_ratio']!,
          _savingRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savingRatioMeta);
    }
    if (data.containsKey('invest_ratio')) {
      context.handle(
        _investRatioMeta,
        investRatio.isAcceptableOrUnknown(
          data['invest_ratio']!,
          _investRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investRatioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {applyFrom};
  @override
  RatioSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RatioSetRow(
      applyFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apply_from'],
      )!,
      savingRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saving_ratio'],
      )!,
      investRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invest_ratio'],
      )!,
    );
  }

  @override
  $RatioSetsTable createAlias(String alias) {
    return $RatioSetsTable(attachedDatabase, alias);
  }
}

class RatioSetRow extends DataClass implements Insertable<RatioSetRow> {
  final String applyFrom;
  final int savingRatio;
  final int investRatio;
  const RatioSetRow({
    required this.applyFrom,
    required this.savingRatio,
    required this.investRatio,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['apply_from'] = Variable<String>(applyFrom);
    map['saving_ratio'] = Variable<int>(savingRatio);
    map['invest_ratio'] = Variable<int>(investRatio);
    return map;
  }

  RatioSetsCompanion toCompanion(bool nullToAbsent) {
    return RatioSetsCompanion(
      applyFrom: Value(applyFrom),
      savingRatio: Value(savingRatio),
      investRatio: Value(investRatio),
    );
  }

  factory RatioSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RatioSetRow(
      applyFrom: serializer.fromJson<String>(json['applyFrom']),
      savingRatio: serializer.fromJson<int>(json['savingRatio']),
      investRatio: serializer.fromJson<int>(json['investRatio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'applyFrom': serializer.toJson<String>(applyFrom),
      'savingRatio': serializer.toJson<int>(savingRatio),
      'investRatio': serializer.toJson<int>(investRatio),
    };
  }

  RatioSetRow copyWith({
    String? applyFrom,
    int? savingRatio,
    int? investRatio,
  }) => RatioSetRow(
    applyFrom: applyFrom ?? this.applyFrom,
    savingRatio: savingRatio ?? this.savingRatio,
    investRatio: investRatio ?? this.investRatio,
  );
  RatioSetRow copyWithCompanion(RatioSetsCompanion data) {
    return RatioSetRow(
      applyFrom: data.applyFrom.present ? data.applyFrom.value : this.applyFrom,
      savingRatio: data.savingRatio.present
          ? data.savingRatio.value
          : this.savingRatio,
      investRatio: data.investRatio.present
          ? data.investRatio.value
          : this.investRatio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RatioSetRow(')
          ..write('applyFrom: $applyFrom, ')
          ..write('savingRatio: $savingRatio, ')
          ..write('investRatio: $investRatio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(applyFrom, savingRatio, investRatio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RatioSetRow &&
          other.applyFrom == this.applyFrom &&
          other.savingRatio == this.savingRatio &&
          other.investRatio == this.investRatio);
}

class RatioSetsCompanion extends UpdateCompanion<RatioSetRow> {
  final Value<String> applyFrom;
  final Value<int> savingRatio;
  final Value<int> investRatio;
  final Value<int> rowid;
  const RatioSetsCompanion({
    this.applyFrom = const Value.absent(),
    this.savingRatio = const Value.absent(),
    this.investRatio = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RatioSetsCompanion.insert({
    required String applyFrom,
    required int savingRatio,
    required int investRatio,
    this.rowid = const Value.absent(),
  }) : applyFrom = Value(applyFrom),
       savingRatio = Value(savingRatio),
       investRatio = Value(investRatio);
  static Insertable<RatioSetRow> custom({
    Expression<String>? applyFrom,
    Expression<int>? savingRatio,
    Expression<int>? investRatio,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (applyFrom != null) 'apply_from': applyFrom,
      if (savingRatio != null) 'saving_ratio': savingRatio,
      if (investRatio != null) 'invest_ratio': investRatio,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RatioSetsCompanion copyWith({
    Value<String>? applyFrom,
    Value<int>? savingRatio,
    Value<int>? investRatio,
    Value<int>? rowid,
  }) {
    return RatioSetsCompanion(
      applyFrom: applyFrom ?? this.applyFrom,
      savingRatio: savingRatio ?? this.savingRatio,
      investRatio: investRatio ?? this.investRatio,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (applyFrom.present) {
      map['apply_from'] = Variable<String>(applyFrom.value);
    }
    if (savingRatio.present) {
      map['saving_ratio'] = Variable<int>(savingRatio.value);
    }
    if (investRatio.present) {
      map['invest_ratio'] = Variable<int>(investRatio.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RatioSetsCompanion(')
          ..write('applyFrom: $applyFrom, ')
          ..write('savingRatio: $savingRatio, ')
          ..write('investRatio: $investRatio, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RatioItemsTable extends RatioItems
    with TableInfo<$RatioItemsTable, RatioItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RatioItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _applyFromMeta = const VerificationMeta(
    'applyFrom',
  );
  @override
  late final GeneratedColumn<String> applyFrom = GeneratedColumn<String>(
    'apply_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ratio_sets (apply_from) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_categories (id)',
    ),
  );
  static const VerificationMeta _ratioMeta = const VerificationMeta('ratio');
  @override
  late final GeneratedColumn<int> ratio = GeneratedColumn<int>(
    'ratio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [applyFrom, categoryId, ratio];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ratio_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RatioItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('apply_from')) {
      context.handle(
        _applyFromMeta,
        applyFrom.isAcceptableOrUnknown(data['apply_from']!, _applyFromMeta),
      );
    } else if (isInserting) {
      context.missing(_applyFromMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('ratio')) {
      context.handle(
        _ratioMeta,
        ratio.isAcceptableOrUnknown(data['ratio']!, _ratioMeta),
      );
    } else if (isInserting) {
      context.missing(_ratioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {applyFrom, categoryId};
  @override
  RatioItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RatioItemRow(
      applyFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apply_from'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      ratio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ratio'],
      )!,
    );
  }

  @override
  $RatioItemsTable createAlias(String alias) {
    return $RatioItemsTable(attachedDatabase, alias);
  }
}

class RatioItemRow extends DataClass implements Insertable<RatioItemRow> {
  final String applyFrom;
  final int categoryId;
  final int ratio;
  const RatioItemRow({
    required this.applyFrom,
    required this.categoryId,
    required this.ratio,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['apply_from'] = Variable<String>(applyFrom);
    map['category_id'] = Variable<int>(categoryId);
    map['ratio'] = Variable<int>(ratio);
    return map;
  }

  RatioItemsCompanion toCompanion(bool nullToAbsent) {
    return RatioItemsCompanion(
      applyFrom: Value(applyFrom),
      categoryId: Value(categoryId),
      ratio: Value(ratio),
    );
  }

  factory RatioItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RatioItemRow(
      applyFrom: serializer.fromJson<String>(json['applyFrom']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      ratio: serializer.fromJson<int>(json['ratio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'applyFrom': serializer.toJson<String>(applyFrom),
      'categoryId': serializer.toJson<int>(categoryId),
      'ratio': serializer.toJson<int>(ratio),
    };
  }

  RatioItemRow copyWith({String? applyFrom, int? categoryId, int? ratio}) =>
      RatioItemRow(
        applyFrom: applyFrom ?? this.applyFrom,
        categoryId: categoryId ?? this.categoryId,
        ratio: ratio ?? this.ratio,
      );
  RatioItemRow copyWithCompanion(RatioItemsCompanion data) {
    return RatioItemRow(
      applyFrom: data.applyFrom.present ? data.applyFrom.value : this.applyFrom,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      ratio: data.ratio.present ? data.ratio.value : this.ratio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RatioItemRow(')
          ..write('applyFrom: $applyFrom, ')
          ..write('categoryId: $categoryId, ')
          ..write('ratio: $ratio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(applyFrom, categoryId, ratio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RatioItemRow &&
          other.applyFrom == this.applyFrom &&
          other.categoryId == this.categoryId &&
          other.ratio == this.ratio);
}

class RatioItemsCompanion extends UpdateCompanion<RatioItemRow> {
  final Value<String> applyFrom;
  final Value<int> categoryId;
  final Value<int> ratio;
  final Value<int> rowid;
  const RatioItemsCompanion({
    this.applyFrom = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.ratio = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RatioItemsCompanion.insert({
    required String applyFrom,
    required int categoryId,
    required int ratio,
    this.rowid = const Value.absent(),
  }) : applyFrom = Value(applyFrom),
       categoryId = Value(categoryId),
       ratio = Value(ratio);
  static Insertable<RatioItemRow> custom({
    Expression<String>? applyFrom,
    Expression<int>? categoryId,
    Expression<int>? ratio,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (applyFrom != null) 'apply_from': applyFrom,
      if (categoryId != null) 'category_id': categoryId,
      if (ratio != null) 'ratio': ratio,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RatioItemsCompanion copyWith({
    Value<String>? applyFrom,
    Value<int>? categoryId,
    Value<int>? ratio,
    Value<int>? rowid,
  }) {
    return RatioItemsCompanion(
      applyFrom: applyFrom ?? this.applyFrom,
      categoryId: categoryId ?? this.categoryId,
      ratio: ratio ?? this.ratio,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (applyFrom.present) {
      map['apply_from'] = Variable<String>(applyFrom.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (ratio.present) {
      map['ratio'] = Variable<int>(ratio.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RatioItemsCompanion(')
          ..write('applyFrom: $applyFrom, ')
          ..write('categoryId: $categoryId, ')
          ..write('ratio: $ratio, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _budgetCategoryIdMeta = const VerificationMeta(
    'budgetCategoryId',
  );
  @override
  late final GeneratedColumn<int> budgetCategoryId = GeneratedColumn<int>(
    'budget_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budget_categories (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTransactionIdMeta =
      const VerificationMeta('sourceTransactionId');
  @override
  late final GeneratedColumn<int> sourceTransactionId = GeneratedColumn<int>(
    'source_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    amount,
    type,
    category,
    budgetCategoryId,
    date,
    memo,
    sourceTransactionId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
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
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('budget_category_id')) {
      context.handle(
        _budgetCategoryIdMeta,
        budgetCategoryId.isAcceptableOrUnknown(
          data['budget_category_id']!,
          _budgetCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('source_transaction_id')) {
      context.handle(
        _sourceTransactionIdMeta,
        sourceTransactionId.isAcceptableOrUnknown(
          data['source_transaction_id']!,
          _sourceTransactionIdMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      budgetCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_category_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      sourceTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_transaction_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final int id;
  final String title;
  final int amount;
  final String type;
  final String category;
  final int? budgetCategoryId;
  final DateTime date;
  final String? memo;
  final int? sourceTransactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const TransactionRow({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.budgetCategoryId,
    required this.date,
    this.memo,
    this.sourceTransactionId,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<int>(amount);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || budgetCategoryId != null) {
      map['budget_category_id'] = Variable<int>(budgetCategoryId);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || sourceTransactionId != null) {
      map['source_transaction_id'] = Variable<int>(sourceTransactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      budgetCategoryId: budgetCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetCategoryId),
      date: Value(date),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      sourceTransactionId: sourceTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTransactionId),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<int>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      budgetCategoryId: serializer.fromJson<int?>(json['budgetCategoryId']),
      date: serializer.fromJson<DateTime>(json['date']),
      memo: serializer.fromJson<String?>(json['memo']),
      sourceTransactionId: serializer.fromJson<int?>(
        json['sourceTransactionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<int>(amount),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'budgetCategoryId': serializer.toJson<int?>(budgetCategoryId),
      'date': serializer.toJson<DateTime>(date),
      'memo': serializer.toJson<String?>(memo),
      'sourceTransactionId': serializer.toJson<int?>(sourceTransactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  TransactionRow copyWith({
    int? id,
    String? title,
    int? amount,
    String? type,
    String? category,
    Value<int?> budgetCategoryId = const Value.absent(),
    DateTime? date,
    Value<String?> memo = const Value.absent(),
    Value<int?> sourceTransactionId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    category: category ?? this.category,
    budgetCategoryId: budgetCategoryId.present
        ? budgetCategoryId.value
        : this.budgetCategoryId,
    date: date ?? this.date,
    memo: memo.present ? memo.value : this.memo,
    sourceTransactionId: sourceTransactionId.present
        ? sourceTransactionId.value
        : this.sourceTransactionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      budgetCategoryId: data.budgetCategoryId.present
          ? data.budgetCategoryId.value
          : this.budgetCategoryId,
      date: data.date.present ? data.date.value : this.date,
      memo: data.memo.present ? data.memo.value : this.memo,
      sourceTransactionId: data.sourceTransactionId.present
          ? data.sourceTransactionId.value
          : this.sourceTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('budgetCategoryId: $budgetCategoryId, ')
          ..write('date: $date, ')
          ..write('memo: $memo, ')
          ..write('sourceTransactionId: $sourceTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amount,
    type,
    category,
    budgetCategoryId,
    date,
    memo,
    sourceTransactionId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.category == this.category &&
          other.budgetCategoryId == this.budgetCategoryId &&
          other.date == this.date &&
          other.memo == this.memo &&
          other.sourceTransactionId == this.sourceTransactionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> amount;
  final Value<String> type;
  final Value<String> category;
  final Value<int?> budgetCategoryId;
  final Value<DateTime> date;
  final Value<String?> memo;
  final Value<int?> sourceTransactionId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.budgetCategoryId = const Value.absent(),
    this.date = const Value.absent(),
    this.memo = const Value.absent(),
    this.sourceTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int amount,
    required String type,
    required String category,
    this.budgetCategoryId = const Value.absent(),
    required DateTime date,
    this.memo = const Value.absent(),
    this.sourceTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       amount = Value(amount),
       type = Value(type),
       category = Value(category),
       date = Value(date);
  static Insertable<TransactionRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? amount,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? budgetCategoryId,
    Expression<DateTime>? date,
    Expression<String>? memo,
    Expression<int>? sourceTransactionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (budgetCategoryId != null) 'budget_category_id': budgetCategoryId,
      if (date != null) 'date': date,
      if (memo != null) 'memo': memo,
      if (sourceTransactionId != null)
        'source_transaction_id': sourceTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? amount,
    Value<String>? type,
    Value<String>? category,
    Value<int?>? budgetCategoryId,
    Value<DateTime>? date,
    Value<String?>? memo,
    Value<int?>? sourceTransactionId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      budgetCategoryId: budgetCategoryId ?? this.budgetCategoryId,
      date: date ?? this.date,
      memo: memo ?? this.memo,
      sourceTransactionId: sourceTransactionId ?? this.sourceTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (budgetCategoryId.present) {
      map['budget_category_id'] = Variable<int>(budgetCategoryId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (sourceTransactionId.present) {
      map['source_transaction_id'] = Variable<int>(sourceTransactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('budgetCategoryId: $budgetCategoryId, ')
          ..write('date: $date, ')
          ..write('memo: $memo, ')
          ..write('sourceTransactionId: $sourceTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BudgetCategoriesTable budgetCategories = $BudgetCategoriesTable(
    this,
  );
  late final $RatioSetsTable ratioSets = $RatioSetsTable(this);
  late final $RatioItemsTable ratioItems = $RatioItemsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    budgetCategories,
    ratioSets,
    ratioItems,
    transactions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ratio_sets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ratio_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BudgetCategoriesTableCreateCompanionBuilder =
    BudgetCategoriesCompanion Function({
      Value<int> id,
      required String name,
      required int orderIndex,
      Value<bool> includeInDaily,
      Value<bool> showOnHome,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
    });
typedef $$BudgetCategoriesTableUpdateCompanionBuilder =
    BudgetCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> orderIndex,
      Value<bool> includeInDaily,
      Value<bool> showOnHome,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
    });

final class $$BudgetCategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetCategoriesTable, CategoryRow> {
  $$BudgetCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RatioItemsTable, List<RatioItemRow>>
  _ratioItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ratioItems,
    aliasName: 'budget_categories__id__ratio_items__category_id',
  );

  $$RatioItemsTableProcessedTableManager get ratioItemsRefs {
    final manager = $$RatioItemsTableTableManager(
      $_db,
      $_db.ratioItems,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ratioItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'budget_categories__id__transactions__budget_category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.budgetCategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BudgetCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetCategoriesTable> {
  $$BudgetCategoriesTableFilterComposer({
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

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeInDaily => $composableBuilder(
    column: $table.includeInDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ratioItemsRefs(
    Expression<bool> Function($$RatioItemsTableFilterComposer f) f,
  ) {
    final $$RatioItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ratioItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RatioItemsTableFilterComposer(
            $db: $db,
            $table: $db.ratioItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.budgetCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetCategoriesTable> {
  $$BudgetCategoriesTableOrderingComposer({
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

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInDaily => $composableBuilder(
    column: $table.includeInDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetCategoriesTable> {
  $$BudgetCategoriesTableAnnotationComposer({
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

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeInDaily => $composableBuilder(
    column: $table.includeInDaily,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> ratioItemsRefs<T extends Object>(
    Expression<T> Function($$RatioItemsTableAnnotationComposer a) f,
  ) {
    final $$RatioItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ratioItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RatioItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.ratioItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.budgetCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetCategoriesTable,
          CategoryRow,
          $$BudgetCategoriesTableFilterComposer,
          $$BudgetCategoriesTableOrderingComposer,
          $$BudgetCategoriesTableAnnotationComposer,
          $$BudgetCategoriesTableCreateCompanionBuilder,
          $$BudgetCategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$BudgetCategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool ratioItemsRefs, bool transactionsRefs})
        > {
  $$BudgetCategoriesTableTableManager(
    _$AppDatabase db,
    $BudgetCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<bool> includeInDaily = const Value.absent(),
                Value<bool> showOnHome = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BudgetCategoriesCompanion(
                id: id,
                name: name,
                orderIndex: orderIndex,
                includeInDaily: includeInDaily,
                showOnHome: showOnHome,
                isDeleted: isDeleted,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int orderIndex,
                Value<bool> includeInDaily = const Value.absent(),
                Value<bool> showOnHome = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BudgetCategoriesCompanion.insert(
                id: id,
                name: name,
                orderIndex: orderIndex,
                includeInDaily: includeInDaily,
                showOnHome: showOnHome,
                isDeleted: isDeleted,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetCategoriesTable, CategoryRow>(table),
                  $$BudgetCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ratioItemsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ratioItemsRefs) db.ratioItems,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ratioItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $BudgetCategoriesTable,
                          RatioItemRow,
                          $RatioItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetCategoriesTableReferences
                              ._ratioItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).ratioItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $BudgetCategoriesTable,
                          TransactionRow,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetCategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'budget_category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BudgetCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetCategoriesTable,
      CategoryRow,
      $$BudgetCategoriesTableFilterComposer,
      $$BudgetCategoriesTableOrderingComposer,
      $$BudgetCategoriesTableAnnotationComposer,
      $$BudgetCategoriesTableCreateCompanionBuilder,
      $$BudgetCategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$BudgetCategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool ratioItemsRefs, bool transactionsRefs})
    >;
typedef $$RatioSetsTableCreateCompanionBuilder =
    RatioSetsCompanion Function({
      required String applyFrom,
      required int savingRatio,
      required int investRatio,
      Value<int> rowid,
    });
typedef $$RatioSetsTableUpdateCompanionBuilder =
    RatioSetsCompanion Function({
      Value<String> applyFrom,
      Value<int> savingRatio,
      Value<int> investRatio,
      Value<int> rowid,
    });

final class $$RatioSetsTableReferences
    extends BaseReferences<_$AppDatabase, $RatioSetsTable, RatioSetRow> {
  $$RatioSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RatioItemsTable, List<RatioItemRow>>
  _ratioItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ratioItems,
    aliasName: 'ratio_sets__apply_from__ratio_items__apply_from',
  );

  $$RatioItemsTableProcessedTableManager get ratioItemsRefs {
    final manager = $$RatioItemsTableTableManager($_db, $_db.ratioItems).filter(
      (f) =>
          f.applyFrom.applyFrom.sqlEquals($_itemColumn<String>('apply_from')!),
    );

    final cache = $_typedResult.readTableOrNull(_ratioItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RatioSetsTableFilterComposer
    extends Composer<_$AppDatabase, $RatioSetsTable> {
  $$RatioSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get applyFrom => $composableBuilder(
    column: $table.applyFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingRatio => $composableBuilder(
    column: $table.savingRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get investRatio => $composableBuilder(
    column: $table.investRatio,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ratioItemsRefs(
    Expression<bool> Function($$RatioItemsTableFilterComposer f) f,
  ) {
    final $$RatioItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applyFrom,
      referencedTable: $db.ratioItems,
      getReferencedColumn: (t) => t.applyFrom,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RatioItemsTableFilterComposer(
            $db: $db,
            $table: $db.ratioItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RatioSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $RatioSetsTable> {
  $$RatioSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get applyFrom => $composableBuilder(
    column: $table.applyFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingRatio => $composableBuilder(
    column: $table.savingRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get investRatio => $composableBuilder(
    column: $table.investRatio,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RatioSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RatioSetsTable> {
  $$RatioSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get applyFrom =>
      $composableBuilder(column: $table.applyFrom, builder: (column) => column);

  GeneratedColumn<int> get savingRatio => $composableBuilder(
    column: $table.savingRatio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get investRatio => $composableBuilder(
    column: $table.investRatio,
    builder: (column) => column,
  );

  Expression<T> ratioItemsRefs<T extends Object>(
    Expression<T> Function($$RatioItemsTableAnnotationComposer a) f,
  ) {
    final $$RatioItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applyFrom,
      referencedTable: $db.ratioItems,
      getReferencedColumn: (t) => t.applyFrom,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RatioItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.ratioItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RatioSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RatioSetsTable,
          RatioSetRow,
          $$RatioSetsTableFilterComposer,
          $$RatioSetsTableOrderingComposer,
          $$RatioSetsTableAnnotationComposer,
          $$RatioSetsTableCreateCompanionBuilder,
          $$RatioSetsTableUpdateCompanionBuilder,
          (RatioSetRow, $$RatioSetsTableReferences),
          RatioSetRow,
          PrefetchHooks Function({bool ratioItemsRefs})
        > {
  $$RatioSetsTableTableManager(_$AppDatabase db, $RatioSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RatioSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RatioSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RatioSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> applyFrom = const Value.absent(),
                Value<int> savingRatio = const Value.absent(),
                Value<int> investRatio = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatioSetsCompanion(
                applyFrom: applyFrom,
                savingRatio: savingRatio,
                investRatio: investRatio,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String applyFrom,
                required int savingRatio,
                required int investRatio,
                Value<int> rowid = const Value.absent(),
              }) => RatioSetsCompanion.insert(
                applyFrom: applyFrom,
                savingRatio: savingRatio,
                investRatio: investRatio,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RatioSetsTable, RatioSetRow>(table),
                  $$RatioSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ratioItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ratioItemsRefs) db.ratioItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ratioItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      RatioSetRow,
                      $RatioSetsTable,
                      RatioItemRow,
                      $RatioItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RatioSetsTableReferences
                          ._ratioItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RatioSetsTableReferences(
                            db,
                            table,
                            p0,
                          ).ratioItemsRefs,
                      currentColumn: 'apply_from',
                      referencedColumn: 'apply_from',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RatioSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RatioSetsTable,
      RatioSetRow,
      $$RatioSetsTableFilterComposer,
      $$RatioSetsTableOrderingComposer,
      $$RatioSetsTableAnnotationComposer,
      $$RatioSetsTableCreateCompanionBuilder,
      $$RatioSetsTableUpdateCompanionBuilder,
      (RatioSetRow, $$RatioSetsTableReferences),
      RatioSetRow,
      PrefetchHooks Function({bool ratioItemsRefs})
    >;
typedef $$RatioItemsTableCreateCompanionBuilder =
    RatioItemsCompanion Function({
      required String applyFrom,
      required int categoryId,
      required int ratio,
      Value<int> rowid,
    });
typedef $$RatioItemsTableUpdateCompanionBuilder =
    RatioItemsCompanion Function({
      Value<String> applyFrom,
      Value<int> categoryId,
      Value<int> ratio,
      Value<int> rowid,
    });

final class $$RatioItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RatioItemsTable, RatioItemRow> {
  $$RatioItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RatioSetsTable _applyFromTable(_$AppDatabase db) => db.ratioSets
      .createAlias('ratio_items__apply_from__ratio_sets__apply_from');

  $$RatioSetsTableProcessedTableManager get applyFrom {
    final $_column = $_itemColumn<String>('apply_from')!;

    final manager = $$RatioSetsTableTableManager(
      $_db,
      $_db.ratioSets,
    ).filter((f) => f.applyFrom.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_applyFromTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BudgetCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .budgetCategories
      .createAlias('ratio_items__category_id__budget_categories__id');

  $$BudgetCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$BudgetCategoriesTableTableManager(
      $_db,
      $_db.budgetCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RatioItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RatioItemsTable> {
  $$RatioItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnFilters(column),
  );

  $$RatioSetsTableFilterComposer get applyFrom {
    final $$RatioSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applyFrom,
      referencedTable: $db.ratioSets,
      getReferencedColumn: (t) => t.applyFrom,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RatioSetsTableFilterComposer(
            $db: $db,
            $table: $db.ratioSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableFilterComposer get categoryId {
    final $$BudgetCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.budgetCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.budgetCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RatioItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RatioItemsTable> {
  $$RatioItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnOrderings(column),
  );

  $$RatioSetsTableOrderingComposer get applyFrom {
    final $$RatioSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applyFrom,
      referencedTable: $db.ratioSets,
      getReferencedColumn: (t) => t.applyFrom,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RatioSetsTableOrderingComposer(
            $db: $db,
            $table: $db.ratioSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableOrderingComposer get categoryId {
    final $$BudgetCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.budgetCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.budgetCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RatioItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RatioItemsTable> {
  $$RatioItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ratio =>
      $composableBuilder(column: $table.ratio, builder: (column) => column);

  $$RatioSetsTableAnnotationComposer get applyFrom {
    final $$RatioSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applyFrom,
      referencedTable: $db.ratioSets,
      getReferencedColumn: (t) => t.applyFrom,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RatioSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.ratioSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetCategoriesTableAnnotationComposer get categoryId {
    final $$BudgetCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.budgetCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RatioItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RatioItemsTable,
          RatioItemRow,
          $$RatioItemsTableFilterComposer,
          $$RatioItemsTableOrderingComposer,
          $$RatioItemsTableAnnotationComposer,
          $$RatioItemsTableCreateCompanionBuilder,
          $$RatioItemsTableUpdateCompanionBuilder,
          (RatioItemRow, $$RatioItemsTableReferences),
          RatioItemRow,
          PrefetchHooks Function({bool applyFrom, bool categoryId})
        > {
  $$RatioItemsTableTableManager(_$AppDatabase db, $RatioItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RatioItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RatioItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RatioItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> applyFrom = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> ratio = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatioItemsCompanion(
                applyFrom: applyFrom,
                categoryId: categoryId,
                ratio: ratio,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String applyFrom,
                required int categoryId,
                required int ratio,
                Value<int> rowid = const Value.absent(),
              }) => RatioItemsCompanion.insert(
                applyFrom: applyFrom,
                categoryId: categoryId,
                ratio: ratio,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RatioItemsTable, RatioItemRow>(table),
                  $$RatioItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({applyFrom = false, categoryId = false}) {
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
                    if (applyFrom) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.applyFrom,
                                referencedTable: $$RatioItemsTableReferences
                                    ._applyFromTable(db),
                                referencedColumn: $$RatioItemsTableReferences
                                    ._applyFromTable(db)
                                    .applyFrom,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$RatioItemsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$RatioItemsTableReferences
                                    ._categoryIdTable(db)
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

typedef $$RatioItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RatioItemsTable,
      RatioItemRow,
      $$RatioItemsTableFilterComposer,
      $$RatioItemsTableOrderingComposer,
      $$RatioItemsTableAnnotationComposer,
      $$RatioItemsTableCreateCompanionBuilder,
      $$RatioItemsTableUpdateCompanionBuilder,
      (RatioItemRow, $$RatioItemsTableReferences),
      RatioItemRow,
      PrefetchHooks Function({bool applyFrom, bool categoryId})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required String title,
      required int amount,
      required String type,
      required String category,
      Value<int?> budgetCategoryId,
      required DateTime date,
      Value<String?> memo,
      Value<int?> sourceTransactionId,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> amount,
      Value<String> type,
      Value<String> category,
      Value<int?> budgetCategoryId,
      Value<DateTime> date,
      Value<String?> memo,
      Value<int?> sourceTransactionId,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BudgetCategoriesTable _budgetCategoryIdTable(_$AppDatabase db) => db
      .budgetCategories
      .createAlias('transactions__budget_category_id__budget_categories__id');

  $$BudgetCategoriesTableProcessedTableManager? get budgetCategoryId {
    final $_column = $_itemColumn<int>('budget_category_id');
    if ($_column == null) return null;
    final manager = $$BudgetCategoriesTableTableManager(
      $_db,
      $_db.budgetCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _sourceTransactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('transactions__source_transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager? get sourceTransactionId {
    final $_column = $_itemColumn<int>('source_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
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

  $$BudgetCategoriesTableFilterComposer get budgetCategoryId {
    final $$BudgetCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetCategoryId,
      referencedTable: $db.budgetCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.budgetCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableFilterComposer get sourceTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
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

  $$BudgetCategoriesTableOrderingComposer get budgetCategoryId {
    final $$BudgetCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetCategoryId,
      referencedTable: $db.budgetCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.budgetCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableOrderingComposer get sourceTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
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

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BudgetCategoriesTableAnnotationComposer get budgetCategoryId {
    final $$BudgetCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetCategoryId,
      referencedTable: $db.budgetCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get sourceTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({
            bool budgetCategoryId,
            bool sourceTransactionId,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int?> budgetCategoryId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<int?> sourceTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                title: title,
                amount: amount,
                type: type,
                category: category,
                budgetCategoryId: budgetCategoryId,
                date: date,
                memo: memo,
                sourceTransactionId: sourceTransactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int amount,
                required String type,
                required String category,
                Value<int?> budgetCategoryId = const Value.absent(),
                required DateTime date,
                Value<String?> memo = const Value.absent(),
                Value<int?> sourceTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                title: title,
                amount: amount,
                type: type,
                category: category,
                budgetCategoryId: budgetCategoryId,
                date: date,
                memo: memo,
                sourceTransactionId: sourceTransactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionRow>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({budgetCategoryId = false, sourceTransactionId = false}) {
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
                        if (budgetCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.budgetCategoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._budgetCategoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._budgetCategoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceTransactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceTransactionId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._sourceTransactionIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._sourceTransactionIdTable(db)
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({bool budgetCategoryId, bool sourceTransactionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BudgetCategoriesTableTableManager get budgetCategories =>
      $$BudgetCategoriesTableTableManager(_db, _db.budgetCategories);
  $$RatioSetsTableTableManager get ratioSets =>
      $$RatioSetsTableTableManager(_db, _db.ratioSets);
  $$RatioItemsTableTableManager get ratioItems =>
      $$RatioItemsTableTableManager(_db, _db.ratioItems);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
