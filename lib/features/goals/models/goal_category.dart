import 'package:flutter/material.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/category_icons.dart';

class GoalCategory {
  const GoalCategory({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.builtInKey,
    required this.iconKey,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String builtInKey;
  final String iconKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBuiltIn => builtInKey.isNotEmpty;

  String get labelKey {
    return switch (builtInKey) {
      'course' => LocaleKeys.categoryCourse,
      'work' => LocaleKeys.categoryWork,
      'healthy_routine' => LocaleKeys.categoryRoutine,
      'nutrition' => LocaleKeys.categoryNutrition,
      'family' => LocaleKeys.categoryFamily,
      'healthy_sleep' => LocaleKeys.categorySleep,
      _ => '',
    };
  }

  IconData get icon => CategoryIcons.of(iconKey);

  Color color(AppPalette palette) => CategoryIcons.color(iconKey, palette);

  GoalCategory copyWith({String? ownerId, String? name, DateTime? updatedAt}) {
    return GoalCategory(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      builtInKey: builtInKey,
      iconKey: iconKey,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GoalCategory.fromMap(String id, Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    return GoalCategory(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      builtInKey: data['builtInKey'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? 'custom',
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }

  static List<GoalCategory> builtIns(String ownerId) {
    final now = DateTime.now();
    const keys = [
      'course',
      'work',
      'healthy_routine',
      'nutrition',
      'family',
      'healthy_sleep',
    ];
    return [
      for (final key in keys)
        GoalCategory(
          id: key,
          ownerId: ownerId,
          name: '',
          builtInKey: key,
          iconKey: key,
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  static List<GoalCategory> withMissingBuiltIns(
    String ownerId,
    List<GoalCategory> existing,
  ) {
    final byId = {for (final item in existing) item.id: item};
    for (final builtIn in builtIns(ownerId)) {
      byId.putIfAbsent(builtIn.id, () => builtIn);
    }
    return byId.values.toList();
  }
}
