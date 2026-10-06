import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/breakpoints.dart';
import 'package:life_daily_app/features/auth/controllers/auth_controller.dart';
import 'package:life_daily_app/features/auth/controllers/profile_controller.dart';
import 'package:life_daily_app/features/home/widgets/name_intro_dialog.dart';
import 'package:life_daily_app/features/shell/pages/mobile_shell_layout.dart';
import 'package:life_daily_app/features/shell/pages/web_shell_layout.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<AuthController>().refreshAccountData();
      NameIntroDialog.showIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final layout = isDesktop
        ? const WebShellLayout()
        : const MobileShellLayout();

    return GetBuilder<ProfileController>(
      id: 'profile',
      builder: (profile) {
        if (profile.needsName) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NameIntroDialog.showIfNeeded();
          });
        }
        return layout;
      },
    );
  }
}
