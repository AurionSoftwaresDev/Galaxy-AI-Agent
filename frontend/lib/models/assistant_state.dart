import 'package:flutter/foundation.dart';

/// Represents the primary operational state of the Galaxy AI assistant.
enum AssistantState {
    disconnected,
    connecting,
    listening,
    thinking,
    speaking,
    error;

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

/// Central configuration matching the FastAPI backend in `backend/startGalaxy.py`
/// and `backend/source/routers/allRoutes.py`.
@immutable
class BackendConfig {
    /// Matches `uvicorn server:agentServer --reload --port 8000` in `startGalaxy.py`.
    static const String defaultBaseUrl = 'http://127.0.0.1:8000';

    final String baseUrl;
    final Duration connectionTimeout;
    final Duration requestTimeout;

    const BackendConfig({
        this.baseUrl = defaultBaseUrl,
        this.connectionTimeout = const Duration(seconds: 6),
        this.requestTimeout = const Duration(seconds: 30),
    });

    String get _normalizedBase =>
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    /// `GET /health` -> `{"Status": 200, "Message": "AI Agent Server Health Is Good."}`
    Uri get healthUri => Uri.parse('$_normalizedBase/health');

    /// `POST /agent/generate` -> body `{"prompt": "..."}` -> `{"status": 201, "response": "..."}`
    Uri get generateUri => Uri.parse('$_normalizedBase/agent/generate');

    /// `WS /ws/assistant` -> sends `{"content": "..."}` and streams `state_change`, `text_delta`, `done`, `error`
    Uri get assistantWebSocketUri {
        final parsed = Uri.parse(_normalizedBase);
        final scheme = parsed.scheme == 'https' ? 'wss' : 'ws';
        return parsed.replace(
            scheme: scheme,
            path: '/ws/assistant',
        );
    }

    /// `GET /settings/avaliable-providers` -> `{"Avaliable Providers": [...]}`
    Uri get availableProvidersUri =>
        Uri.parse('$_normalizedBase/settings/avaliable-providers');

    /// `GET /settings/avaliable-models` -> `{"Avaliable Models": [...]}`
    Uri get availableModelsUri =>
        Uri.parse('$_normalizedBase/settings/avaliable-models');

    /// `PATCH /settings/change-agent-temperature` -> body `{"temperature": 0.2}`
    Uri get changeTemperatureUri =>
        Uri.parse('$_normalizedBase/settings/change-agent-temperature');

    /// `PATCH /settings/change-agent-provider` -> body `{"provider": "..."}`
    Uri get changeProviderUri =>
        Uri.parse('$_normalizedBase/settings/change-agent-provider');

    BackendConfig copyWith({
        String? baseUrl,
        Duration? connectionTimeout,
        Duration? requestTimeout,
    }) {
        return BackendConfig(
            baseUrl: baseUrl ?? this.baseUrl,
            connectionTimeout: connectionTimeout ?? this.connectionTimeout,
            requestTimeout: requestTimeout ?? this.requestTimeout,
        );
    }
}

/// Types of WebSocket messages emitted by `agentWebSocketController.py`.
enum BackendEventType {
    stateChange,
    textDelta,
    done,
    error,
}

/// Structured event received from `ws://127.0.0.1:8000/ws/assistant` or `POST /agent/generate`.
@immutable
class BackendEvent {
    final BackendEventType type;
    final AssistantState? assistantState;
    final String? textDelta;
    final ToolActivity? toolActivity;
    final String? errorMessage;
    final bool isCompleted;

    const BackendEvent({
        required this.type,
        this.assistantState,
        this.textDelta,
        this.toolActivity,
        this.errorMessage,
        this.isCompleted = false,
    });

    factory BackendEvent.fromWebSocketJson(Map<String, dynamic> json) {
        final rawType = (json['type'] as String?)?.toLowerCase().trim() ?? '';
        final payload = (json['payload'] is Map<String, dynamic>)
            ? (json['payload'] as Map<String, dynamic>)
            : const <String, dynamic>{};

        if (rawType == 'state_change' || rawType == 'change_state') {
            final rawState = (payload['state'] as String?)?.toLowerCase().trim() ?? '';
            if (rawState == 'thinking') {
                return const BackendEvent(
                    type: BackendEventType.stateChange,
                    assistantState: AssistantState.thinking,
                );
            }
            if (rawState == 'completed') {
                return const BackendEvent(
                    type: BackendEventType.stateChange,
                    isCompleted: true,
                );
            }
            if (rawState == 'error') {
                return const BackendEvent(
                    type: BackendEventType.stateChange,
                    assistantState: AssistantState.error,
                );
            }
            if (rawState == 'listening') {
                return const BackendEvent(
                    type: BackendEventType.stateChange,
                    assistantState: AssistantState.listening,
                );
            }
            if (rawState == 'speaking') {
                return const BackendEvent(
                    type: BackendEventType.stateChange,
                    assistantState: AssistantState.speaking,
                );
            }
        }

        if (rawType == 'text_delta') {
            final content = payload['content'] as String? ?? '';
            return BackendEvent(
                type: BackendEventType.textDelta,
                assistantState: AssistantState.speaking,
                textDelta: content,
            );
        }

        if (rawType == 'done') {
            return const BackendEvent(
                type: BackendEventType.done,
                isCompleted: true,
            );
        }

        if (rawType == 'error') {
            final message = (payload['message'] as String?) ??
                'AI Agent Failed To Generate A Response.';
            return BackendEvent(
                type: BackendEventType.error,
                assistantState: AssistantState.error,
                errorMessage: message,
            );
        }

        if (rawType == 'tool_activity' || payload.containsKey('tool_name')) {
            final toolName = (payload['tool_name'] as String?) ?? 'tool';
            return BackendEvent(
                type: BackendEventType.stateChange,
                assistantState: AssistantState.thinking,
                toolActivity: ToolActivity(
                    toolId: toolName,
                    statusText: 'Using $toolName...',
                ),
            );
        }

        return const BackendEvent(
            type: BackendEventType.stateChange,
        );
    }
}
