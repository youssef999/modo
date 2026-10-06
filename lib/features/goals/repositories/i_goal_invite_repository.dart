import '../models/goal_invite.dart';

/// Interface for managing goal collaboration invitations.
abstract class IGoalInviteRepository {
  /// Sends an invitation email to [inviteeEmail] to join goal [goalId].
  Future<GoalInvite> sendInvite({
    required String goalId,
    required String goalTitle,
    required String inviterUid,
    required String inviterEmail,
    required String inviterName,
    required String inviteeEmail,
  });

  /// Fetches all pending invites addressed to [inviteeEmail].
  Future<List<GoalInvite>> fetchPendingInvites(String inviteeEmail);

  /// Accepts an invite — the acceptor becomes a partner on the goal.
  Future<void> acceptInvite({
    required GoalInvite invite,
    required String acceptorUid,
    required String acceptorEmail,
    required String acceptorName,
  });

  /// Declines an invite.
  Future<void> declineInvite(String inviteId);
}
