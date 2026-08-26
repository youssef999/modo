import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/work/controllers/work_controller.dart';
import 'package:life_daily_app/features/work/models/work_folder.dart';
import 'package:life_daily_app/features/work/models/work_item.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/progress/week_progress_card.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class WorkEditorPage extends StatefulWidget {
  const WorkEditorPage({
    super.key,
    this.item,
    this.draftTitle,
    this.draftDetails,
    this.folderId,
  });

  final WorkItem? item;
  final String? draftTitle;
  final String? draftDetails;
  final String? folderId;

  @override
  State<WorkEditorPage> createState() => _WorkEditorPageState();
}

class _WorkEditorPageState extends State<WorkEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _details;
  late String _folderId;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(
      text: widget.item?.title ?? widget.draftTitle ?? '',
    );
    _details = TextEditingController(
      text: widget.item?.details ?? widget.draftDetails ?? '',
    );
    _folderId =
        widget.item?.folderId ?? widget.folderId ?? WorkFolder.generalId;
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return AppScaffold(
      title: isEdit ? LocaleKeys.editWork.tr : LocaleKeys.addWork.tr,
      bottomBar: AppButton(label: LocaleKeys.save.tr, onPressed: _save),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _title,
              label: LocaleKeys.noteTitle.tr,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _details,
              label: LocaleKeys.workDetails.tr,
              maxLines: 16,
            ),
            const SizedBox(height: AppSpacing.md),
            GetBuilder<WorkController>(
              id: 'work',
              builder: (controller) {
                return FolderChipRow(
                  labels: [
                    for (final folder in controller.folders)
                      controller.folderLabel(folder),
                  ],
                  ids: [for (final folder in controller.folders) folder.id],
                  selectedId: _folderId,
                  onSelected: (id) => setState(() => _folderId = id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final controller = Get.find<WorkController>();
    final details = _details.text.trim();
    final item = widget.item;
    if (item == null) {
      await controller.add(
        title: title,
        details: details,
        folderId: _folderId,
      );
    } else {
      await controller.edit(
        item.copyWith(
          title: title,
          details: details,
          folderId: _folderId,
        ),
      );
    }
    Get.back();
  }
}
