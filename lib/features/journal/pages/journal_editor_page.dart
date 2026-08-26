import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_daily_app/core/constants/locale_keys.dart';
import 'package:life_daily_app/core/theme/app_spacing.dart';
import 'package:life_daily_app/features/journal/controllers/journal_controller.dart';
import 'package:life_daily_app/features/journal/models/journal_entry.dart';
import 'package:life_daily_app/features/journal/models/journal_folder.dart';
import 'package:life_daily_app/shared/widgets/buttons/app_button.dart';
import 'package:life_daily_app/shared/widgets/progress/week_progress_card.dart';
import 'package:life_daily_app/shared/widgets/inputs/app_text_field.dart';
import 'package:life_daily_app/shared/widgets/layout/app_scaffold.dart';

class JournalEditorPage extends StatefulWidget {
  const JournalEditorPage({
    super.key,
    this.entry,
    this.draftTitle,
    this.draftDetails,
    this.folderId,
  });

  final JournalEntry? entry;
  final String? draftTitle;
  final String? draftDetails;
  final String? folderId;

  @override
  State<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends State<JournalEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late String _folderId;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(
      text: widget.entry?.title ?? widget.draftTitle ?? '',
    );
    _body = TextEditingController(
      text: widget.entry?.body ?? widget.draftDetails ?? '',
    );
    _folderId =
        widget.entry?.folderId ?? widget.folderId ?? JournalFolder.generalId;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;
    return AppScaffold(
      title: isEdit ? LocaleKeys.editJournal.tr : LocaleKeys.addJournal.tr,
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
              controller: _body,
              label: LocaleKeys.noteDetails.tr,
              maxLines: 16,
            ),
            const SizedBox(height: AppSpacing.md),
            GetBuilder<JournalController>(
              id: 'journal',
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
    final controller = Get.find<JournalController>();
    final details = _body.text.trim();
    final entry = widget.entry;
    if (entry == null) {
      await controller.add(
        title: title,
        body: details,
        folderId: _folderId,
      );
    } else {
      await controller.edit(
        entry.copyWith(title: title, body: details, folderId: _folderId),
      );
    }
    Get.back();
  }
}
