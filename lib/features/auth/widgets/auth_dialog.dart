import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/widgets/sign_out_button.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/cards/app_card.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

enum AuthMode { signIn, signUp, resetPassword }

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AuthDialog(),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  AuthMode _mode = AuthMode.signIn;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _localError;

  bool get _showApple {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = (width * 0.9).clamp(320.0, 440.0);

    return Dialog(
      backgroundColor: colors.card.withValues(alpha: 0),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: GetBuilder<AuthController>(
          id: 'auth',
          builder: (auth) {
            final isBackedUp = auth.isBackedUp;

            return AppCard(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Icon(
                              Icons.cloud_outlined,
                              size: AppIconSize.lg,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.authTitle.tr,
                                style: AppTextStyles.h6(colors),
                              ),
                              Text(
                                LocaleKeys.authSubtitle.tr,
                                style: AppTextStyles.caption(colors),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            size: AppIconSize.md,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (isBackedUp) ...[
                      _buildSignedInView(context, auth),
                    ] else ...[
                      _buildAuthForm(context, auth),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignedInView(BuildContext context, AuthController auth) {
    final colors = context.appPalette;
    final email = auth.user?.email ?? auth.user?.displayName ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.success.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: colors.success,
                  size: AppIconSize.lg,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.syncStatusSynced.tr,
                        style: AppTextStyles.body1(colors).copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.success,
                        ),
                      ),
                      if (email.isNotEmpty)
                        Text(
                          LocaleKeys.signedInAs.trParams({'email': email}),
                          style: AppTextStyles.caption(colors),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: LocaleKeys.signOut.tr,
          variant: AppButtonVariant.secondary,
          onPressed: auth.isBusy
              ? null
              : () {
                  Navigator.of(context).pop();
                  SignOutButton.confirmAndSignOut();
                },
        ),
      ],
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthController auth) {
    final colors = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: LocaleKeys.continueGoogle.tr,
          onPressed: auth.isBusy
              ? null
              : () async {
                  final ok = await auth.continueWithGoogle();
                  if (ok && context.mounted) Navigator.of(context).pop();
                },
        ),
        if (_showApple) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: LocaleKeys.continueApple.tr,
            variant: AppButtonVariant.secondary,
            onPressed: auth.isBusy
                ? null
                : () async {
                    final ok = await auth.continueWithApple();
                    if (ok && context.mounted) Navigator.of(context).pop();
                  },
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: Divider(color: colors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                LocaleKeys.orDivider.tr,
                style: AppTextStyles.caption(colors),
              ),
            ),
            Expanded(child: Divider(color: colors.border)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _emailController,
          label: LocaleKeys.email.tr,
          keyboardType: TextInputType.emailAddress,
          textInputAction: _mode == AuthMode.resetPassword
              ? TextInputAction.done
              : TextInputAction.next,
        ),
        if (_mode != AuthMode.resetPassword) ...[
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _passwordController,
            label: LocaleKeys.password.tr,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(auth),
          ),
        ],
        if (_localError != null || auth.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _localError ?? auth.errorMessage!,
            style: AppTextStyles.caption(colors).copyWith(color: colors.error),
          ),
        ],
        if (auth.infoMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            auth.infoMessage!,
            style: AppTextStyles.caption(
              colors,
            ).copyWith(color: colors.success),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: switch (_mode) {
            AuthMode.signIn => LocaleKeys.signIn.tr,
            AuthMode.signUp => LocaleKeys.signUp.tr,
            AuthMode.resetPassword => LocaleKeys.sendResetLink.tr,
          },
          onPressed: auth.isBusy ? null : () => _submit(auth),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_mode == AuthMode.signIn) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _mode = AuthMode.resetPassword;
                    _localError = null;
                  });
                },
                child: Text(
                  LocaleKeys.forgotPassword.tr,
                  style: AppTextStyles.caption(
                    colors,
                  ).copyWith(color: colors.primary),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _mode = AuthMode.signUp;
                    _localError = null;
                  });
                },
                child: Text(
                  LocaleKeys.signUp.tr,
                  style: AppTextStyles.caption(colors).copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ] else if (_mode == AuthMode.signUp) ...[
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _mode = AuthMode.signIn;
                  _localError = null;
                });
              },
              child: Text(
                LocaleKeys.alreadyHaveAccount.tr,
                style: AppTextStyles.caption(
                  colors,
                ).copyWith(color: colors.primary),
              ),
            ),
          ),
        ] else ...[
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _mode = AuthMode.signIn;
                  _localError = null;
                });
              },
              child: Text(
                LocaleKeys.signIn.tr,
                style: AppTextStyles.caption(
                  colors,
                ).copyWith(color: colors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _submit(AuthController auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _localError = LocaleKeys.invalidEmail.tr);
      return;
    }

    if (_mode != AuthMode.resetPassword && password.length < 6) {
      setState(() => _localError = LocaleKeys.passwordTooShort.tr);
      return;
    }

    setState(() => _localError = null);

    bool ok = false;
    if (_mode == AuthMode.signIn) {
      ok = await auth.signInWithEmail(email, password);
    } else if (_mode == AuthMode.signUp) {
      ok = await auth.registerWithEmail(email, password);
    } else {
      ok = await auth.sendPasswordReset(email);
    }

    if (ok && _mode != AuthMode.resetPassword && mounted) {
      Navigator.of(context).pop();
    }
  }
}
