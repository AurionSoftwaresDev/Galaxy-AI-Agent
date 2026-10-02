import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/assistant_state.dart';

/// Reusable interactive row displaying a single frontend keyboard shortcut,
/// with status badge and quick-preset key picker when actively recording.
class ShortcutRowItem extends StatelessWidget {
    final FrontendShortcutAction action;
    final FrontendShortcutsConfig shortcuts;
    final bool isRecording;
    final VoidCallback onTap;
    final ValueChanged<LogicalKeyboardKey> onKeySelected;
    final VoidCallback onCancel;

    const ShortcutRowItem({
        super.key,
        required this.action,
        required this.shortcuts,
        required this.isRecording,
        required this.onTap,
        required this.onKeySelected,
        required this.onCancel,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                InkWell(
                    canRequestFocus: false,
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                        ),
                        decoration: BoxDecoration(
                            color: isRecording
                                ? const Color(0xFF06B6D4).withValues(alpha: 0.14)
                                : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isRecording
                                    ? const Color(0xFF22D3EE)
                                    : const Color(0xFF1E293B),
                            ),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                action.label,
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFFE2E8F0),
                                                ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                                action.description,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                        color: isRecording
                                            ? const Color(0xFF06B6D4)
                                            : const Color(0xFF0B0E17),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: isRecording
                                                ? const Color(0xFF22D3EE)
                                                : const Color(0xFF334155),
                                        ),
                                    ),
                                    child: Text(
                                        isRecording
                                            ? 'Press any key...'
                                            : shortcuts.labelFor(action),
                                        style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'monospace',
                                            color: isRecording
                                                ? const Color(0xFF07090E)
                                                : const Color(0xFF22D3EE),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
                if (isRecording) ...[
                    const SizedBox(height: 8),
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0B1320),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF22D3EE)
                                    .withValues(alpha: 0.4),
                            ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(
                                            'Press a key on your keyboard or select a preset:',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF22D3EE),
                                                fontWeight: FontWeight.w500,
                                            ),
                                        ),
                                        InkWell(
                                            canRequestFocus: false,
                                            onTap: onCancel,
                                            child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                ),
                                                child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        fontSize: 10.5,
                                                        color:
                                                            Color(0xFF94A3B8),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                        for (final key
                                            in FrontendShortcutsConfig
                                                .presetKeys)
                                            InkWell(
                                                canRequestFocus: false,
                                                onTap: () => onKeySelected(key),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFF111827),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFF334155),
                                                        ),
                                                    ),
                                                    child: Text(
                                                        FrontendShortcutsConfig
                                                            .formatKeyLabel(
                                                                key),
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            fontFamily:
                                                                'monospace',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFFF8FAFC),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ],
            ],
        );
    }
}
