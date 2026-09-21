import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/app/app_navigator.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_icons.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/features/finance/controllers/finance_controller.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

enum _AuthMode { signIn, signUp, resetPassword }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _AuthMode _mode = _AuthMode.signIn;
  final _nameController = TextEditingController();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSuccess() async {
    await Get.find<ProfileController>().syncFromRemote();
    await Get.find<GoalsController>().load();
    if (Get.isRegistered<FinanceController>()) {
      await Get.find<FinanceController>().load();
    }
    AppNavigator.offAllHome();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 700;

    return Scaffold(
      backgroundColor: colors.background,
      body: GetBuilder<AuthController>(
        id: 'auth',
        builder: (auth) {
          return Stack(
            children: [
              // Background gradient decoration
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.secondary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 440 : double.infinity,
                    ),
                    child: _buildCard(context, auth, colors),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    AuthController auth,
    AppPalette colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(colors),
          const SizedBox(height: AppSpacing.xl),
          _buildSocialButtons(auth, colors),
          const SizedBox(height: AppSpacing.lg),
          _buildDivider(colors),
          const SizedBox(height: AppSpacing.lg),
          _buildForm(auth, colors),
        ],
      ),
    );
  }

  Widget _buildHeader(AppPalette colors) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            Icons.track_changes_rounded,
            size: AppIconSize.xl,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          LocaleKeys.appName.tr,
          style: AppTextStyles.h4(colors).copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          switch (_mode) {
            _AuthMode.signIn => LocaleKeys.signInSubtitle.tr,
            _AuthMode.signUp => LocaleKeys.signUpSubtitle.tr,
            _AuthMode.resetPassword => LocaleKeys.resetPasswordSubtitle.tr,
          },
          style: AppTextStyles.body2(colors).copyWith(
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialButtons(AuthController auth, AppPalette colors) {
    if (_mode == _AuthMode.resetPassword) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GoogleButton(
          busy: auth.isBusy,
          onTap: () async {
            final ok = await auth.continueWithGoogle();
            if (ok && mounted) await _onSuccess();
          },
        ),
        if (_showApple) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: LocaleKeys.continueApple.tr,
            variant: AppButtonVariant.secondary,
            onPressed:
                auth.isBusy
                    ? null
                    : () async {
                      final ok = await auth.continueWithApple();
                      if (ok && mounted) await _onSuccess();
                    },
          ),
        ],
      ],
    );
  }

  Widget _buildDivider(AppPalette colors) {
    if (_mode == _AuthMode.resetPassword) return const SizedBox.shrink();
    return Row(
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
    );
  }

  Widget _buildForm(AuthController auth, AppPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_mode == _AuthMode.signUp) ...[
          AppTextField(
            controller: _nameController,
            label: LocaleKeys.fullName.tr,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppTextField(
          controller: _emailController,
          label: LocaleKeys.email.tr,
          keyboardType: TextInputType.emailAddress,
          textInputAction:
              _mode == _AuthMode.resetPassword
                  ? TextInputAction.done
                  : TextInputAction.next,
        ),
        if (_mode != _AuthMode.resetPassword) ...[
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.error.withValues(alpha: 0.2)),
            ),
            child: Text(
              _localError ?? auth.errorMessage!,
              style: AppTextStyles.caption(colors).copyWith(
                color: colors.error,
              ),
            ),
          ),
        ],
        if (auth.infoMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              auth.infoMessage!,
              style: AppTextStyles.caption(colors).copyWith(
                color: colors.success,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: switch (_mode) {
            _AuthMode.signIn => LocaleKeys.signIn.tr,
            _AuthMode.signUp => LocaleKeys.signUp.tr,
            _AuthMode.resetPassword => LocaleKeys.sendResetLink.tr,
          },
          onPressed: auth.isBusy ? null : () => _submit(auth),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildModeLinks(colors),
      ],
    );
  }

  Widget _buildModeLinks(AppPalette colors) {
    return switch (_mode) {
      _AuthMode.signIn => Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton(
            onPressed:
                () => setState(() {
                  _mode = _AuthMode.resetPassword;
                  _localError = null;
                }),
            child: Text(
              LocaleKeys.forgotPassword.tr,
              style: AppTextStyles.caption(colors).copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed:
                () => setState(() {
                  _mode = _AuthMode.signUp;
                  _localError = null;
                }),
            child: Text(
              LocaleKeys.signUp.tr,
              style: AppTextStyles.caption(colors).copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      _AuthMode.signUp => Center(
        child: TextButton(
          onPressed:
              () => setState(() {
                _mode = _AuthMode.signIn;
                _localError = null;
              }),
          child: Text(
            LocaleKeys.alreadyHaveAccount.tr,
            style: AppTextStyles.caption(colors).copyWith(
              color: colors.primary,
            ),
          ),
        ),
      ),
      _AuthMode.resetPassword => Center(
        child: TextButton(
          onPressed:
              () => setState(() {
                _mode = _AuthMode.signIn;
                _localError = null;
              }),
          child: Text(
            LocaleKeys.signIn.tr,
            style: AppTextStyles.caption(colors).copyWith(
              color: colors.primary,
            ),
          ),
        ),
      ),
    };
  }

  Future<void> _submit(AuthController auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_mode == _AuthMode.signUp && name.isEmpty) {
      setState(() => _localError = LocaleKeys.nameRequired.tr);
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _localError = LocaleKeys.invalidEmail.tr);
      return;
    }

    if (_mode != _AuthMode.resetPassword && password.length < 6) {
      setState(() => _localError = LocaleKeys.passwordTooShort.tr);
      return;
    }

    setState(() => _localError = null);

    bool ok = false;
    if (_mode == _AuthMode.signIn) {
      ok = await auth.signInWithEmail(email, password);
    } else if (_mode == _AuthMode.signUp) {
      ok = await auth.registerWithEmail(email, password, displayName: name);
    } else {
      ok = await auth.sendPasswordReset(email);
    }

    if (!mounted) return;
    if (ok && _mode != _AuthMode.resetPassword) {
      await _onSuccess();
    }
  }
}

// ---------------------------------------------------------------------------
// Google button with branded style
// ---------------------------------------------------------------------------

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: colors.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google "G" icon via text
              const Text(
                'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4285F4),
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                LocaleKeys.continueGoogle.tr,
                style: AppTextStyles.body2(colors).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
