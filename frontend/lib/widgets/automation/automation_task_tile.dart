import 'package:flutter/material.dart';
import '../../models/assistant_state.dart';
import '../../models/automation_task.dart';

/// Individual automation task tile rendered in either collapsed (icon only) or expanded layout.
class AutomationTaskTile extends StatelessWidget {
    final AutomationTask task;
    final bool isExpanded;
    final bool isCurrentlyRunning;
    final bool isBusy;
    final void Function(AutomationTask) onExecuteTask;

    const AutomationTaskTile({
        super.key,
        required this.task,
        required this.isExpanded,
        required this.isCurrentlyRunning,
        required this.isBusy,
        required this.onExecuteTask,
    });

    @override
    Widget build(BuildContext context) {
        if (!isExpanded) {
            return Tooltip(
                message: '${task.title}\n${task.description}',
                waitDuration: const Duration(milliseconds: 300),
                child: Material(
                    color: isCurrentlyRunning ? task.accentColor.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                        onTap: isBusy ? null : () => onExecuteTask(task),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            child: isCurrentlyRunning
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(task.accentColor),
                                    ),
                                )
                                : Icon(
                                    task.icon,
                                    size: 20,
                                    color: task.accentColor,
                                ),
                        ),
                    ),
                ),
            );
        }

        return Material(
            color: isCurrentlyRunning ? task.accentColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
                onTap: isBusy ? null : () => onExecuteTask(task),
                borderRadius: BorderRadius.circular(10),
                hoverColor: task.accentColor.withValues(alpha: 0.08),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                        children: [
                            Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: task.accentColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: isCurrentlyRunning
                                            ? task.accentColor
                                            : task.accentColor.withValues(alpha: 0.3),
                                        width: isCurrentlyRunning ? 1.2 : 0.8,
                                    ),
                                ),
                                child: isCurrentlyRunning
                                    ? Center(
                                        child: SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(task.accentColor),
                                            ),
                                        ),
                                    )
                                    : Icon(
                                        task.icon,
                                        size: 16,
                                        color: task.accentColor,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            task.title,
                                            style: TextStyle(
                                                color: isCurrentlyRunning ? const Color(0xFFFFFFFF) : const Color(0xFFE2E8F0),
                                                fontSize: 12,
                                                fontWeight: isCurrentlyRunning ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                        ),
                                        Text(
                                            isCurrentlyRunning ? 'Executing...' : task.description,
                                            style: TextStyle(
                                                color: isCurrentlyRunning ? task.accentColor : const Color(0xFF64748B),
                                                fontSize: 10,
                                                fontWeight: isCurrentlyRunning ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                ),
                            ),
                            Icon(
                                isCurrentlyRunning ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
                                size: 14,
                                color: isCurrentlyRunning ? task.accentColor : const Color(0xFF475569),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
