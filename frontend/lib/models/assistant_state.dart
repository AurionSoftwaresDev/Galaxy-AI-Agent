import 'package:flutter/material.dart';

/// Strongly typed state of the Galaxy AI assistant.
///
/// Dictates UI visuals, animations, microphone status, neon colors, and particle swarm behavior.
enum AssistantState {
    /// Agent is ready and waiting for user voice or text input.
    idle,

    /// Microphone active, capturing and streaming user speech.
    listening,

    /// LLM/agent is analyzing, retrieving memory, and formulating reasoning chains.
    thinking,

    /// Agent is actively executing an external tool or automation script.
    toolExecution,

    /// Agent is streaming and generating synthesis tokens.
    generating,

    /// Assistant is playing synthesized speech audio back to the user.
    speaking,

    /// User or system interrupted speech playback.
    interrupted,

    /// Establishing connection or handshake with FastAPI backend.
    connecting,

    /// Backend is unreachable or network connection dropped.
    disconnected,

    /// An unrecoverable network or audio error occurred.
    error;

    /// User-facing human-readable state label.
    String get displayName {
        switch (this) {
            case AssistantState.idle:
                return 'Ready';
            case AssistantState.listening:
                return 'Listening...';
            case AssistantState.thinking:
                return 'Thinking...';
            case AssistantState.toolExecution:
                return 'Executing Tool...';
            case AssistantState.generating:
                return 'Generating Response...';
            case AssistantState.speaking:
                return 'Speaking...';
            case AssistantState.interrupted:
                return 'Interrupted';
            case AssistantState.connecting:
                return 'Connecting...';
            case AssistantState.disconnected:
                return 'Disconnected';
            case AssistantState.error:
                return 'Connection Error';
        }
    }

    /// Primary neon accent color for this state.
    Color get neonColor {
        switch (this) {
            case AssistantState.idle:
                return const Color(0xFF6366F1); // Indigo Neon
            case AssistantState.listening:
                return const Color(0xFF06B6D4); // Cyan Neon
            case AssistantState.thinking:
                return const Color(0xFFA855F7); // Purple Neon
            case AssistantState.toolExecution:
                return const Color(0xFFF59E0B); // Amber / Gold Neon
            case AssistantState.generating:
                return const Color(0xFF3B82F6); // Electric Blue
            case AssistantState.speaking:
                return const Color(0xFF10B981); // Emerald Mint Neon
            case AssistantState.interrupted:
                return const Color(0xFFEC4899); // Hot Pink Neon
            case AssistantState.connecting:
                return const Color(0xFF0284C7); // Sky Blue
            case AssistantState.disconnected:
                return const Color(0xFF64748B); // Muted Slate
            case AssistantState.error:
                return const Color(0xFFEF4444); // Neon Red
        }
    }

    /// Secondary glowing hue for multi-stop gradients.
    Color get secondaryNeonColor {
        switch (this) {
            case AssistantState.idle:
                return const Color(0xFF8B5CF6);
            case AssistantState.listening:
                return const Color(0xFF3B82F6);
            case AssistantState.thinking:
                return const Color(0xFFEC4899);
            case AssistantState.toolExecution:
                return const Color(0xFFF97316);
            case AssistantState.generating:
                return const Color(0xFF06B6D4);
            case AssistantState.speaking:
                return const Color(0xFF06B6D4);
            case AssistantState.interrupted:
                return const Color(0xFFF43F5E);
            case AssistantState.connecting:
                return const Color(0xFF6366F1);
            case AssistantState.disconnected:
                return const Color(0xFF334155);
            case AssistantState.error:
                return const Color(0xFFB91C1C);
        }
    }

    /// State icon representation.
    IconData get icon {
        switch (this) {
            case AssistantState.idle:
                return Icons.radio_button_checked_rounded;
            case AssistantState.listening:
                return Icons.mic_rounded;
            case AssistantState.thinking:
                return Icons.psychology_rounded;
            case AssistantState.toolExecution:
                return Icons.terminal_rounded;
            case AssistantState.generating:
                return Icons.auto_awesome_rounded;
            case AssistantState.speaking:
                return Icons.volume_up_rounded;
            case AssistantState.interrupted:
                return Icons.pause_circle_filled_rounded;
            case AssistantState.connecting:
                return Icons.sync_rounded;
            case AssistantState.disconnected:
                return Icons.cloud_off_rounded;
            case AssistantState.error:
                return Icons.error_outline_rounded;
        }
    }

    /// Whether the assistant is currently in an active reasoning or speaking loop.
    bool get isActive =>
        this == AssistantState.listening ||
        this == AssistantState.thinking ||
        this == AssistantState.toolExecution ||
        this == AssistantState.generating ||
        this == AssistantState.speaking;

    /// Whether the microphone can be toggled on/off.
    bool get canInteract =>
        this != AssistantState.disconnected &&
        this != AssistantState.connecting;
}

/// Helper model representing backend tool execution or status notes.
class ToolStatusInfo {
    final String toolName;
    final String humanReadableMessage;
    final DateTime timestamp;

    const ToolStatusInfo({
        required this.toolName,
        required this.humanReadableMessage,
        required this.timestamp,
    });
}
