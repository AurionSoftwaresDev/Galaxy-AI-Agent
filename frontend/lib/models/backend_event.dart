import 'dart:convert';
import 'assistant_state.dart';

/// Events transmitted between Flutter Desktop frontend and Python FastAPI backend.
class BackendEvent {
    final String type;
    final Map<String, dynamic> payload;

    const BackendEvent({
        required this.type,
        this.payload = const <String, dynamic>{},
    });

    factory BackendEvent.message(String content) => BackendEvent(
      type: "message",
      payload: <String, dynamic>{
        "content": content
      }
    );

    /// Factory to parse incoming JSON WebSocket message from FastAPI backend.
    factory BackendEvent.fromJson(String rawJson) {
        try {
            final dynamic decoded = jsonDecode(rawJson);
            if (decoded is Map<String, dynamic>) {
                return BackendEvent(
                    type: decoded['type'] as String? ?? 'unknown',
                    payload: decoded['payload'] as Map<String, dynamic>? ??
                        <String, dynamic>{},
                );
            }
        } catch (_) {
            // Return raw fallback event on malformed frame
        }
        return const BackendEvent(type: 'malformed');
    }

    /// Serializes event into JSON payload for transmission to backend.
    String toJson() {
        return jsonEncode(<String, dynamic>{
            'type': type,
            'payload': payload,
            'timestamp': DateTime.now().toIso8601String(),
        });
    }

    /// Factory for user audio start event.
    factory BackendEvent.audioStart() => const BackendEvent(type: 'audio_start');

    /// Factory for user audio stop/silence detected event.
    factory BackendEvent.audioStop() => const BackendEvent(type: 'audio_stop');

    /// Factory for user interruption request (stop speaking).
    factory BackendEvent.interrupt() => const BackendEvent(type: 'interrupt');

    /// Extract assistant state if this is a state change event.
    AssistantState? parseState() {
        if (type != 'state_change') return null;
        final stateStr = payload['state'] as String?;
        switch (stateStr?.toLowerCase()) {
            case 'disconnected':
                return AssistantState.disconnected;
            case 'connecting':
                return AssistantState.connecting;
            case 'listening':
                return AssistantState.listening;
            case 'thinking':
                return AssistantState.thinking;
            case 'speaking':
                return AssistantState.speaking;
            case 'error':
                return AssistantState.error;
            default:
                return null;
        }
    }

    /// Extract tool status message if backend is executing a background tool.
    ToolStatusInfo? parseToolStatus() {
        if (type != 'tool_activity') return null;
        final toolName = payload['tool_name'] as String? ?? 'assistant_tool';
        final statusMsg = payload['status'] as String? ?? 'Processing with tool...';
        return ToolStatusInfo(
            toolName: toolName,
            humanReadableMessage: statusMsg,
            timestamp: DateTime.now(),
        );
    }
}
