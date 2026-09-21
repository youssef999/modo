import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/models/app_priority.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/features/auth/models/app_user.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_category.dart';
import 'package:life_daily_app/features/goals/models/goal_invite.dart';
import 'package:life_daily_app/features/goals/models/goal_member.dart';
import 'package:life_daily_app/features/goals/models/goal_model.dart';
import 'package:life_daily_app/features/goals/models/goal_task.dart';
import 'package:life_daily_app/features/goals/repositories/i_goal_invite_repository.dart';
import 'package:life_daily_app/features/goals/repositories/i_goal_repository.dart';

// ---------------------------------------------------------------------------
// Fake implementations
// ---------------------------------------------------------------------------

class _FakeAuthService implements IAuthService {
  AppUser? _user = const AppUser(
    uid: 'owner-uid',
    isAnonymous: false,
    email: 'owner@test.com',
    displayName: 'Test Owner',
  );

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(_user);

  @override
  Future<AppUser> ensureAnonymousSession() async => _user!;
  @override
  Future<AppUser> continueWithGoogle() async => _user!;
  @override
  Future<AppUser> continueWithApple() async => _user!;
  @override
  Future<AppUser> signInWithEmail(String email, String password) async => _user!;
  @override
  Future<AppUser> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async => _user!;
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> signOut() async { _user = null; }
}

class _FakeStorage implements IStorage {
  final Map<String, dynamic> _data = {};
  @override T? read<T>(String key) => _data[key] as T?;
  @override Future<void> write(String key, dynamic value) async => _data[key] = value;
  @override Future<void> remove(String key) async => _data.remove(key);
}

class _FakeGoalRepository implements IGoalRepository {
  List<GoalModel> _goals = [];
  final List<GoalCategory> _categories = [];

  @override
  Future<List<GoalCategory>> fetchCategories(String ownerId) async => _categories;

