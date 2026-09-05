import 'package:flutter/material.dart';

/// Top header of the conversation panel with status, message count, and action buttons.
class ChatHeader extends StatelessWidget {
    final int messageCount;
    final bool hasMessages;
    final VoidCallback onClearMessages;
    final VoidCallback onClose;

    const ChatHeader({
        super.key,
        required this.messageCount,
        required this.hasMessages,
        required this.onClearMessages,
        required this.onClose,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                ),
            ),
            child: Row(
                children: [
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                            Icons.forum_outlined,
                            size: 16,
                            color: Color(0xFFA855F7),
                        ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                    'Agent Conversation',
                                    style: TextStyle(
                                        color: Color(0xFFF1F5F9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                    ),
                                ),
                                Text(
                                    '$messageCount messages • Gemini 2.5',
                                    style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11,
                                    ),
                                ),
                            ],
                        ),
                    ),
                    Tooltip(
                        message: 'Clear Chat History',
                        child: IconButton(
                            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                            color: const Color(0xFF64748B),
                            onPressed: hasMessages ? onClearMessages : null,
                            splashRadius: 16,
                        ),
                    ),
                    Tooltip(
                        message: 'Close Panel',
                        child: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: const Color(0xFF94A3B8),
                            onPressed: onClose,
                            splashRadius: 16,
                        ),
                    ),
                ],
            ),
        );
    }
}
