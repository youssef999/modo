import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/features/shell/controllers/shell_controller.dart';
import 'package:life_daily_app/features/shell/widgets/shell_area_style.dart';
import 'package:life_daily_app/shared/widgets/layout/app_page_title.dart';

/// Title of the area currently open in the shell.
class ShellPageTitle extends StatelessWidget {
  const ShellPageTitle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<ShellController>(
      id: 'shell',
      builder: (controller) {
        final area = controller.area;
        return AppPageTitle(
          title: area.titleKey.tr,
          subtitle: area.subtitleKey.tr,
          icon: area.icon,
          accent: area.accent(colors),
          compact: compact,
        );
      },
    );
  }
}
