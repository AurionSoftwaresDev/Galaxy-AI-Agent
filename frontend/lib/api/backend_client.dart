import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/assistant_state.dart';

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

    void dispose();
}

/// Production HTTP + WebSocket implementation wired to the exact routes in `backend/`:
/// - `GET /health`
/// - `WS /ws/assistant`
/// - `POST /agent/generate`
/// - `GET /settings/avaliable-providers`
/// - `GET /settings/avaliable-models`
/// - `PATCH /settings/change-agent-provider`
/// - `PATCH /settings/change-agent-temperature`
class HttpWebSocketBackendClient implements BackendClient {
    BackendConfig _config;
    final http.Client _httpClient;
    WebSocketChannel? _wsChannel;
    StreamSubscription<dynamic>? _wsSubscription;

    final StreamController<ConnectionStatus> _connectionController =
        StreamController<ConnectionStatus>.broadcast();
    final StreamController<BackendEvent> _eventController =
        StreamController<BackendEvent>.broadcast();
    final StreamController<AssistantError> _errorController =
        StreamController<AssistantError>.broadcast();

    bool _isDisposed = false;
    bool _isWebSocketReady = false;

    HttpWebSocketBackendClient({
        BackendConfig config = const BackendConfig(),
        http.Client? httpClient,
    })  : _config = config,
          _httpClient = httpClient ?? http.Client();

    @override
    BackendConfig get config => _config;

    @override
    Stream<ConnectionStatus> get connectionStatusStream =>
        _connectionController.stream;

    @override
    Stream<BackendEvent> get eventStream => _eventController.stream;

    @override
    Stream<AssistantError> get errorStream => _errorController.stream;

    @override
    Future<void> connect() async {
        if (_isDisposed) return;
        await _closeWebSocket();
        _emitConnectionStatus(ConnectionStatus.connecting);

        try {
            // 1. Verify FastAPI server health via `GET /health`
            final response = await _httpClient
                .get(_config.healthUri)
                .timeout(_config.connectionTimeout);

            if (response.statusCode != 200) {
                _emitConnectionStatus(ConnectionStatus.offline);
                _emitError(
                    const AssistantError(
                        type: AssistantErrorType.backendUnavailable,
                        userMessage: 'Galaxy AI server health check failed.',
                    ),
                );
                return;
            }

            // 2. Open real-time streaming WebSocket at `WS /ws/assistant`
            _wsChannel = WebSocketChannel.connect(_config.assistantWebSocketUri);
            await _wsChannel!.ready.timeout(_config.connectionTimeout);
            _isWebSocketReady = true;

            _wsSubscription = _wsChannel!.stream.listen(
                _handleWebSocketMessage,
                onError: (_) {
                    _isWebSocketReady = false;
                    _emitConnectionStatus(ConnectionStatus.offline);
                    _emitError(
                        const AssistantError(
                            type: AssistantErrorType.connectionLost,
                            userMessage: 'WebSocket connection to Galaxy AI was lost.',
                        ),
                    );
                },
                onDone: () {
                    _isWebSocketReady = false;
                    _emitConnectionStatus(ConnectionStatus.offline);
                },
                cancelOnError: false,
            );

            _emitConnectionStatus(ConnectionStatus.connected);
            _emitEvent(
                const BackendEvent(
                    type: BackendEventType.stateChange,
                    assistantState: AssistantState.listening,
                ),
            );
        } on TimeoutException {
            _isWebSocketReady = false;
            _emitConnectionStatus(ConnectionStatus.offline);
            _emitError(
                const AssistantError(
                    type: AssistantErrorType.timeout,
                    userMessage: 'Connection to Galaxy AI server (port 8000) timed out.',
                ),
            );
        } catch (_) {
            _isWebSocketReady = false;
            _emitConnectionStatus(ConnectionStatus.offline);
            _emitError(
                AssistantError(
                    type: AssistantErrorType.backendUnavailable,
                    userMessage:
                        'Unable to reach Galaxy AI server at ${_config.baseUrl}.',
                ),
            );
        }
    }

    @override
    Future<void> disconnect() async {
        await _closeWebSocket();
        _emitConnectionStatus(ConnectionStatus.offline);
    }

    @override
    Future<void> updateConfig(BackendConfig newConfig) async {
        _config = newConfig;
        await connect();
    }

    @override
    Future<void> sendPrompt(String prompt) async {
        if (_isDisposed) return;
        final trimmed = prompt.trim();
        if (trimmed.isEmpty) return;

        // Primary path: stream via `WS /ws/assistant` (`agentWebSocketController.py`)
        if (_wsChannel != null && _isWebSocketReady) {
            try {
                final payload = jsonEncode({'content': trimmed});
                _wsChannel!.sink.add(payload);
                return;
            } catch (_) {
                _isWebSocketReady = false;
            }
        }

        // Fallback path: HTTP `POST /agent/generate` (`agentResponse.py`)
        await _sendPromptViaHttpRest(trimmed);
    }

