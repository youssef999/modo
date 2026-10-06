import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/controllers/theme_controller.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_gradients.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

class NameIntroDialog extends StatefulWidget {
  const NameIntroDialog({super.key});

  static bool _open = false;

  static Future<void> showIfNeeded() async {
    if (_open || !Get.isRegistered<ProfileController>()) return;
    final profile = Get.find<ProfileController>();
    if (!profile.isSynced) await profile.syncFromRemote();
    if (!profile.needsName) return;
    final palette = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>().palette
        : AppColors.light;
    _open = true;
    try {
      await Get.dialog<void>(
        const PopScope(canPop: false, child: NameIntroDialog()),
        barrierDismissible: false,
        barrierColor: palette.textPrimary.withValues(alpha: 0.45),
      );
    } finally {
      _open = false;
    }
  }

  @override
  State<NameIntroDialog> createState() => _NameIntroDialogState();
}

class _NameIntroDialogState extends State<NameIntroDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Dialog(
      backgroundColor: colors.card.withValues(alpha: 0),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: colors.border.withValues(alpha: 0.7)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: AppSpacing.sm,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryHero(colors),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppSpacing.xxl + AppSpacing.md,
                        height: AppSpacing.xxl + AppSpacing.md,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.primaryHero(colors),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: AppSpacing.lg,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: colors.onPrimary,
                          size: AppIconSize.xl,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        LocaleKeys.askNameTitle.tr,
                        style: AppTextStyles.h4(colors),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        LocaleKeys.askNameSubtitle.tr,
                        style: AppTextStyles.body2(colors),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        LocaleKeys.askNameLocked.tr,
                        style: AppTextStyles.caption(colors),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _controller,
                        label: LocaleKeys.askNameHint.tr,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GetBuilder<ProfileController>(
                        id: 'profile',
                        builder: (profile) => AppButton(
                          label: LocaleKeys.saveName.tr,
                          onPressed: profile.isSaving ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final profile = Get.find<ProfileController>();
    await profile.saveName(name);
    if (profile.hasName) _close();
  }

  void _close() {
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }
}
