import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/app/life_daily_app.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/storage/i_storage.dart';
import 'package:life_daily_app/core/storage/memory_storage.dart';
import 'package:life_daily_app/features/auth/services/fake_auth_service.dart';
import 'package:life_daily_app/features/auth/services/fake_user_profile_service.dart';
import 'package:life_daily_app/features/auth/services/i_auth_service.dart';
import 'package:life_daily_app/features/auth/services/i_user_profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.lazyPut<IStorage>(MemoryStorage.new, fenix: true);
    Get.lazyPut<IAuthService>(FakeAuthService.new, fenix: true);
    Get.lazyPut<IUserProfileService>(FakeUserProfileService.new, fenix: true);
    AppStartBinding().dependencies();
  });

  testWidgets('home asks for name in a popup then greets', (tester) async {
    await tester.pumpWidget(const LifeDailyApp());
    await tester.pumpAndSettle();
    expect(find.text(LocaleKeys.askNameTitle.tr), findsOneWidget);
    expect(find.text(LocaleKeys.analysisTitle.tr), findsOneWidget);
    expect(find.text(LocaleKeys.goalsTitle.tr), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Sara');
    await tester.tap(find.text(LocaleKeys.saveName.tr));
    await tester.pumpAndSettle();

    expect(find.text(LocaleKeys.askNameTitle.tr), findsNothing);
    expect(
      find.text(LocaleKeys.helloName.trParams({'name': 'Sara'})),
      findsOneWidget,
    );
  });
}
