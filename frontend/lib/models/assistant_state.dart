import 'package:flutter/foundation.dart';

export 'backend_config.dart';
export 'chat_message.dart';
export 'frontend_shortcuts.dart';

/// Represents the primary operational state of the Galaxy AI assistant.
enum AssistantState {
    disconnected,
    connecting,
    listening,
    thinking,
    speaking,
    error;

    /// Alias for the default ready/listening state.
    static const AssistantState idle = AssistantState.listening;

    String get displayLabel {
        switch (this) {
            case AssistantState.disconnected:
                return 'Disconnected';
            case AssistantState.connecting:
                return 'Connecting';
            case AssistantState.listening:
                return 'Listening';
            case AssistantState.thinking:
                return 'Thinking';
            case AssistantState.speaking:
                return 'Speaking';
            case AssistantState.error:
                return 'Unavailable';
        }
    }

    String get subtitleHint {
        switch (this) {
            case AssistantState.disconnected:
                return 'Galaxy AI backend server (port 8000) is offline';
            case AssistantState.connecting:
                return 'Connecting to Galaxy AI server...';
            case AssistantState.listening:
                return 'Speak naturally or type in the left chat panel';
            case AssistantState.thinking:
                return 'Galaxy AI is reasoning...';
            case AssistantState.speaking:
                return 'Press Esc or click orb to interrupt';
            case AssistantState.error:
                return 'Agent request encountered an error';
        }
    }
}

/// Represents the transport connection status to the Python FastAPI backend.
enum ConnectionStatus {
    offline,
    connecting,
    connected;

    String get label {
        switch (this) {
            case ConnectionStatus.offline:
                return 'Offline';
            case ConnectionStatus.connecting:
                return 'Connecting';
            case ConnectionStatus.connected:
                return 'Connected';
        }
    }
}

/// Optional subtle tool execution state displayed during agent reasoning.
@immutable
class ToolActivity {
    final String toolId;
    final String statusText;
    final bool isActive;

    const ToolActivity({
        required this.toolId,
        required this.statusText,
        this.isActive = true,
    });
}

/// Categorized frontend/transport error model for clean UI presentation.
enum AssistantErrorType {
    backendUnavailable,
    connectionLost,
    microphoneUnavailable,
    audioInitializationFailure,
    requestFailure,
    timeout,
    unexpectedResponse,
}

@immutable
class AssistantError {
    final AssistantErrorType type;
    final String userMessage;
    final bool canRetry;

    const AssistantError({
        required this.type,
        required this.userMessage,
        this.canRetry = true,
    });
}

/// Represents the backend LLM provider & model configuration from `/settings/*`.
@immutable
class AgentSettingsSnapshot {
    final List<String> availableProviders;
    final List<String> availableModels;
    final String? activeProvider;
    final double temperature;

    const AgentSettingsSnapshot({
        this.availableProviders = const [],
        this.availableModels = const [],
        this.activeProvider,
        this.temperature = 0.2,
    });

    AgentSettingsSnapshot copyWith({
        List<String>? availableProviders,
        List<String>? availableModels,
        String? activeProvider,
        double? temperature,
    }) {
        return AgentSettingsSnapshot(
            availableProviders: availableProviders ?? this.availableProviders,
            availableModels: availableModels ?? this.availableModels,
            activeProvider: activeProvider ?? this.activeProvider,
            temperature: temperature ?? this.temperature,
        );
    }
}
