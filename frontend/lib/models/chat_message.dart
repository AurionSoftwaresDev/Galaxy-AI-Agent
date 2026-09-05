/// Role of the message author.
enum MessageRole {
    user,
    assistant,
    system;

    bool get isUser => this == MessageRole.user;
    bool get isAssistant => this == MessageRole.assistant;
    bool get isSystem => this == MessageRole.system;
}

/// Status of the message generation.
enum MessageStatus {
    sending,
    thinking,
    executingTool,
    streaming,
    completed,
    interrupted,
    error;

    bool get isPending =>
        this == MessageStatus.sending ||
        this == MessageStatus.thinking ||
        this == MessageStatus.executingTool ||
        this == MessageStatus.streaming;
}

/// Represents a single conversational message in Galaxy AI's chat history.
class ChatMessage {
    final String id;
    final MessageRole role;
    final String text;
    final DateTime timestamp;
    final MessageStatus status;
    final String? reasoning;
    final String? toolName;
    final String? toolOutput;
    final bool hasAudio;

    const ChatMessage({
        required this.id,
        required this.role,
        required this.text,
        required this.timestamp,
        this.status = MessageStatus.completed,
        this.reasoning,
        this.toolName,
        this.toolOutput,
        this.hasAudio = false,
    });

    ChatMessage copyWith({
        String? id,
        MessageRole? role,
        String? text,
        DateTime? timestamp,
        MessageStatus? status,
        String? reasoning,
        String? toolName,
        String? toolOutput,
        bool? hasAudio,
    }) {
        return ChatMessage(
            id: id ?? this.id,
            role: role ?? this.role,
            text: text ?? this.text,
            timestamp: timestamp ?? this.timestamp,
            status: status ?? this.status,
            reasoning: reasoning ?? this.reasoning,
            toolName: toolName ?? this.toolName,
            toolOutput: toolOutput ?? this.toolOutput,
            hasAudio: hasAudio ?? this.hasAudio,
        );
    }
}
