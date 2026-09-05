/// Configuration constants for backend communication.
///
/// Centralized location for the backend URL and networking parameters
/// to ensure easy environment switching and desktop deployment tuning.
class ApiConfig {
    /// Prevent instantiation.
    const ApiConfig._();

    /// Default base URL for the Python FastAPI backend.
    /// Configured for local desktop communication.
    static const String defaultBaseUrl = 'http://127.0.0.1:8080';

    /// Current active base URL. Can be mutated if user reconfigures host.
    static String baseUrl = defaultBaseUrl;

    /// WebSocket URL derived from the current base URL.
    static String get wsUrl {
        final uri = Uri.parse(baseUrl);
        final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
        final portPart = uri.hasPort ? ':${uri.port}' : '';
        return '$wsScheme://${uri.host}$portPart/ws/assistant';
    }

    /// Health check endpoint to verify backend reachability.
    static String get healthUrl => '$baseUrl/health';

    /// Audio stream endpoint for voice streaming if REST/chunked transfer is used.
    static String get audioStreamUrl => '$baseUrl/audio/stream';

    /// Connection handshake timeout.
    static const Duration connectionTimeout = Duration(seconds: 5);

    /// Heartbeat ping interval.
    static const Duration pingInterval = Duration(seconds: 15);

    /// Automatic reconnection retry delay.
    static const Duration reconnectDelay = Duration(seconds: 3);

    /// Max reconnection attempts before entering persistent error state.
    static const int maxReconnectAttempts = 5;
}
