/// Role of a user within a specific goal.
enum GoalMemberRole { owner, partner }

/// Represents a member (owner or partner) of a specific [GoalModel].
class GoalMember {
  const GoalMember({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final GoalMemberRole role;
  final DateTime joinedAt;

  bool get isOwner => role == GoalMemberRole.owner;
  bool get isPartner => role == GoalMemberRole.partner;

  /// Initials derived from displayName or email for avatar display.
  String get initials {
    final name = displayName.isNotEmpty ? displayName : email;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory GoalMember.fromMap(Map<String, dynamic> map) {
    GoalMemberRole parsedRole = GoalMemberRole.partner;
    final roleStr = map['role'] as String?;
    if (roleStr == GoalMemberRole.owner.name) {
      parsedRole = GoalMemberRole.owner;
    }

    final joinedAt = map['joinedAt'];
    DateTime parsedJoinedAt;
    if (joinedAt is DateTime) {
      parsedJoinedAt = joinedAt;
    } else if (joinedAt is String) {
      parsedJoinedAt = DateTime.tryParse(joinedAt) ?? DateTime.now();
    } else {
      parsedJoinedAt = DateTime.now();
    }

    return GoalMember(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      role: parsedRole,
      joinedAt: parsedJoinedAt,
    );
  }

  GoalMember copyWith({
    String? uid,
    String? email,
    String? displayName,
    GoalMemberRole? role,
    DateTime? joinedAt,
  }) {
    return GoalMember(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GoalMember && other.uid == uid);

  @override
  int get hashCode => uid.hashCode;
}
