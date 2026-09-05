import 'package:flutter/material.dart';

/// Movable title bar for Settings floating window with drag handlers and window controls.
class SettingsTitleBar extends StatelessWidget {
    final bool isMaximized;
    final VoidCallback onToggleMaximize;
    final VoidCallback onClose;
    final GestureDragUpdateCallback? onPanUpdate;

    const SettingsTitleBar({
        super.key,
        required this.isMaximized,
        required this.onToggleMaximize,
        required this.onClose,
        this.onPanUpdate,
    });

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onPanUpdate: isMaximized ? null : onPanUpdate,
            child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                    ),
                    border: Border(
                        bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                    ),
                ),
                child: Row(
                    children: [
                        // Gear Icon with Neon Glow
                        Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                                Icons.settings_suggest_rounded,
                                size: 16,
                                color: Color(0xFFA855F7),
                            ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                            'Galaxy AI Settings & Configuration',
                            style: TextStyle(
                                color: Color(0xFFF1F5F9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                            ),
                        ),
                        const Spacer(),
                        // Move hint badge
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                                'Movable & Resizable',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                            ),
                        ),
                        const SizedBox(width: 8),
                        // Maximize/Restore button
                        IconButton(
                            icon: Icon(
                                isMaximized ? Icons.filter_none_rounded : Icons.crop_square_rounded,
                                size: 15,
                            ),
                            color: const Color(0xFF94A3B8),
                            splashRadius: 14,
                            onPressed: onToggleMaximize,
                        ),
                        // Close button
                        IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            color: const Color(0xFFEF4444),
                            splashRadius: 14,
                            onPressed: onClose,
                        ),
                    ],
                ),
            ),
        );
    }
}
