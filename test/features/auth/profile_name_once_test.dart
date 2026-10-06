import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/core/storage/memory_storage.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/features/auth/models/app_user.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/fake_user_profile_service.dart';

void main() {
  group('ProfileController — name is saved once per account', () {
    late FakeAuthService auth;
    late FakeUserProfileService profiles;
    late ProfileController controller;

    setUp(() {
      auth = FakeAuthService()
        ..user = const AppUser(
          uid: 'uid-1',
          isAnonymous: false,
          email: 'a@test.com',
        );
      profiles = FakeUserProfileService();
      controller = ProfileController(MemoryStorage(), auth, profiles);
    });

    test('asks for a name when the account has none', () async {
      await controller.syncFromRemote();
      expect(controller.needsName, isTrue);
      expect(controller.email, 'a@test.com');
    });

    test('first save is stored and later saves are ignored', () async {
      await controller.syncFromRemote();
      await controller.saveName('Youssef');
      expect(controller.displayName, 'Youssef');
      expect(controller.needsName, isFalse);

      await controller.saveName('Other');
      expect(controller.displayName, 'Youssef');
      expect(await profiles.readDisplayName('uid-1'), 'Youssef');
    });

    test('switching accounts replaces the cached name', () async {
      await profiles.claimDisplayName('uid-1', 'Youssef');
      await controller.syncFromRemote();
      expect(controller.displayName, 'Youssef');

      auth.user = const AppUser(uid: 'uid-2', isAnonymous: false);
      await controller.syncFromRemote();
      expect(controller.displayName, isEmpty);
      expect(controller.needsName, isTrue);
    });

    test('clear wipes the name on sign-out', () async {
      await profiles.claimDisplayName('uid-1', 'Youssef');
      await controller.syncFromRemote();
      await controller.clear();
      expect(controller.displayName, isEmpty);
      expect(controller.isSynced, isFalse);
    });
  });
}
