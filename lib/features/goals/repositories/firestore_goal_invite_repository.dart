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

    // Also queue an email in the 'mail' collection for Firebase Trigger Email extension (if configured)
    try {
      await _db.collection('mail').add({
        'to': [cleanEmail],
        'message': {
          'subject': 'You have been invited to collaborate on "${invite.goalTitle}" in Life Daily',
          'text': '${inviterName.isNotEmpty ? inviterName : inviterEmail} invited you to join the goal "${invite.goalTitle}" on Life Daily. Log in with $cleanEmail to accept your invitation.',
          'html': '<p><strong>${inviterName.isNotEmpty ? inviterName : inviterEmail}</strong> invited you to join the goal <strong>${invite.goalTitle}</strong> on Life Daily.</p><p>Log in with <code>$cleanEmail</code> on the app to accept and collaborate.</p>',
        },
      });
    } catch (_) {
      // Ignored if rules don't permit or mail extension isn't used
    }

    return invite;
  }

  @override
  Future<List<GoalInvite>> fetchPendingInvites(String inviteeEmail) async {
    final cleanEmail = inviteeEmail.trim().toLowerCase();
    final snapshot = await _invitesCol
        .where('inviteeEmail', isEqualTo: cleanEmail)
        .where('status', isEqualTo: GoalInviteStatus.pending.name)
        .get();

    final list = snapshot.docs
        .map((doc) => GoalInvite.fromMap(doc.id, doc.data()))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
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

    // Firestore transaction: all reads must happen before any writes
    await _db.runTransaction((tx) async {
      final inviteRef = _invitesCol.doc(invite.id);
      final topGoalRef = _db.doc(FirestorePaths.goalDoc(invite.goalId));
      final userGoalRef = _db
          .collection(FirestorePaths.userGoals(invite.inviterUid))
          .doc(invite.goalId);
      final acceptorGoalRef = _db
          .collection(FirestorePaths.userGoals(acceptorUid))
          .doc(invite.goalId);
      final memberRef = _db.doc(
        FirestorePaths.goalMemberDoc(invite.goalId, acceptorUid),
      );

      // 1. Transaction read phase
      final topGoalSnap = await tx.get(topGoalRef);
      final userGoalSnap = await tx.get(userGoalRef);

      // 2. Transaction write phase
      tx.update(inviteRef, {
        'status': GoalInviteStatus.accepted.name,
        'respondedAt': now.toIso8601String(),
      });

      tx.set(memberRef, member.toMap());

      if (topGoalSnap.exists) {
        tx.update(topGoalRef, {
          'memberIds': FieldValue.arrayUnion([acceptorUid]),
          'members': FieldValue.arrayUnion([member.toMap()]),
          'updatedAt': now.toIso8601String(),
        });
        if (userGoalSnap.exists) {
          tx.update(userGoalRef, {
            'memberIds': FieldValue.arrayUnion([acceptorUid]),
            'members': FieldValue.arrayUnion([member.toMap()]),
            'updatedAt': now.toIso8601String(),
          });
        }
        final topData = Map<String, dynamic>.from(topGoalSnap.data() ?? {});
        final existingMemberIds =
            List<String>.from(topData['memberIds'] as List? ?? []);
        if (!existingMemberIds.contains(acceptorUid)) {
          existingMemberIds.add(acceptorUid);
        }
        topData['memberIds'] = existingMemberIds;
        final existingMembers =
            List<dynamic>.from(topData['members'] as List? ?? []);
        existingMembers.add(member.toMap());
        topData['members'] = existingMembers;
        topData['updatedAt'] = now.toIso8601String();
        tx.set(acceptorGoalRef, topData, SetOptions(merge: true));
      } else if (userGoalSnap.exists) {
        final userData = Map<String, dynamic>.from(userGoalSnap.data() ?? {});
        final existingMemberIds = List<String>.from(
            userData['memberIds'] as List? ?? [invite.inviterUid]);
        if (!existingMemberIds.contains(acceptorUid)) {
          existingMemberIds.add(acceptorUid);
        }
        userData['memberIds'] = existingMemberIds;
        final existingMembers =
            List<dynamic>.from(userData['members'] as List? ?? []);
        existingMembers.add(member.toMap());
        userData['members'] = existingMembers;
        userData['updatedAt'] = now.toIso8601String();

        tx.set(topGoalRef, userData, SetOptions(merge: true));
        tx.set(userGoalRef, userData, SetOptions(merge: true));
        tx.set(acceptorGoalRef, userData, SetOptions(merge: true));
      } else {
        // Goal doc didn't exist at either top-level or inviter's path: create it
        final newGoalData = {
          'id': invite.goalId,
          'ownerId': invite.inviterUid,
          'title': invite.goalTitle,
          'details': '',
          'kind': 'goal',
          'startsAt': now.toIso8601String(),
          'dueAt': now.toIso8601String(),
          'category': '',
          'status': 'notStarted',
          'checkIns': [],
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'memberIds': [invite.inviterUid, acceptorUid],
          'members': [
            {
              'uid': invite.inviterUid,
              'email': invite.inviterEmail,
              'displayName': invite.inviterName,
              'role': 'owner',
              'joinedAt': invite.createdAt.toIso8601String(),
            },
            member.toMap(),
          ],
        };
        tx.set(topGoalRef, newGoalData);
        tx.set(userGoalRef, newGoalData);
        tx.set(acceptorGoalRef, newGoalData);
      }
    });
  }

  @override
  Future<void> declineInvite(String inviteId) async {
    await _invitesCol.doc(inviteId).update({
      'status': GoalInviteStatus.declined.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<GoalInvite>> fetchGoalPendingInvites(String goalId) async {
    final snapshot = await _invitesCol
        .where('goalId', isEqualTo: goalId)
        .where('status', isEqualTo: GoalInviteStatus.pending.name)
        .get();

    final list = snapshot.docs
        .map((doc) => GoalInvite.fromMap(doc.id, doc.data()))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> cancelInvite(String inviteId) async {
    await _invitesCol.doc(inviteId).delete();
  }
}
