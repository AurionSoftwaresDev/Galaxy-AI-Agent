import 'dart:async';

import '../models/assistant_state.dart';

export 'http_websocket_backend_client.dart';

/// Contract for communicating with the Galaxy AI Python FastAPI backend (`server.py`).
abstract class BackendClient {
    BackendConfig get config;
    Stream<ConnectionStatus> get connectionStatusStream;
    Stream<BackendEvent> get eventStream;
    Stream<AssistantError> get errorStream;

    /// Connects to `GET /health` and opens `WS /ws/assistant`.
    Future<void> connect();

    /// Disconnects the active WebSocket session.
    Future<void> disconnect();

    /// Updates the backend base URL and reconnects.
    Future<void> updateConfig(BackendConfig newConfig);

    /// Sends a user prompt over `WS /ws/assistant` (`{"content": prompt}`),
    /// or falls back to `POST /agent/generate` (`{"prompt": prompt}`).
    Future<void> sendPrompt(String prompt);

    /// Calls `GET /settings/avaliable-providers`.
    Future<List<String>> fetchAvailableProviders();

    /// Calls `GET /settings/avaliable-models`.
    Future<List<String>> fetchAvailableModels();

    /// Calls `PATCH /settings/change-agent-provider` with `{"provider": providerName}`.
    Future<bool> changeAgentProvider(String providerName);

    /// Calls `PATCH /settings/change-agent-temperature` with `{"temperature": temperature}`.
    Future<bool> changeAgentTemperature(double temperature);

    /// Calls `POST /server/desktop/disconnect` to kill/terminate the backend server process.
    Future<bool> disconnectDesktopServer();

    void dispose();
}
