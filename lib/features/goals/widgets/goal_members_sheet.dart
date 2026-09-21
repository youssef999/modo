import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_colors.dart';
import 'package:life_daily_app/core/theme/app_palette.dart';
import 'package:life_daily_app/core/theme/app_radius.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/core/theme/app_text_styles.dart';
import 'package:life_daily_app/features/goals/controllers/goals_controller.dart';
import 'package:life_daily_app/features/goals/models/goal_invite.dart';
import 'package:life_daily_app/features/goals/models/goal_member.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';

/// Bottom sheet / modal for managing team members of a goal.
class GoalMembersSheet extends StatefulWidget {
  const GoalMembersSheet({super.key, required this.goalId});

  final String goalId;

  static Future<void> show(BuildContext context, String goalId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalMembersSheet(goalId: goalId),
    );
  }

  @override
  State<GoalMembersSheet> createState() => _GoalMembersSheetState();
}

class _GoalMembersSheetState extends State<GoalMembersSheet> {
  bool _showInviteForm = false;
  final _emailController = TextEditingController();
  bool _isSending = false;
  String? _feedback;
  bool _feedbackIsError = false;

  List<GoalInvite> _pendingInvites = [];
  bool _loadingInvites = false;
  String? _cancellingInviteId;

  @override
  void initState() {
    super.initState();
    _loadPendingInvites();
  }

  Future<void> _loadPendingInvites() async {
    if (!Get.isRegistered<GoalsController>()) return;
    setState(() => _loadingInvites = true);
    final invites =
        await Get.find<GoalsController>().loadGoalPendingInvites(widget.goalId);
    if (!mounted) return;
    setState(() {
      _pendingInvites = invites;
      _loadingInvites = false;
    });
  }

