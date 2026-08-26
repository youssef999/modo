import 'package:life_daily_app/core/constants/locale_keys.dart';

class WorkFolder {
  const WorkFolder({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.builtInKey,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String generalId = 'general';

  final String id;
  final String ownerId;
  final String name;
  final String builtInKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBuiltIn => builtInKey == generalId;

  String get labelKey => isBuiltIn ? LocaleKeys.folderGeneral : '';

  WorkFolder copyWith({String? ownerId, String? name, DateTime? updatedAt}) {
    return WorkFolder(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      builtInKey: builtInKey,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'builtInKey': builtInKey,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkFolder.fromMap(String id, Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now();
    return WorkFolder(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      builtInKey: data['builtInKey'] as String? ?? '',
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? createdAt,
    );
  }

  static WorkFolder general(String ownerId) {
    final now = DateTime.now();
    return WorkFolder(
      id: generalId,
      ownerId: ownerId,
      name: '',
      builtInKey: generalId,
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<WorkFolder> withGeneral(String ownerId, List<WorkFolder> existing) {
    final byId = {for (final item in existing) item.id: item};
    byId.putIfAbsent(generalId, () => general(ownerId));
    return byId.values.toList();
  }
}
