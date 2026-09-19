import 'package:flutter/material.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';

extension ShellAreaStyle on ShellArea {
  String get titleKey {
    return switch (this) {
      ShellArea.goals => LocaleKeys.goalsTitle,
      ShellArea.finance => LocaleKeys.financeTitle,
    };
  }

  String get subtitleKey {
    return switch (this) {
      ShellArea.goals => LocaleKeys.goalsSubtitle,
      ShellArea.finance => LocaleKeys.financeSubtitle,
    };
  }

  IconData get icon {
    return switch (this) {
      ShellArea.goals => Icons.flag_rounded,
      ShellArea.finance => Icons.account_balance_wallet_rounded,
    };
  }

  Color accent(AppPalette colors) {
    return switch (this) {
      ShellArea.goals => colors.primary,
      ShellArea.finance => colors.success,
    };
  }
}