    Future<void> _sendPromptViaHttpRest(String prompt) async {
        _emitEvent(
            const BackendEvent(
                type: BackendEventType.stateChange,
                assistantState: AssistantState.thinking,
            ),
        );

        try {
            final response = await _httpClient
                .post(
                    _config.generateUri,
                    headers: const {'Content-Type': 'application/json'},
                    body: jsonEncode({'prompt': prompt}),
                )
                .timeout(_config.requestTimeout);

            final decoded = jsonDecode(response.body);
            if (response.statusCode == 201 || response.statusCode == 200) {
                final text = (decoded is Map<String, dynamic>)
                    ? (decoded['response'] as String? ?? '')
                    : '';

                if (text.isNotEmpty) {
                    _emitEvent(
                        BackendEvent(
                            type: BackendEventType.textDelta,
                            assistantState: AssistantState.speaking,
                            textDelta: text,
                        ),
                    );
                }

                _emitEvent(
                    const BackendEvent(
                        type: BackendEventType.done,
                        isCompleted: true,
                    ),
                );
            } else {
                final errorMsg = (decoded is Map<String, dynamic>)
                    ? (decoded['Error'] as String? ??
                        'Failed to generate response.')
                    : 'Failed to generate response.';
                _emitError(
                    AssistantError(
                        type: AssistantErrorType.requestFailure,
                        userMessage: errorMsg,
                    ),
                );
            }
        } on TimeoutException {
            _emitError(
                const AssistantError(
                    type: AssistantErrorType.timeout,
                    userMessage: 'Agent generation request timed out.',
                ),
            );
        } catch (_) {
            _emitError(
                const AssistantError(
                    type: AssistantErrorType.requestFailure,
                    userMessage: 'Failed to communicate with /agent/generate.',
                ),
            );
        }
    }

    @override
    Future<List<String>> fetchAvailableProviders() async {
        if (_isDisposed) return const [];
        try {
            final response = await _httpClient
                .get(_config.availableProvidersUri)
                .timeout(_config.connectionTimeout);

            if (response.statusCode == 200) {
                final decoded = jsonDecode(response.body);
                if (decoded is Map<String, dynamic>) {
                    final list = decoded['Avaliable Providers'];
                    if (list is List) {
                        return list.whereType<String>().toList();
                    }
                }
            }
        } catch (_) {
            // Return empty list cleanly on error
        }
        return const [];
    }

    @override
    Future<List<String>> fetchAvailableModels() async {
        if (_isDisposed) return const [];
        try {
            final response = await _httpClient
                .get(_config.availableModelsUri)
                .timeout(_config.connectionTimeout);

            if (response.statusCode == 200) {
                final decoded = jsonDecode(response.body);
                if (decoded is Map<String, dynamic>) {
                    final list = decoded['Avaliable Models'];
                    if (list is List) {
                        return list.whereType<String>().toList();
                    }
                }
            }
        } catch (_) {
            // Return empty list cleanly on error
        }
        return const [];
    }

    @override
    Future<bool> changeAgentProvider(String providerName) async {
        if (_isDisposed) return false;
        try {
            final response = await _httpClient
                .patch(
                    _config.changeProviderUri,
                    headers: const {'Content-Type': 'application/json'},
                    body: jsonEncode({'provider': providerName}),
                )
                .timeout(_config.requestTimeout);

            if (response.statusCode == 200) {
                final decoded = jsonDecode(response.body);
                if (decoded is Map<String, dynamic>) {
                    return (decoded['Success'] as bool?) ?? true;
                }
                return true;
            } else {
                final decoded = jsonDecode(response.body);
                final message = (decoded is Map<String, dynamic>)
                    ? (decoded['Error'] as String? ??
                        'Provider change rejected by backend.')
                    : 'Provider change rejected by backend.';
                _emitError(
                    AssistantError(
                        type: AssistantErrorType.requestFailure,
                        userMessage: message,
                    ),
                );
            }
        } catch (_) {
            _emitError(
                const AssistantError(
                    type: AssistantErrorType.requestFailure,
                    userMessage: 'Unable to update LLM provider.',
                ),
            );
        }
        return false;
    }

    @override
    Future<bool> changeAgentTemperature(double temperature) async {
        if (_isDisposed) return false;
        try {
            final response = await _httpClient
                .patch(
                    _config.changeTemperatureUri,
                    headers: const {'Content-Type': 'application/json'},
                    body: jsonEncode({'temperature': temperature}),
                )
                .timeout(_config.requestTimeout);

            if (response.statusCode == 201 || response.statusCode == 200) {
                return true;
            }
        } catch (_) {
            _emitError(
                const AssistantError(
                    type: AssistantErrorType.requestFailure,
                    userMessage: 'Unable to update agent temperature.',
                ),
            );
        }
        return false;
    }

    void _handleWebSocketMessage(dynamic rawData) {
        if (_isDisposed || rawData is! String) return;

        try {
            final decoded = jsonDecode(rawData);
            if (decoded is! Map<String, dynamic>) {
                throw const FormatException('Expected JSON object from WebSocket');
            }
            final event = BackendEvent.fromWebSocketJson(decoded);
            _emitEvent(event);

            if (event.type == BackendEventType.error && event.errorMessage != null) {
                _emitError(
                    AssistantError(
                        type: AssistantErrorType.requestFailure,
                        userMessage: event.errorMessage!,
                    ),
                );
            }
        } catch (_) {
            _emitError(
                const AssistantError(
                    type: AssistantErrorType.unexpectedResponse,
                    userMessage: 'Received an unrecognized message from /ws/assistant.',
                ),
            );
        }
    }

    void _emitConnectionStatus(ConnectionStatus status) {
        if (!_isDisposed && !_connectionController.isClosed) {
            _connectionController.add(status);
        }
    }

    void _emitEvent(BackendEvent event) {
        if (!_isDisposed && !_eventController.isClosed) {
            _eventController.add(event);
        }
    }

    void _emitError(AssistantError error) {
        if (!_isDisposed && !_errorController.isClosed) {
            _errorController.add(error);
        }
    }

    Future<void> _closeWebSocket() async {
        _isWebSocketReady = false;
        await _wsSubscription?.cancel();
        _wsSubscription = null;
        try {
            await _wsChannel?.sink.close();
        } catch (_) {
            // Ignore sink close errors during teardown
        }
        _wsChannel = null;
    }

    @override
    void dispose() {
        _isDisposed = true;
        _closeWebSocket();
        _httpClient.close();
        _connectionController.close();
        _eventController.close();
        _errorController.close();
    }
}
