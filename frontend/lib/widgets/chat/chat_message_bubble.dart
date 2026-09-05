import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../models/user_profile.dart';

/// Renders a single conversation bubble (user or assistant) with reasoning chains,
/// tool badges, audio indicator, and avatar initials.
class ChatMessageBubble extends StatelessWidget {
    final ChatMessage message;
    final UserProfile userProfile;

    const ChatMessageBubble({
        super.key,
        required this.message,
        required this.userProfile,
    });

    @override
    Widget build(BuildContext context) {
        final isUser = message.role.isUser;

        return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                    if (!isUser) ...[
                        // Agent Avatar with Neon Ring
                        Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(right: 8, top: 2),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                                ),
                                boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                        blurRadius: 6,
                                    ),
                                ],
                            ),
                            child: const Icon(Icons.bolt, size: 14, color: Colors.white),
                        ),
                    ],
                    Flexible(
                        child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                                // Reasoning step if available
                                if (message.reasoning != null && message.reasoning!.isNotEmpty)
                                    Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF1E1B4B).withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                                width: 0.8,
                                            ),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                const Icon(
                                                    Icons.psychology_outlined,
                                                    size: 13,
                                                    color: Color(0xFFA855F7),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                    child: Text(
                                                        message.reasoning!,
                                                        style: const TextStyle(
                                                            color: Color(0xFFC4B5FD),
                                                            fontSize: 11,
                                                            fontStyle: FontStyle.italic,
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),

                                // Tool execution badge if tool was called
                                if (message.toolName != null)
                                    Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF0F172A),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                                width: 0.8,
                                            ),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                const Icon(Icons.terminal, size: 12, color: Color(0xFFF59E0B)),
                                                const SizedBox(width: 5),
                                                Text(
                                                    '[tool: ${message.toolName}]',
                                                    style: const TextStyle(
                                                        color: Color(0xFFFDE68A),
                                                        fontSize: 10,
                                                        fontFamily: 'monospace',
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),

                                // Main Text Bubble
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: isUser
                                            ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                                            : const Color(0xFF131B2E).withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(12),
                                            topRight: const Radius.circular(12),
                                            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                                            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                                        ),
                                        border: Border.all(
                                            color: isUser
                                                ? const Color(0xFF818CF8).withValues(alpha: 0.5)
                                                : const Color(0xFF1E293B),
                                            width: 1,
                                        ),
                                    ),
                                    child: SelectableText(
                                        message.text,
                                        style: TextStyle(
                                            color: isUser ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                                            fontSize: 13,
                                            height: 1.4,
                                        ),
                                    ),
                                ),

                                // Timestamp & Audio indicator
                                Padding(
                                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Text(
                                                _formatTime(message.timestamp),
                                                style: const TextStyle(
                                                    color: Color(0xFF475569),
                                                    fontSize: 10,
                                                ),
                                            ),
                                            if (message.hasAudio) ...[
                                                const SizedBox(width: 6),
                                                const Icon(
                                                    Icons.volume_up_outlined,
                                                    size: 11,
                                                    color: Color(0xFF10B981),
                                                ),
                                            ],
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                    if (isUser) ...[
                        // User Avatar with Initials Fallback
                        Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(left: 8, top: 2),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                    colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                                ),
                                boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                    ),
                                ],
                            ),
                            child: Center(
                                child: Text(
                                    userProfile.initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                            ),
                        ),
                    ],
                ],
            ),
        );
    }

    String _formatTime(DateTime time) {
        final h = time.hour.toString().padLeft(2, '0');
        final m = time.minute.toString().padLeft(2, '0');
        return '$h:$m';
    }
}
