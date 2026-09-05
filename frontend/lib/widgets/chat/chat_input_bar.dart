import 'package:flutter/material.dart';

/// Bottom bar for inputting text queries and toggling microphone.
class ChatInputBar extends StatelessWidget {
    final TextEditingController controller;
    final FocusNode focusNode;
    final bool isMuted;
    final VoidCallback onToggleMic;
    final VoidCallback onSend;

    const ChatInputBar({
        super.key,
        required this.controller,
        required this.focusNode,
        required this.isMuted,
        required this.onToggleMic,
        required this.onSend,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFF1E293B), width: 1),
                ),
            ),
            child: Row(
                children: [
                    // Mic toggle button
                    IconButton(
                        onPressed: onToggleMic,
                        icon: Icon(
                            isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            size: 19,
                        ),
                        color: isMuted
                            ? const Color(0xFF64748B)
                            : const Color(0xFF06B6D4),
                        splashRadius: 18,
                    ),

                    // Text Input
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF334155),
                                    width: 1,
                                ),
                            ),
                            child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13),
                                decoration: const InputDecoration(
                                    hintText: 'Ask Galaxy AI or issue command...',
                                    hintStyle: TextStyle(color: Color(0xFF475569), fontSize: 12),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                onSubmitted: (_) => onSend(),
                            ),
                        ),
                    ),

                    const SizedBox(width: 8),

                    // Send Button
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: onSend,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    ),
                                    boxShadow: [
                                        BoxShadow(
                                            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                            blurRadius: 8,
                                        ),
                                    ],
                                ),
                                child: const Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}
