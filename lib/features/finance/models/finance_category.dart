import 'package:flutter/material.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/category_icons.dart';

import 'finance_category_role.dart';

class FinanceCategory {
  const FinanceCategory({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.builtInKey,
    required this.iconKey,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String builtInKey;
  final String iconKey;
  final FinanceCategoryRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBuiltIn => builtInKey.isNotEmpty;

  bool get isAllocate => role == FinanceCategoryRole.allocate;

  bool get isIncome => role == FinanceCategoryRole.income;

  bool get isSpend => role == FinanceCategoryRole.spend;

  String get labelKey {
    return switch (builtInKey) {
      'food' => LocaleKeys.financeCatFood,
      'outings' => LocaleKeys.financeCatOutings,
      'bills' => LocaleKeys.financeCatBills,
      'health' => LocaleKeys.financeCatHealth,
      'transport' => LocaleKeys.financeCatTransport,
      'savings' => LocaleKeys.financeCatSavings,
      'invest' => LocaleKeys.financeCatInvest,
      'salary' => LocaleKeys.financeSalary,
      'bonus' => LocaleKeys.financeCatBonus,
      'gift' => LocaleKeys.financeCatGift,
      'profit' => LocaleKeys.financeCatProfit,
      'association' => LocaleKeys.financeCatAssociation,
      'other_income' => LocaleKeys.financeCatOtherIncome,
      _ => '',
    };
  }

  IconData get icon => CategoryIcons.of(iconKey);

  Color color(AppPalette palette) => CategoryIcons.color(iconKey, palette);

  FinanceCategory copyWith({
    String? ownerId,
    String? name,
    FinanceCategoryRole? role,
    DateTime? updatedAt,
  }) {
    return FinanceCategory(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      builtInKey: builtInKey,
      iconKey: iconKey,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'builtInKey': builtInKey,
      'iconKey': iconKey,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinanceCategory.fromMap(String id, Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    final builtInKey = data['builtInKey'] as String? ?? '';
    return FinanceCategory(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      builtInKey: builtInKey,
      iconKey: data['iconKey'] as String? ?? 'custom',
      role: FinanceCategoryRoleX.fromStorage(
        data['role'] as String? ?? _roleForBuiltIn(builtInKey).name,
      ),
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }

  static FinanceCategoryRole _roleForBuiltIn(String key) {
    return switch (key) {
      'savings' || 'invest' => FinanceCategoryRole.allocate,
      'salary' ||
      'bonus' ||
      'gift' ||
      'profit' ||
      'association' ||
      'other_income' => FinanceCategoryRole.income,
      _ => FinanceCategoryRole.spend,
    };
  }

  static const _spendKeys = ['food', 'outings', 'bills', 'health', 'transport'];
  static const _allocateKeys = ['savings', 'invest'];
  static const _incomeKeys = [
    'salary',
    'bonus',
    'gift',
    'profit',
    'association',
    'other_income',
  ];

  static List<FinanceCategory> builtIns(String ownerId) {
    final now = DateTime.now();
    final keys = [..._spendKeys, ..._allocateKeys, ..._incomeKeys];
    return [
      for (final key in keys)
        FinanceCategory(
          id: key,
          ownerId: ownerId,
          name: '',
          builtInKey: key,
          iconKey: key,
          role: _roleForBuiltIn(key),
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  static List<FinanceCategory> withMissingBuiltIns(
    String ownerId,
    List<FinanceCategory> existing,
  ) {
    final byId = {for (final item in existing) item.id: item};
    for (final builtIn in builtIns(ownerId)) {
      byId.putIfAbsent(builtIn.id, () => builtIn);
    }
    return byId.values.toList();
  }
}
