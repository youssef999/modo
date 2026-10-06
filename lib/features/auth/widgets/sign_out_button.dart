import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/feedback/app_confirm_dialog.dart';

/// Confirms, signs out, and returns to the login screen. Hidden for
/// anonymous sessions, whose data would be lost on sign-out.
class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key, this.iconOnly = false});

  /// Icon button (sidebars) instead of a full-width button (drawers).
  final bool iconOnly;

  static Future<void> confirmAndSignOut() async {
    final confirmed = await AppConfirmDialog.show(
      title: LocaleKeys.signOutTitle.tr,
      message: LocaleKeys.signOutMessage.tr,
      icon: Icons.logout_rounded,
      confirmLabel: LocaleKeys.signOut.tr,
    );
    if (!confirmed) return;
    final signedOut = await Get.find<AuthController>().signOut();
    if (signedOut) AppNavigator.offAllLogin();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<AuthController>(
      id: 'auth',
      builder: (auth) {
        if (!auth.isLoggedIn) return const SizedBox.shrink();
        final onPressed = auth.isBusy ? null : confirmAndSignOut;
        if (iconOnly) {
          return IconButton(
            onPressed: onPressed,
            tooltip: LocaleKeys.signOut.tr,
            icon: Icon(
              Icons.logout_rounded,
              size: AppIconSize.md,
              color: colors.error,
            ),
          );
        }
        return AppButton(
          label: LocaleKeys.signOut.tr,
          variant: AppButtonVariant.secondary,
          onPressed: onPressed,
        );
      },
    );
  }
}
