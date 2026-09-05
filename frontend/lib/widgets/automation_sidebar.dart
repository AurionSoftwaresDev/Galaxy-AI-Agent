import 'package:flutter/material.dart';
import '../models/assistant_state.dart';
import '../models/automation_task.dart';
import 'automation/automation_task_tile.dart';
import 'automation/sidebar_header.dart';
import 'automation/sidebar_settings_button.dart';
import 'automation/sidebar_telemetry_footer.dart';

// Re-export AutomationTask and tasks for backward compatibility
export '../models/automation_task.dart';

/// Collapsible left sidebar for Galaxy AI tasks, workflow automations, and quick-access Settings.
class AutomationSidebar extends StatelessWidget {
    final bool isExpanded;
    final VoidCallback onToggleExpand;
    final void Function(AutomationTask) onExecuteTask;
    final VoidCallback onOpenSettings;
    final bool isSettingsOpen;
    final AssistantState state;
    final String? activeToolName;
    final List<AutomationTask> tasks;

    const AutomationSidebar({
        super.key,
        required this.isExpanded,
        required this.onToggleExpand,
        required this.onExecuteTask,
        required this.onOpenSettings,
        this.isSettingsOpen = false,
        required this.state,
        this.activeToolName,
        this.tasks = defaultAutomationTasks,
    });

    @override
    Widget build(BuildContext context) {
        final double width = isExpanded ? 260.0 : 64.0;

        return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: width,
            decoration: BoxDecoration(
                color: const Color(0xFF070B18).withValues(alpha: 0.95),
                border: const Border(
                    right: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1.2,
                    ),
                ),
            ),
            child: Column(
                children: [
                    // Sidebar Top Header & Toggle
                    SidebarHeader(
                        isExpanded: isExpanded,
                        onToggleExpand: onToggleExpand,
                    ),

                    const Divider(height: 1, color: Color(0xFF1E293B)),

                    // Automation Tasks List
                    Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                                final task = tasks[index];
                                final bool isCurrentlyRunning = activeToolName == task.toolName;
                                final bool isBusy = (state == AssistantState.thinking || state == AssistantState.toolExecution) && !isCurrentlyRunning;

                                return AutomationTaskTile(
                                    task: task,
                                    isExpanded: isExpanded,
                                    isCurrentlyRunning: isCurrentlyRunning,
                                    isBusy: isBusy,
                                    onExecuteTask: onExecuteTask,
                                );
                            },
                        ),
                    ),

                    const Divider(height: 1, color: Color(0xFF1E293B)),

                    // Left Bottom Section: Dedicated Settings & Configuration Entry
                    SidebarSettingsButton(
                        isExpanded: isExpanded,
                        isSettingsOpen: isSettingsOpen,
                        onOpenSettings: onOpenSettings,
                    ),

                    // Bottom Telemetry Resource Monitor
                    if (isExpanded) const SidebarTelemetryFooter(),
                ],
            ),
        );
    }
}