  Future<void> _cancelInvite(GoalsController ctrl, GoalInvite invite) async {
    setState(() => _cancellingInviteId = invite.id);
    final error = await ctrl.cancelGoalInvite(invite.id);
    if (!mounted) return;
    setState(() {
      _cancellingInviteId = null;
      if (error == null) {
        _pendingInvites.removeWhere((i) => i.id == invite.id);
        _feedback = LocaleKeys.inviteCancelled.tr;
        _feedbackIsError = false;
      } else {
        _feedback = error;
        _feedbackIsError = true;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    return GetBuilder<GoalsController>(
      id: 'goals',
      builder: (ctrl) {
        final members = ctrl.goalMembers(widget.goalId);
        final isOwner = ctrl.isGoalOwner(widget.goalId);
        final hasAny = members.isNotEmpty || _pendingInvites.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(colors),
              _buildHeader(colors, isOwner),
              const SizedBox(height: AppSpacing.sm),
              if (!hasAny && !_loadingInvites)
                _buildEmpty(colors)
              else ...[
                if (members.isNotEmpty)
                  ...members.map((m) => _buildMemberTile(context, colors, m)),
                if (_pendingInvites.isNotEmpty)
                  _buildPendingSection(context, colors, ctrl, isOwner),
              ],
              if (_loadingInvites && !hasAny)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
              if (_feedback != null && !_showInviteForm)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    _feedback!,
                    style: AppTextStyles.caption(colors).copyWith(
                      color: _feedbackIsError ? colors.error : colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (isOwner && _showInviteForm)
                _buildInviteForm(context, colors, ctrl),
              if (isOwner && !_showInviteForm)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: AppButton(
                    label: LocaleKeys.invitePartner.tr,
                    onPressed: () => setState(() {
                      _showInviteForm = true;
                      _feedback = null;
                    }),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(AppPalette colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppPalette colors, bool isOwner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.group_outlined, color: colors.primary, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Text(LocaleKeys.teamMembers.tr, style: AppTextStyles.h6(colors)),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppPalette colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        LocaleKeys.noMembersYet.tr,
        style: AppTextStyles.body2(colors).copyWith(color: colors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    AppPalette colors,
    GoalMember member,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: _MemberAvatar(member: member, colors: colors),
      title: Text(
        member.displayName.isNotEmpty ? member.displayName : member.email,
        style: AppTextStyles.body2(colors).copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        member.email,
        style: AppTextStyles.caption(colors),
      ),
      trailing: _RoleBadge(role: member.role, colors: colors),
    );
  }

  Widget _buildInviteForm(
    BuildContext context,
    AppPalette colors,
    GoalsController ctrl,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _emailController,
            label: LocaleKeys.inviteEmailHint.tr,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          if (_feedback != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _feedback!,
              style: AppTextStyles.caption(colors).copyWith(
                color: _feedbackIsError ? colors.error : colors.success,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: LocaleKeys.sendInvite.tr,
                  onPressed: _isSending ? null : () => _sendInvite(ctrl),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () => setState(() {
                  _showInviteForm = false;
                  _feedback = null;
                  _emailController.clear();
                }),
                child: Text(
                  LocaleKeys.cancel.tr,
                  style: AppTextStyles.caption(colors)
                      .copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection(
    BuildContext context,
    AppPalette colors,
    GoalsController ctrl,
    bool isOwner,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_top_rounded, size: 16, color: colors.warning),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${LocaleKeys.sentInvitesSection.tr} (${_pendingInvites.length})',
                style: AppTextStyles.caption(colors).copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ..._pendingInvites.map(
          (invite) => _buildPendingTile(context, colors, ctrl, invite, isOwner),
        ),
      ],
    );
  }

  Widget _buildPendingTile(
    BuildContext context,
    AppPalette colors,
    GoalsController ctrl,
    GoalInvite invite,
    bool isOwner,
  ) {
    final isCancelling = _cancellingInviteId == invite.id;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 2,
      ),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: colors.warning.withValues(alpha: 0.15),
        child: Icon(Icons.mail_outline_rounded, size: 18, color: colors.warning),
      ),
      title: Text(
        invite.inviteeEmail,
        style: AppTextStyles.body2(colors).copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, size: 11, color: colors.warning),
                  const SizedBox(width: 3),
                  Text(
                    LocaleKeys.pendingInviteBadge.tr,
                    style: TextStyle(
                      color: colors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              LocaleKeys.rolePartner.tr,
              style: AppTextStyles.caption(colors).copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      trailing: isOwner
          ? (isCancelling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  tooltip: LocaleKeys.cancelInvite.tr,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  onPressed: () => _cancelInvite(ctrl, invite),
                ))
          : null,
    );
  }

  Future<void> _sendInvite(GoalsController ctrl) async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _feedback = LocaleKeys.invalidEmail.tr;
        _feedbackIsError = true;
      });
      return;
    }
    setState(() {
      _isSending = true;
      _feedback = null;
    });
    final error = await ctrl.invitePartner(widget.goalId, email);
    if (!mounted) return;
    if (error == null) {
      await _loadPendingInvites();
    }
    setState(() {
      _isSending = false;
      if (error == null) {
        _feedback = LocaleKeys.inviteSent.tr;
        _feedbackIsError = false;
        _emailController.clear();
        _showInviteForm = false;
      } else {
        _feedback = error;
        _feedbackIsError = true;
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.colors});

  final GoalMember member;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: member.isOwner
          ? colors.primary.withValues(alpha: 0.15)
          : colors.secondary.withValues(alpha: 0.15),
      child: Text(
        member.initials,
        style: TextStyle(
          color: member.isOwner ? colors.primary : colors.secondary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.colors});

  final GoalMemberRole role;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) {
    final isOwner = role == GoalMemberRole.owner;
    final label = isOwner ? LocaleKeys.roleOwner.tr : LocaleKeys.rolePartner.tr;
    final color = isOwner ? colors.primary : colors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Reusable assignee avatar chip shown on task tiles.
class AssigneeAvatar extends StatelessWidget {
  const AssigneeAvatar({
    super.key,
    required this.initials,
    this.size = 24,
    this.color,
  });

  final String initials;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final bg = (color ?? colors.secondary).withValues(alpha: 0.18);
    final fg = color ?? colors.secondary;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      child: Text(
        initials,
        style: TextStyle(
          color: fg,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
