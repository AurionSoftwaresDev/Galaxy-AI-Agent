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

    /// Calls `GET /chats/load-all` -> returns list of all chat sessions.
    Future<List<Map<String, dynamic>>> fetchAllChats();

    /// Calls `POST /chats/create` with `{"title": title}` -> returns created chat details.
    Future<Map<String, dynamic>?> createChat(String title);

    /// Calls `POST /chats/load-chat` with `{"chatId": chatId, "title": title}` -> returns chat details and messages.
    Future<Map<String, dynamic>?> loadChat(int chatId, String title);

    /// Calls `POST /chats/save-message` with `{"chatId": chatId, "role": role, "content": content}`.
    Future<bool> saveChatMessage(int chatId, String role, String content);

    /// Calls `PATCH /chats/update-title` with `{"chatId": chatId, "title": title}`.
    Future<bool> updateChatTitle(int chatId, String title);

    /// Calls `POST /chats/delete` with `{"chatId": chatId, "title": title}`.
    Future<bool> deleteChat(int chatId, String title);

    void dispose();
}
