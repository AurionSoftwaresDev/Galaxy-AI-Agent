import 'package:flutter/material.dart';

/// Dedicated left-bottom button for launching Settings & Agent Configurations.
class SidebarSettingsButton extends StatelessWidget {
    final bool isExpanded;
    final bool isSettingsOpen;
    final VoidCallback onOpenSettings;

    const SidebarSettingsButton({
        super.key,
        required this.isExpanded,
        required this.isSettingsOpen,
        required this.onOpenSettings,
    });

    @override
    Widget build(BuildContext context) {
        if (!isExpanded) {
            return Tooltip(
                message: 'Settings & Configurations (⌘ ,)',
                waitDuration: const Duration(milliseconds: 300),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Material(
                        color: isSettingsOpen
                            ? const Color(0xFFA855F7).withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                            onTap: onOpenSettings,
                            borderRadius: BorderRadius.circular(10),
                            hoverColor: const Color(0xFFA855F7).withValues(alpha: 0.12),
                            child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSettingsOpen
                                        ? Border.all(color: const Color(0xFFA855F7), width: 1.2)
                                        : null,
                                ),
                                child: Icon(
                                    isSettingsOpen ? Icons.settings : Icons.settings_outlined,
                                    size: 21,
                                    color: isSettingsOpen ? const Color(0xFFA855F7) : const Color(0xFF94A3B8),
                                ),
                            ),
                        ),
                    ),
                ),
            );
        }

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Material(
                color: isSettingsOpen
                    ? const Color(0xFFA855F7).withValues(alpha: 0.16)
                    : const Color(0xFF0F172A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                    onTap: onOpenSettings,
                    borderRadius: BorderRadius.circular(10),
                    hoverColor: const Color(0xFFA855F7).withValues(alpha: 0.14),
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isSettingsOpen
                                    ? const Color(0xFFA855F7)
                                    : const Color(0xFF1E293B),
                                width: isSettingsOpen ? 1.2 : 0.8,
                            ),
                        ),
                        child: Row(
                            children: [
                                Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFA855F7).withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                                            width: 0.8,
                                        ),
                                    ),
                                    child: Icon(
                                        isSettingsOpen ? Icons.settings : Icons.settings_outlined,
                                        size: 17,
                                        color: const Color(0xFFA855F7),
                                    ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                'Settings & Config',
                                                style: TextStyle(
                                                    color: Color(0xFFF1F5F9),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                            Text(
                                                'Profile, Models & Themes',
                                                style: TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 10,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                    ),
                                ),
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF334155), width: 0.6),
                                    ),
                                    child: const Text(
                                        '⌘ ,',
                                        style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
