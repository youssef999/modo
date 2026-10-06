import 'package:flutter_test/flutter_test.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/models/app_user.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/fake_user_profile_service.dart';

void main() {
  group('AuthController — Mandatory Auth Gate', () {
    late AuthController controller;
    late FakeAuthService fakeAuth;
    late FakeUserProfileService fakeProfiles;

    setUp(() {
      fakeAuth = FakeAuthService();
      fakeProfiles = FakeUserProfileService();
      controller = AuthController(fakeAuth, fakeProfiles);
    });

    test('bootstrap returns false when no user is logged in', () async {
      fakeAuth.user = null;
      final result = await controller.bootstrap();
      expect(result, isFalse);
      expect(controller.isLoggedIn, isFalse);
      expect(controller.user, isNull);
    });

    test('bootstrap returns false for anonymous user', () async {
      fakeAuth.user = const AppUser(uid: 'anon-123', isAnonymous: true);
      final result = await controller.bootstrap();
      expect(result, isFalse);
      expect(controller.isLoggedIn, isFalse);
    });

    test('bootstrap returns true for authenticated user', () async {
      fakeAuth.user = const AppUser(
        uid: 'real-uid',
        isAnonymous: false,
        email: 'user@test.com',
      );
      final result = await controller.bootstrap();
      expect(result, isTrue);
      expect(controller.isLoggedIn, isTrue);
      expect(controller.user?.uid, equals('real-uid'));
    });

    test('signOut sets user to null', () async {
      fakeAuth.user = const AppUser(
        uid: 'real-uid',
        isAnonymous: false,
        email: 'user@test.com',
      );
      await controller.bootstrap();
      expect(controller.isLoggedIn, isTrue);
      await controller.signOut();
      expect(controller.user, isNull);
      expect(controller.isLoggedIn, isFalse);
    });

    test('signInWithEmail sets authenticated user', () async {
      fakeAuth.user = null;
      fakeAuth.nextUser = const AppUser(
        uid: 'email-uid',
        isAnonymous: false,
        email: 'test@example.com',
        hasPassword: true,
      );
      final ok = await controller.signInWithEmail(
        'test@example.com',
        'pass123',
      );
      expect(ok, isTrue);
      expect(controller.isLoggedIn, isTrue);
      expect(controller.user?.email, equals('test@example.com'));
    });
  });
}
