import 'package:flutter/foundation.dart';

/// Role of a participant in the left-side conversation panel.
enum ChatRole {
    user,
    assistant,
}

/// Represents a single chat message in the left-side conversation panel.
@immutable
class ChatMessage {
    final String id;
    final ChatRole role;
    final String content;
    final DateTime timestamp;
    final bool isStreaming;
    final bool isError;

    const ChatMessage({
        required this.id,
        required this.role,
        required this.content,
        required this.timestamp,
        this.isStreaming = false,
        this.isError = false,
    });

    ChatMessage copyWith({
        String? content,
        bool? isStreaming,
        bool? isError,
    }) {
        return ChatMessage(
            id: id,
            role: role,
            content: content ?? this.content,
            timestamp: timestamp,
            isStreaming: isStreaming ?? this.isStreaming,
            isError: isError ?? this.isError,
        );
    }
}
