import 'dart:async';
import '../api/backend_client.dart';

/// Service responsible for managing high-level connection lifecycle,
/// health status polling, and reconnection commands.
class ConnectionService {
    final BackendClient _client;

    ConnectionService({required BackendClient client}) : _client = client;

    /// Stream of connection status changes from backend client.
    Stream<ConnectionStatus> get statusStream => _client.statusStream;

    /// Current connection status.
    ConnectionStatus get currentStatus => _client.status;

    /// Whether the client currently has a live connection.
    bool get isConnected => _client.status == ConnectionStatus.connected;

    /// Most recent error message.
    String? get lastError => _client.lastErrorMessage;

    /// Initiate connection to backend.
    Future<void> connect() async {
        await _client.connect();
    }

    /// Terminate active connection.
    Future<void> disconnect() async {
        await _client.disconnect();
    }

    /// Trigger an immediate manual reconnection attempt.
    Future<void> retryConnection() async {
        await _client.disconnect();
        await _client.connect();
    }

    /// Dispose connection service resources.
    void dispose() {
        _client.dispose();
    }
}
