import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

enum ActionType { edit, delete }

class ActionButton extends StatelessWidget {
  final ActionType actionType;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.actionType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String label;
    final bool isDestructive;

    switch (actionType) {
      case ActionType.edit:
        icon = Icons.edit_outlined;
        label = 'Edit';
        isDestructive = false;
        break;
      case ActionType.delete:
        icon = Icons.delete_outline;
        label = 'Delete';
        isDestructive = true;
        break;
    }

    final textColor = isDestructive ? Colors.red : AppColors.text;
    const backgroundColor = AppColors.cardBackground;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionsPanel extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActionsPanel({
    super.key,
    required this.onDismiss,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButton(
                actionType: ActionType.edit,
                onTap: () {
                  onDismiss();
                  onEdit();
                },
              ),
              const SizedBox(height: 16),
              ActionButton(
                actionType: ActionType.delete,
                onTap: () {
                  onDismiss();
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
