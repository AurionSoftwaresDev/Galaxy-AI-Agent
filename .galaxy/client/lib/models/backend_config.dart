import 'package:flutter/foundation.dart';

import 'assistant_state.dart';

/// Central configuration matching the FastAPI backend in `backend/startGalaxy.py`
/// and `backend/source/routers/allRoutes.py`.
@immutable
class BackendConfig {
    /// Matches `uvicorn server:agentServer --port 8000` in `startGalaxy.py`.
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

    /// `POST /server/desktop/disconnect` -> requests shutdown/termination of the desktop server process
    Uri get disconnectServerUri =>
        Uri.parse('$_normalizedBase/server/desktop/disconnect');

    /// `GET /chats/load-all` -> lists all conversations
    Uri get loadAllChatsUri => Uri.parse('$_normalizedBase/chats/load-all');

    /// `POST /chats/create` -> creates a new conversation
    Uri get createChatUri => Uri.parse('$_normalizedBase/chats/create');

    /// `POST /chats/load-chat` -> loads a specific conversation and its messages
    Uri get loadChatUri => Uri.parse('$_normalizedBase/chats/load-chat');

    /// `POST /chats/save-message` -> persists a user or assistant message to SQLite
    Uri get saveChatMessageUri => Uri.parse('$_normalizedBase/chats/save-message');

    /// `PATCH /chats/update-title` -> updates a conversation title
    Uri get updateChatTitleUri => Uri.parse('$_normalizedBase/chats/update-title');

    /// `POST /chats/delete` -> deletes a conversation from SQLite
    Uri get deleteChatUri => Uri.parse('$_normalizedBase/chats/delete');

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
