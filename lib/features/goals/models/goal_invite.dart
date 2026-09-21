/// Status of a collaboration invite to a goal.
enum GoalInviteStatus { pending, accepted, declined }

/// Represents an invitation for a user to collaborate on a specific [GoalModel].
///
/// The invite is stored in Firestore's `goal_invites` collection.
/// When accepted, the invitee becomes a [GoalMember] with the `partner` role.
class GoalInvite {
  const GoalInvite({
    required this.id,
    required this.goalId,
    required this.goalTitle,
    required this.inviterUid,
    required this.inviterEmail,
    required this.inviterName,
    required this.inviteeEmail,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  final String id;
  final String goalId;
  final String goalTitle;
  final String inviterUid;
  final String inviterEmail;
  final String inviterName;
  final String inviteeEmail;
  final GoalInviteStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  bool get isPending => status == GoalInviteStatus.pending;
  bool get isAccepted => status == GoalInviteStatus.accepted;

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'goalTitle': goalTitle,
      'inviterUid': inviterUid,
      'inviterEmail': inviterEmail,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      if (respondedAt != null) 'respondedAt': respondedAt!.toIso8601String(),
    };
  }

  factory GoalInvite.fromMap(String id, Map<String, dynamic> map) {
    GoalInviteStatus parsedStatus = GoalInviteStatus.pending;
    final statusStr = map['status'] as String?;
    if (statusStr == GoalInviteStatus.accepted.name) {
      parsedStatus = GoalInviteStatus.accepted;
    } else if (statusStr == GoalInviteStatus.declined.name) {
      parsedStatus = GoalInviteStatus.declined;
    }

    return GoalInvite(
      id: id,
      goalId: map['goalId'] as String? ?? '',
      goalTitle: map['goalTitle'] as String? ?? '',
      inviterUid: map['inviterUid'] as String? ?? '',
      inviterEmail: map['inviterEmail'] as String? ?? '',
      inviterName: map['inviterName'] as String? ?? '',
      inviteeEmail: map['inviteeEmail'] as String? ?? '',
      status: parsedStatus,
      createdAt: _parseDate(map['createdAt']),
      respondedAt: map['respondedAt'] != null
          ? _parseDate(map['respondedAt'])
          : null,
    );
  }

  GoalInvite copyWith({GoalInviteStatus? status, DateTime? respondedAt}) {
    return GoalInvite(
      id: id,
      goalId: goalId,
      goalTitle: goalTitle,
      inviterUid: inviterUid,
      inviterEmail: inviterEmail,
      inviterName: inviterName,
      inviteeEmail: inviteeEmail,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GoalInvite && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
