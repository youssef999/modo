import 'package:flutter/material.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';

extension ShellAreaStyle on ShellArea {
  String get titleKey {
    return switch (this) {
      ShellArea.goals => LocaleKeys.goalsTitle,
      ShellArea.finance => LocaleKeys.financeTitle,
      ShellArea.journal => LocaleKeys.journalTitle,
      ShellArea.work => LocaleKeys.workTitle,
    };
  }

  String get subtitleKey {
    return switch (this) {
      ShellArea.goals => LocaleKeys.goalsSubtitle,
      ShellArea.finance => LocaleKeys.financeSubtitle,
      ShellArea.journal => LocaleKeys.journalSubtitle,
      ShellArea.work => LocaleKeys.workSubtitle,
    };
  }

  IconData get icon {
    return switch (this) {
      ShellArea.goals => Icons.flag_rounded,
      ShellArea.finance => Icons.account_balance_wallet_rounded,
      ShellArea.journal => Icons.menu_book_rounded,
      ShellArea.work => Icons.work_rounded,
    };
  }

  Color accent(AppPalette colors) {
    return switch (this) {
      ShellArea.goals => colors.primary,
      ShellArea.finance => colors.success,
      ShellArea.journal => colors.secondary,
      ShellArea.work => colors.info,
    };
  }
}
