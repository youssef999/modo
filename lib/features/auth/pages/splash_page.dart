import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final controller = Get.find<AuthController>();
    final ok = await controller.bootstrap();
    if (!mounted) return;
    if (ok) {
      await Get.find<ProfileController>().syncFromRemote();
      await Get.find<GoalsController>().load();
      if (Get.isRegistered<FinanceController>()) {
        await Get.find<FinanceController>().load();
      }
      if (!mounted) return;
      AppNavigator.offAllHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<AuthController>(
      id: 'auth',
      builder: (controller) {
        return Scaffold(
          backgroundColor: colors.background,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: controller.errorMessage == null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: AppSpacing.xl,
                          height: AppSpacing.xl,
                          child: CircularProgressIndicator(
                            color: colors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          LocaleKeys.preparingSpace.tr,
                          style: AppTextStyles.body2(colors),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.errorMessage!,
                          style: AppTextStyles.body2(colors),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: LocaleKeys.retry.tr,
                          onPressed: _start,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
