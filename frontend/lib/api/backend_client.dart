import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/backend_event.dart';
import 'api_config.dart';

/// Connection states between desktop client and Python backend.
enum ConnectionStatus {
    disconnected,
    connecting,
    connected,
    error,
}

/// Abstract contract for Python FastAPI backend communication.
///
/// Ensures the network layer can be seamlessly swapped or mocked
/// without impacting UI screens or state controllers.
abstract class BackendClient {
    /// Stream of connection status updates.
    Stream<ConnectionStatus> get statusStream;

    /// Stream of incoming backend events (state changes, tool execution, audio).
    Stream<BackendEvent> get eventStream;

    /// Current connection status.
    ConnectionStatus get status;

    /// Human-readable description of the last connection error.
    String? get lastErrorMessage;

    /// Establish connection to backend.
    Future<void> connect();

    /// Terminate connection cleanly.
    Future<void> disconnect();

    /// Dispatch event to backend.
    Future<void> sendEvent(BackendEvent event);

    /// Sending agent message to user
    Future<void> sendMessage(String content);

    /// Clean up network streams and sockets.
    void dispose();
}

/// Production desktop implementation communicating with FastAPI over WebSocket & HTTP.
class FastApiBackendClient implements BackendClient {
    final StreamController<ConnectionStatus> _statusController =
        StreamController<ConnectionStatus>.broadcast();
    final StreamController<BackendEvent> _eventController =
        StreamController<BackendEvent>.broadcast();

    WebSocketChannel? _channel;
    StreamSubscription<dynamic>? _channelSubscription;
    Timer? _reconnectTimer;
    int _reconnectAttempts = 0;
    ConnectionStatus _status = ConnectionStatus.disconnected;
    String? _lastError;
    bool _isDisposed = false;

    @override
    Stream<ConnectionStatus> get statusStream => _statusController.stream;

    @override
    Stream<BackendEvent> get eventStream => _eventController.stream;

    @override
    ConnectionStatus get status => _status;

    @override
    String? get lastErrorMessage => _lastError;

    @override
    Future<void> connect() async {
        if (_isDisposed) return;
        if (_status == ConnectionStatus.connecting || _status == ConnectionStatus.connected) {
            return;
        }

        _setStatus(ConnectionStatus.connecting);
        _lastError = null;

        try {
            // First perform a quick HTTP health check to test reachability
            final healthUri = Uri.parse(ApiConfig.healthUrl);
            try {
                final response = await http.get(healthUri).timeout(ApiConfig.connectionTimeout);
                if (response.statusCode >= 500) {
                    throw Exception('Backend returned server error (${response.statusCode})');
                }
            } catch (e) {
                // If health check fails or times out, proceed to test WebSocket directly
                // in case the FastAPI server only serves WebSocket routes.
            }

            final wsUri = Uri.parse(ApiConfig.wsUrl);
            final channel = WebSocketChannel.connect(wsUri);
            _channel = channel;

            _channelSubscription = channel.stream.listen(
                (dynamic message) {
                    if (_status != ConnectionStatus.connected) {
                        _reconnectAttempts = 0;
                        _setStatus(ConnectionStatus.connected);
                    }
                    _handleIncomingMessage(message);
                },
                onError: (dynamic error) {
                    _handleConnectionFailure('Connection dropped: ${error.toString()}');
                },
                onDone: () {
                    if (_status == ConnectionStatus.connected) {
                        _handleConnectionFailure('Backend closed connection');
                    } else {
                        _handleConnectionFailure('Unable to reach backend at ${ApiConfig.baseUrl}');
                    }
                },
                cancelOnError: true,
            );

            // Give a short timeout for handshake confirmation
            Future.delayed(const Duration(milliseconds: 600), () {
                if (_status == ConnectionStatus.connecting && _channel != null) {
                    _reconnectAttempts = 0;
                    _setStatus(ConnectionStatus.connected);
                }
            });
        } catch (e) {
            _handleConnectionFailure('Could not connect to ${ApiConfig.baseUrl}');
        }
    }

    void _handleIncomingMessage(dynamic rawMessage) {
        if (rawMessage is String) {
            final event = BackendEvent.fromJson(rawMessage);
            if (!_eventController.isClosed) {
                _eventController.add(event);
            }
        }
    }

    void _handleConnectionFailure(String message) {
        _lastError = message;
        _channelSubscription?.cancel();
        _channelSubscription = null;
        _channel = null;

        _setStatus(ConnectionStatus.error);

        // Schedule auto-reconnection attempt if under maximum limit
        if (_reconnectAttempts < ApiConfig.maxReconnectAttempts && !_isDisposed) {
            _reconnectAttempts++;
            _reconnectTimer?.cancel();
            _reconnectTimer = Timer(ApiConfig.reconnectDelay, () {
                if (!_isDisposed && _status != ConnectionStatus.connected) {
                    connect();
                }
            });
        }
    }

    @override
    Future<void> sendEvent(BackendEvent event) async {
        if (_channel != null && _status == ConnectionStatus.connected) {
            try {
                _channel?.sink.add(event.toJson());
            } catch (e) {
                _handleConnectionFailure('Failed to transmit message: ${e.toString()}');
            }
        }
    }

    @override
    Future<void> disconnect() async {
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        await _channelSubscription?.cancel();
        _channelSubscription = null;
        await _channel?.sink.close();
        _channel = null;
        _setStatus(ConnectionStatus.disconnected);
    }

    void _setStatus(ConnectionStatus newStatus) {
        _status = newStatus;
        if (!_statusController.isClosed) {
            _statusController.add(newStatus);
        }
    }

    @override
    void dispose() {
        _isDisposed = true;
        _reconnectTimer?.cancel();
        _channelSubscription?.cancel();
        _channel?.sink.close();
        _statusController.close();
        _eventController.close();
    }

    @override
    Future<void> sendMessage(String content) async {

      if (_channel != null && _status == ConnectionStatus.connected) {
        try {
          
          _channel?.sink.add(
            jsonEncode(<String, dynamic>{
              "content" : content
            })
          );
        } catch (Error) {
          _handleConnectionFailure("Failed To Transmit Message : ${Error.toString()}");
        }
      }
    }
}
