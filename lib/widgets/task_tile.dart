import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../utils/constants.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.paddingLG),
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => _showDeleteDialog(context),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => _showTaskDetail(context),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMD,
            vertical: AppDimensions.paddingXS,
          ),
          child: Material(
            color: task.completed ? AppColors.completedTask : AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            elevation: task.completed
                ? AppDimensions.elevationSM / 2
                : AppDimensions.elevationSM,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Row(
                children: [
                  SizedBox(
                    width: AppDimensions.minTouchTarget,
                    height: AppDimensions.minTouchTarget,
                    child: Checkbox(
                      value: task.completed,
                      onChanged: (_) => onToggle(),
                      activeColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: const BorderSide(
                        color: AppColors.textSecondary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: task.completed
                                ? AppColors.completedText
                                : AppColors.textPrimary,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.completedText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: task.completed
                                  ? AppColors.completedText.withValues(alpha: 0.7)
                                  : AppColors.textSecondary,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor:
                                  AppColors.completedText.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('MMM d, yyyy \u2022 h:mm a')
                              .format(task.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    onPressed: onTap,
                    tooltip: AppStrings.editTask,
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                    onPressed: () async {
                      final confirmed = await _showDeleteDialog(context);
                      if (confirmed == true) onDelete();
                    },
                    tooltip: AppStrings.delete,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusLG),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        task.completed
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        color: task.completed
                            ? AppColors.success
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(width: AppDimensions.paddingSM),
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: task.completed
                                ? AppColors.completedText
                                : AppColors.textPrimary,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingSM),
                  Text(
                    'Created ${DateFormat('MMM d, yyyy \u2022 h:mm a').format(task.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const Divider(height: AppDimensions.paddingXL),
                    Text(
                      task.description,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        title: const Text(
          AppStrings.deleteConfirmTitle,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