  @override
  Future<GoalCategory> addCategory({
    required String ownerId,
    required String name,
    String iconKey = 'star',
  }) async {
    final cat = GoalCategory(
      id: 'cat-1',
      ownerId: ownerId,
      name: name,
      builtInKey: '',
      iconKey: iconKey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _categories.add(cat);
    return cat;
  }

  @override
  Future<void> updateCategory(GoalCategory category) async {}

  @override
  Future<List<GoalModel>> fetch(String ownerId) async => _goals;

  @override
  Future<GoalModel> create({
    required String ownerId,
    required String title,
    required String details,
    required GoalKind kind,
    required DateTime startsAt,
    required DateTime dueAt,
    required String category,
  }) async {
    final goal = GoalModel(
      id: 'goal-${_goals.length + 1}',
      ownerId: ownerId,
      title: title,
      details: details,
      kind: kind,
      startsAt: startsAt,
      dueAt: dueAt,
      category: category,
      status: GoalStatus.notStarted,
      checkIns: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _goals.add(goal);
    return goal;
  }

  @override
  Future<void> update(GoalModel goal) async {
    _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
  }

  @override
  Future<void> delete(String ownerId, String id) async {
    _goals.removeWhere((g) => g.id == id);
  }

  @override
  Future<void> syncAfterLogin(String ownerId) async {}
}

class _FakeInviteRepository implements IGoalInviteRepository {
  final List<GoalInvite> _invites = [];
  final List<GoalMember> _addedMembers = [];

  List<GoalMember> get addedMembers => List.unmodifiable(_addedMembers);

  @override
  Future<GoalInvite> sendInvite({
    required String goalId,
    required String goalTitle,
    required String inviterUid,
    required String inviterEmail,
    required String inviterName,
    required String inviteeEmail,
  }) async {
    final invite = GoalInvite(
      id: 'invite-${_invites.length + 1}',
      goalId: goalId,
      goalTitle: goalTitle,
      inviterUid: inviterUid,
      inviterEmail: inviterEmail,
      inviterName: inviterName,
      inviteeEmail: inviteeEmail,
      status: GoalInviteStatus.pending,
      createdAt: DateTime.now(),
    );
    _invites.add(invite);
    return invite;
  }

  @override
  Future<List<GoalInvite>> fetchPendingInvites(String inviteeEmail) async {
    return _invites
        .where((i) => i.inviteeEmail == inviteeEmail && i.isPending)
        .toList();
  }

  @override
  Future<void> acceptInvite({
    required GoalInvite invite,
    required String acceptorUid,
    required String acceptorEmail,
    required String acceptorName,
  }) async {
    final idx = _invites.indexWhere((i) => i.id == invite.id);
    if (idx >= 0) {
      _invites[idx] = _invites[idx].copyWith(status: GoalInviteStatus.accepted);
    }
    _addedMembers.add(GoalMember(
      uid: acceptorUid,
      email: acceptorEmail,
      displayName: acceptorName,
      role: GoalMemberRole.partner,
      joinedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> declineInvite(String inviteId) async {
    final idx = _invites.indexWhere((i) => i.id == inviteId);
    if (idx >= 0) {
      _invites[idx] = _invites[idx].copyWith(status: GoalInviteStatus.declined);
    }
  }

  @override
  Future<List<GoalInvite>> fetchGoalPendingInvites(String goalId) async {
    return _invites
        .where((i) => i.goalId == goalId && i.isPending)
        .toList();
  }

  @override
  Future<void> cancelInvite(String inviteId) async {
    _invites.removeWhere((i) => i.id == inviteId);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GoalMember model', () {
    test('serialization round-trip', () {
      final member = GoalMember(
        uid: 'uid-1',
        email: 'partner@test.com',
        displayName: 'Partner User',
        role: GoalMemberRole.partner,
        joinedAt: DateTime(2026, 1, 15),
      );
      final map = member.toMap();
      final restored = GoalMember.fromMap(map);
      expect(restored.uid, equals(member.uid));
      expect(restored.email, equals(member.email));
      expect(restored.role, equals(GoalMemberRole.partner));
      expect(restored.isPartner, isTrue);
      expect(restored.isOwner, isFalse);
    });

    test('initials from displayName', () {
      final member = GoalMember(
        uid: 'u',
        email: 'a@b.com',
        displayName: 'Ahmed Mohamed',
        role: GoalMemberRole.owner,
        joinedAt: DateTime.now(),
      );
      expect(member.initials, equals('AM'));
    });

    test('initials from email when no displayName', () {
      final member = GoalMember(
        uid: 'u',
        email: 'john@example.com',
        displayName: '',
        role: GoalMemberRole.partner,
        joinedAt: DateTime.now(),
      );
      expect(member.initials, equals('J'));
    });
  });

  group('GoalInvite model', () {
    test('serialization round-trip', () {
      final invite = GoalInvite(
        id: 'inv-1',
        goalId: 'goal-1',
        goalTitle: 'My Goal',
        inviterUid: 'uid-a',
        inviterEmail: 'inviter@test.com',
        inviterName: 'Inviter Name',
        inviteeEmail: 'invitee@test.com',
        status: GoalInviteStatus.pending,
        createdAt: DateTime(2026, 3, 10),
      );
      final map = invite.toMap();
      final restored = GoalInvite.fromMap('inv-1', map);
      expect(restored.id, equals('inv-1'));
      expect(restored.inviteeEmail, equals('invitee@test.com'));
      expect(restored.status, equals(GoalInviteStatus.pending));
      expect(restored.isPending, isTrue);
      expect(restored.isAccepted, isFalse);
    });
  });

  group('GoalTask — assignee fields', () {
    test('assigneeId serialization round-trip', () {
      const task = GoalTask(
        id: 't-1',
        title: 'Design the landing page',
        priority: AppPriority.high,
        assigneeId: 'partner-uid',
        assigneeEmail: 'partner@test.com',
        assigneeName: 'Partner User',
      );
      final map = task.toMap();
      final restored = GoalTask.fromMap(map);
      expect(restored.assigneeId, equals('partner-uid'));
      expect(restored.assigneeEmail, equals('partner@test.com'));
      expect(restored.assigneeName, equals('Partner User'));
    });

    test('clearAssignee removes all assignee fields', () {
      const task = GoalTask(
        id: 't-1',
        title: 'Task',
        assigneeId: 'uid',
        assigneeEmail: 'a@b.com',
        assigneeName: 'Alice',
      );
      final cleared = task.copyWith(clearAssignee: true);
      expect(cleared.assigneeId, isNull);
      expect(cleared.assigneeEmail, isNull);
      expect(cleared.assigneeName, isNull);
    });

    test('assigneeInitials from name', () {
      const task = GoalTask(
        id: 't-1',
        title: 'Task',
        assigneeName: 'Sara Ahmed',
        assigneeEmail: 's@test.com',
      );
      expect(task.assigneeInitials, equals('SA'));
    });
  });

  group('GoalModel — members fields', () {
    test('serialization round-trip with members', () {
      final member = GoalMember(
        uid: 'u-1',
        email: 'p@test.com',
        displayName: 'Partner',
        role: GoalMemberRole.partner,
        joinedAt: DateTime.now(),
      );
      final goal = GoalModel(
        id: 'g-1',
        ownerId: 'owner-uid',
        title: 'Test Goal',
        details: '',
        kind: GoalKind.once,
        startsAt: DateTime.now(),
        dueAt: DateTime.now().add(const Duration(days: 30)),
        category: 'cat',
        status: GoalStatus.notStarted,
        checkIns: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        members: [member],
        memberIds: [member.uid],
      );
      final map = goal.toMap();
      final restored = GoalModel.fromMap('g-1', map);
      expect(restored.memberIds, contains('u-1'));
      expect(restored.members, hasLength(1));
      expect(restored.members.first.email, equals('p@test.com'));
    });
  });

  group('GoalsController — team operations', () {
    late _FakeGoalRepository fakeRepo;
    late _FakeInviteRepository fakeInviteRepo;
    late _FakeAuthService fakeAuth;
    late GoalsController controller;

    setUp(() async {
      fakeRepo = _FakeGoalRepository();
      fakeInviteRepo = _FakeInviteRepository();
      fakeAuth = _FakeAuthService();
      Get.reset();
      Get.put<IAuthService>(fakeAuth);

      controller = GoalsController(
        fakeRepo,
        _FakeStorage(),
        inviteRepository: fakeInviteRepo,
      );

      // Pre-load a goal owned by test user
      final goal = await fakeRepo.create(
        ownerId: 'owner-uid',
        title: 'The Hatch Project',
        details: '',
        kind: GoalKind.once,
        startsAt: DateTime.now(),
        dueAt: DateTime.now().add(const Duration(days: 90)),
        category: 'work',
      );
      fakeRepo._goals = [goal];
      await controller.load();
    });

    tearDown(() => Get.reset());

    test('invitePartner creates a pending invite', () async {
      final goalId = controller.goals.first.id;
      final error = await controller.invitePartner(goalId, 'partner@test.com');
      expect(error, isNull);
    });

    test('loadPendingInvites fetches invites for current user', () async {
      // Simulate an invite sent to the current user
      fakeInviteRepo._invites.add(GoalInvite(
        id: 'inv-x',
        goalId: 'goal-1',
        goalTitle: 'Some Goal',
        inviterUid: 'other-uid',
        inviterEmail: 'other@test.com',
        inviterName: 'Other Person',
        inviteeEmail: 'owner@test.com',
        status: GoalInviteStatus.pending,
        createdAt: DateTime.now(),
      ));
      await controller.loadPendingInvites();
      expect(controller.pendingInvites, hasLength(1));
      expect(controller.pendingInvites.first.inviteeEmail, equals('owner@test.com'));
    });

    test('declineInvite removes from pendingInvites', () async {
      final invite = GoalInvite(
        id: 'inv-y',
        goalId: 'goal-1',
        goalTitle: 'Goal',
        inviterUid: 'x',
        inviterEmail: 'x@x.com',
        inviterName: 'X',
        inviteeEmail: 'owner@test.com',
        status: GoalInviteStatus.pending,
        createdAt: DateTime.now(),
      );
      fakeInviteRepo._invites.add(invite);
      controller.pendingInvites = [invite];
      await controller.declineInvite(invite);
      expect(controller.pendingInvites, isEmpty);
    });

    test('assignTask sets assignee on task', () async {
      final goal = controller.goals.first;
      // Add a task first
      await controller.addTask(
        goal,
        'Design homepage',
        priority: AppPriority.high,
      );
      final updatedGoal = controller.goalById(goal.id)!;
      final task = updatedGoal.tasks.first;

      final member = GoalMember(
        uid: 'partner-uid',
        email: 'partner@test.com',
        displayName: 'Partner',
        role: GoalMemberRole.partner,
        joinedAt: DateTime.now(),
      );
      await controller.assignTask(goal: updatedGoal, taskId: task.id, member: member);
      final finalGoal = controller.goalById(goal.id)!;
      final assignedTask = finalGoal.tasks.first;
      expect(assignedTask.assigneeId, equals('partner-uid'));
      expect(assignedTask.assigneeEmail, equals('partner@test.com'));
    });

    test('isGoalOwner returns true for owner', () {
      expect(controller.isGoalOwner(controller.goals.first.id), isTrue);
    });

    test('loadGoalPendingInvites returns outgoing invites for goal', () async {
      final goal = controller.goals.first;
      final invite = await fakeInviteRepo.sendInvite(
        goalId: goal.id,
        goalTitle: goal.title,
        inviterUid: 'owner-uid',
        inviterEmail: 'owner@test.com',
        inviterName: 'Owner',
        inviteeEmail: 'collaborator@test.com',
      );
      final invites = await controller.loadGoalPendingInvites(goal.id);
      expect(invites, hasLength(1));
      expect(invites.first.id, equals(invite.id));
      expect(invites.first.inviteeEmail, equals('collaborator@test.com'));

      // cancel invite
      final err = await controller.cancelGoalInvite(invite.id);
      expect(err, isNull);
      final remaining = await controller.loadGoalPendingInvites(goal.id);
      expect(remaining, isEmpty);
    });
  });
}
