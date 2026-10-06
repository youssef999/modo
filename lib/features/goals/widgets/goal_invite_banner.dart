import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_invite.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';

/// Banner that appears when the current user has pending collaboration invites.
/// Shows each invite with Accept / Decline buttons.
class GoalInviteBanner extends StatelessWidget {
  const GoalInviteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (ctrl) {
        final invites = ctrl.pendingInvites;
        if (invites.isEmpty) return const SizedBox.shrink();
        final colors = context.appPalette;
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      color: colors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      LocaleKeys.pendingInvites.tr,
                      style: AppTextStyles.body2(colors).copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${invites.length}',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...invites.map(
                (invite) => _InviteTile(invite: invite, ctrl: ctrl),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        );
      },
    );
  }
}

class _InviteTile extends StatefulWidget {
  const _InviteTile({required this.invite, required this.ctrl});

  final GoalInvite invite;
  final GoalsController ctrl;

  @override
  State<_InviteTile> createState() => _InviteTileState();
}

class _InviteTileState extends State<_InviteTile> {
  bool _isProcessing = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                  child: Text(
                    widget.invite.inviterName.isNotEmpty
                        ? widget.invite.inviterName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.inviteFrom.trParams({
                          'name': widget.invite.inviterEmail,
                        }),
                        style: AppTextStyles.caption(
                          colors,
                        ).copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        LocaleKeys.inviteToGoal.trParams({
                          'goal': widget.invite.goalTitle,
                        }),
                        style: AppTextStyles.caption(
                          colors,
                        ).copyWith(color: colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _error!,
                style: AppTextStyles.caption(
                  colors,
                ).copyWith(color: colors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: LocaleKeys.acceptInvite.tr,
                    onPressed: _isProcessing ? null : _accept,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: LocaleKeys.declineInvite.tr,
                    variant: AppButtonVariant.secondary,
                    onPressed: _isProcessing ? null : _decline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    final error = await widget.ctrl.acceptInvite(widget.invite);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isProcessing = false;
        _error = error;
      });
    }
  }

  Future<void> _decline() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    await widget.ctrl.declineInvite(widget.invite);
  }
}
