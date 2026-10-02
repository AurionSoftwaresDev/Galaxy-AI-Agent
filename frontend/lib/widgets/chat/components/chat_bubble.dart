import 'package:flutter/material.dart';

import '../../../models/assistant_state.dart';

/// Individual message bubble in the conversation panel.
class ChatBubble extends StatelessWidget {
    final ChatMessage message;

    const ChatBubble({
        super.key,
        required this.message,
    });

    @override
    Widget build(BuildContext context) {
        final isUser = message.role == ChatRole.user;

        return Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        isUser ? 'You' : 'Galaxy AI',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isUser
                                ? const Color(0xFF64748B)
                                : const Color(0xFF22D3EE),
                        ),
                    ),
                ),
                Container(
                    constraints: const BoxConstraints(maxWidth: 295),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                    ),
                    decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF0E7490).withValues(alpha: 0.28)
                            : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: message.isError
                                ? const Color(0xFFF43F5E).withValues(alpha: 0.45)
                                : isUser
                                    ? const Color(0xFF06B6D4)
                                        .withValues(alpha: 0.35)
                                    : const Color(0xFF1E293B),
                        ),
                    ),
                    child: message.content.isEmpty && message.isStreaming
                        ? const SizedBox(
                              height: 18,
                              width: 36,
                              child: Center(
                                  child: LinearProgressIndicator(
                                      minHeight: 2,
                                      backgroundColor: Color(0xFF1E293B),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF22D3EE),
                                      ),
                                  ),
                              ),
                          )
                        : Text(
                              message.content,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.48,
                                  color: message.isError
                                      ? const Color(0xFFFDA4AF)
                                      : const Color(0xFFE2E8F0),
                              ),
                          ),
                ),
            ],
        );
    }
}
