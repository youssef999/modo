import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/locale_controller.dart';
import 'package:life_daily_app/core/controllers/theme_controller.dart';
import 'package:life_daily_app/core/localization/app_translations.dart';
import 'package:life_daily_app/features/auth/pages/splash_page.dart';

class LifeDailyApp extends StatelessWidget {
  const LifeDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      id: 'theme',
      builder: (theme) {
        return GetMaterialApp(
          onGenerateTitle: (_) => LocaleKeys.appName.tr,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.cupertino,
          theme: theme.themeData,
          themeMode: ThemeMode.light,
          translations: AppTranslations(),
          locale: Get.find<LocaleController>().locale,
          fallbackLocale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashPage(),
        );
      },
    );
  }
}
