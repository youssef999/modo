import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_daily_app/core/constants/firestore_paths.dart';
import 'package:life_daily_app/core/errors/app_failure.dart';

import '../models/goal_invite.dart';
import '../models/goal_member.dart';
import 'i_goal_invite_repository.dart';

/// Firestore implementation of [IGoalInviteRepository].
///
/// Firestore structure:
/// - `goal_invites/{inviteId}` — top-level collection for all invites.
/// - `goals/{goalId}/members/{uid}` — subcollection added when invite is accepted.
/// - `goals/{goalId}.memberIds` — array updated atomically when invite is accepted.
class FirestoreGoalInviteRepository implements IGoalInviteRepository {
  FirestoreGoalInviteRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _invitesCol =>
      _db.collection(FirestorePaths.goalInvitesCol());

  @override
  Future<GoalInvite> sendInvite({
    required String goalId,
    required String goalTitle,
    required String inviterUid,
    required String inviterEmail,
    required String inviterName,
    required String inviteeEmail,
  }) async {
    final cleanEmail = inviteeEmail.trim().toLowerCase();

    // Check for an existing pending invite to prevent duplicates
    final existing = await _invitesCol
        .where('goalId', isEqualTo: goalId)
        .where('inviteeEmail', isEqualTo: cleanEmail)
        .where('status', isEqualTo: GoalInviteStatus.pending.name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw const AppFailure('An invite to this person is already pending.');
    }

    final ref = _invitesCol.doc();
    final invite = GoalInvite(
      id: ref.id,
      goalId: goalId,
      goalTitle: goalTitle,
      inviterUid: inviterUid,
      inviterEmail: inviterEmail,
      inviterName: inviterName,
      inviteeEmail: cleanEmail,
      status: GoalInviteStatus.pending,
      createdAt: DateTime.now(),
    );

    await ref.set(invite.toMap());
    return invite;
  }

  @override
  Future<List<GoalInvite>> fetchPendingInvites(String inviteeEmail) async {
    final cleanEmail = inviteeEmail.trim().toLowerCase();
    final snapshot = await _invitesCol
        .where('inviteeEmail', isEqualTo: cleanEmail)
        .where('status', isEqualTo: GoalInviteStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GoalInvite.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> acceptInvite({
    required GoalInvite invite,
    required String acceptorUid,
    required String acceptorEmail,
    required String acceptorName,
  }) async {
    final now = DateTime.now();
    final member = GoalMember(
      uid: acceptorUid,
      email: acceptorEmail,
      displayName: acceptorName,
      role: GoalMemberRole.partner,
      joinedAt: now,
    );

    // Firestore transaction: update invite + add member + update memberIds
    await _db.runTransaction((tx) async {
      final inviteRef = _invitesCol.doc(invite.id);
      final goalRef = _db.doc(FirestorePaths.goalDoc(invite.goalId));
      final memberRef = _db.doc(
        FirestorePaths.goalMemberDoc(invite.goalId, acceptorUid),
      );

      tx.update(inviteRef, {
        'status': GoalInviteStatus.accepted.name,
        'respondedAt': now.toIso8601String(),
      });

      tx.set(memberRef, member.toMap());

      tx.update(goalRef, {
        'memberIds': FieldValue.arrayUnion([acceptorUid]),
        'members': FieldValue.arrayUnion([member.toMap()]),
      });
    });
  }

  @override
  Future<void> declineInvite(String inviteId) async {
    await _invitesCol.doc(inviteId).update({
      'status': GoalInviteStatus.declined.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
  }
}
