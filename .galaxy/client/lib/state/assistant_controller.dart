import 'dart:async';
import 'package:flutter/foundation.dart';

import '../api/backend_client.dart';
import '../models/assistant_state.dart';
import '../services/voice_service.dart';
import 'shortcuts_controller_mixin.dart';

/// Coordinates UI state, FastAPI backend connection (`http://127.0.0.1:8000`),
/// WebSocket streaming (`/ws/assistant`), left-side chat history, `/settings/*`, and `VoiceService`.
class AssistantController extends ChangeNotifier with ShortcutsControllerMixin {
    final BackendClient _backendClient;
    final VoiceService _voiceService;

    AssistantState _assistantState = AssistantState.connecting;
    ConnectionStatus _connectionStatus = ConnectionStatus.connecting;
    ToolActivity? _activeTool;
    AssistantError? _activeError;
    AgentSettingsSnapshot _settings = const AgentSettingsSnapshot();
    double _currentAmplitude = 0.0;
    String _streamingSubtitle = '';
    bool _isChatPanelOpen = true;
    final List<ChatMessage> _messages = [];
    String? _activeStreamingMessageId;

    StreamSubscription<ConnectionStatus>? _connectionSub;
    StreamSubscription<BackendEvent>? _eventSub;
    StreamSubscription<AssistantError>? _backendErrorSub;
    StreamSubscription<AssistantError>? _voiceErrorSub;
    StreamSubscription<double>? _amplitudeSub;
    StreamSubscription<String>? _speechSub;
    StreamSubscription<void>? _speakingDoneSub;

    AssistantController({
        required BackendClient backendClient,
        required VoiceService voiceService,
    })  : _backendClient = backendClient,
          _voiceService = voiceService {
        _bindStreams();
    }

    AssistantState get assistantState => _assistantState;
    ConnectionStatus get connectionStatus => _connectionStatus;
    ToolActivity? get activeTool => _activeTool;
    AssistantError? get activeError => _activeError;
    AgentSettingsSnapshot get settings => _settings;
    double get currentAmplitude => _currentAmplitude;
    bool get isMuted => _voiceService.isMuted;
    bool get isMicActive =>
        _assistantState == AssistantState.listening && !_voiceService.isMuted;
    String get backendBaseUrl => _backendClient.config.baseUrl;
    String get streamingSubtitle => _streamingSubtitle;
    bool get isChatPanelOpen => _isChatPanelOpen;
    List<ChatMessage> get messages => List.unmodifiable(_messages);

    /// Toggles the left-side chat panel open or closed.
    void toggleChatPanel() {
        _isChatPanelOpen = !_isChatPanelOpen;
        notifyListeners();
    }

    /// Clears the local conversation transcript in the left chat panel.
    void clearChatHistory() {
        _messages.clear();
        _activeStreamingMessageId = null;
        _streamingSubtitle = '';
        notifyListeners();
    }

    /// Initializes default voice mode on startup, connects to `http://127.0.0.1:8000`,
    /// and loads available LLM providers and models from `/settings/*`.
    Future<void> initializeDefaultVoiceMode() async {
        _activeError = null;
        _setAssistantState(AssistantState.connecting);

        final audioReady = await _voiceService.initialize();
        if (!audioReady) {
            _setAssistantState(AssistantState.error);
            return;
        }

        await _voiceService.startListening();
        await _backendClient.connect();

        if (_connectionStatus == ConnectionStatus.connected) {
            await refreshAgentSettings();
        }
    }

    /// Fetches `/settings/avaliable-providers` and `/settings/avaliable-models` from the backend.
    Future<void> refreshAgentSettings() async {
        final results = await Future.wait([
            _backendClient.fetchAvailableProviders(),
            _backendClient.fetchAvailableModels(),
        ]);

        final providers = results[0];
        final models = results[1];

        _settings = _settings.copyWith(
            availableProviders: providers,
            availableModels: models,
            activeProvider: _settings.activeProvider ??
                (providers.isNotEmpty ? providers.first : null),
        );
        notifyListeners();
    }

    /// Updates the active LLM provider via `PATCH /settings/change-agent-provider`.
    Future<bool> changeProvider(String providerName) async {
        final ok = await _backendClient.changeAgentProvider(providerName);
        if (ok) {
            _settings = _settings.copyWith(activeProvider: providerName);
            notifyListeners();
        }
        return ok;
    }

    /// Updates the LLM temperature via `PATCH /settings/change-agent-temperature`.
    Future<bool> changeTemperature(double newTemperature) async {
        final clamped = double.parse(
            newTemperature.clamp(0.0, 1.0).toStringAsFixed(2),
        );
        final ok = await _backendClient.changeAgentTemperature(clamped);
        if (ok) {
            _settings = _settings.copyWith(temperature: clamped);
            notifyListeners();
        }
        return ok;
    }

    /// Sends a chat or voice prompt to `/ws/assistant` (or `/agent/generate` fallback)
    /// and appends it to the left-side chat panel.
    Future<void> sendVoicePrompt(String prompt) async {
        final trimmed = prompt.trim();
        if (trimmed.isEmpty) return;

        final now = DateTime.now();
        final userMsg = ChatMessage(
            id: 'user_${now.microsecondsSinceEpoch}',
            role: ChatRole.user,
            content: trimmed,
            timestamp: now,
        );
        final assistantMsgId = 'assistant_${now.microsecondsSinceEpoch + 1}';
        final placeholderAssistantMsg = ChatMessage(
            id: assistantMsgId,
            role: ChatRole.assistant,
            content: '',
            timestamp: now,
            isStreaming: true,
        );

        _messages.add(userMsg);
        _messages.add(placeholderAssistantMsg);
        _activeStreamingMessageId = assistantMsgId;
        _activeError = null;
        _activeTool = null;
        _streamingSubtitle = '';
        _setAssistantState(AssistantState.thinking);

        if (_connectionStatus == ConnectionStatus.offline) {
            await reconnect();
            if (_connectionStatus == ConnectionStatus.offline) {
                _finalizeStreamingMessageWithError(
                    'Backend server at $backendBaseUrl is offline.',
                );
                return;
            }
        }

        await _backendClient.sendPrompt(trimmed);
    }

    /// Alias for sending message from chat panel input bar.
    Future<void> sendTextMessage(String text) => sendVoicePrompt(text);

    /// Toggles between active voice listening and muted state, or interrupts assistant speech.
    Future<void> toggleVoiceInteraction() async {
        if (_connectionStatus == ConnectionStatus.offline ||
            _assistantState == AssistantState.disconnected ||
            _assistantState == AssistantState.error) {
            await reconnect();
            return;
        }

        if (_assistantState == AssistantState.speaking) {
            await interruptAssistant();
            return;
        }

        if (_voiceService.isMuted) {
            _voiceService.setMuted(false);
            await _voiceService.startListening();
            _setAssistantState(AssistantState.listening);
        } else {
            _voiceService.setMuted(true);
            notifyListeners();
        }
    }

    /// Explicitly toggles microphone mute state.
    Future<void> toggleMute() async {
        final nextMuted = !_voiceService.isMuted;
        _voiceService.setMuted(nextMuted);
        notifyListeners();
    }

    /// Interrupts the assistant while speaking and returns to listening mode.
    Future<void> interruptAssistant() async {
        if (_connectionStatus != ConnectionStatus.connected) return;
        _activeTool = null;
        _streamingSubtitle = '';
        _completeActiveStreamingMessage();
        _setAssistantState(AssistantState.listening);
        await _voiceService.startListening();
    }

    /// Reconnects to the Python backend (`http://127.0.0.1:8000`) and restores default voice mode.
    Future<void> reconnect() async {
        _activeError = null;
        _activeTool = null;
        _streamingSubtitle = '';
        _setAssistantState(AssistantState.connecting);
        await _voiceService.startListening();
        await _backendClient.connect();

        if (_connectionStatus == ConnectionStatus.connected) {
            await refreshAgentSettings();
        }
    }

    /// Requests desktop server termination/kill via `POST /server/desktop/disconnect`,
    /// closes local streaming connection, and updates status to offline/disconnected.
    Future<bool> disconnectDesktopServer() async {
        _activeError = null;
        _activeTool = null;
        _streamingSubtitle = '';
        _setAssistantState(AssistantState.disconnected);
        final result = await _backendClient.disconnectDesktopServer();
        notifyListeners();
        return result;
    }

    /// Updates the configurable backend base URL and reconnects.
    Future<void> updateBackendBaseUrl(String newBaseUrl) async {
        final sanitized = newBaseUrl.trim();
        if (sanitized.isEmpty) return;
        _activeError = null;
        _streamingSubtitle = '';
        _setAssistantState(AssistantState.connecting);
        await _backendClient.updateConfig(
            _backendClient.config.copyWith(baseUrl: sanitized),
        );
        if (_connectionStatus == ConnectionStatus.connected) {
            await refreshAgentSettings();
        }
    }

    /// Dismisses the current non-fatal error banner.
    void dismissError() {
        if (_activeError != null) {
            _activeError = null;
            if (_connectionStatus == ConnectionStatus.connected &&
                _assistantState == AssistantState.error) {
                _setAssistantState(AssistantState.listening);
            }
            notifyListeners();
        }
    }

    void _appendStreamingDeltaToChat(String delta) {
        if (delta.isEmpty) return;

        if (_activeStreamingMessageId != null) {
            final index = _messages.indexWhere(
                (m) => m.id == _activeStreamingMessageId,
            );
            if (index != -1) {
                final existing = _messages[index];
                _messages[index] = existing.copyWith(
                    content: existing.content + delta,
                    isStreaming: true,
                );
                return;
            }
        }

        final now = DateTime.now();
        final newId = 'assistant_${now.microsecondsSinceEpoch}';
        _activeStreamingMessageId = newId;
        _messages.add(
            ChatMessage(
                id: newId,
                role: ChatRole.assistant,
                content: delta,
                timestamp: now,
                isStreaming: true,
            ),
        );
    }

    void _completeActiveStreamingMessage() {
        if (_activeStreamingMessageId == null) return;
        final index = _messages.indexWhere(
            (m) => m.id == _activeStreamingMessageId,
        );
        if (index != -1) {
            final existing = _messages[index];
            _messages[index] = existing.copyWith(isStreaming: false);
        }
        _activeStreamingMessageId = null;
    }

    void _finalizeStreamingMessageWithError(String errorMessage) {
        if (_activeStreamingMessageId == null) return;
        final index = _messages.indexWhere(
            (m) => m.id == _activeStreamingMessageId,
        );
        if (index != -1) {
            final existing = _messages[index];
            _messages[index] = existing.copyWith(
                content:
                    existing.content.isEmpty ? errorMessage : existing.content,
                isStreaming: false,
                isError: true,
            );
        }
        _activeStreamingMessageId = null;
        notifyListeners();
    }

    void _bindStreams() {
        _connectionSub = _backendClient.connectionStatusStream.listen((status) {
            _connectionStatus = status;
            if (status == ConnectionStatus.offline) {
                _setAssistantState(AssistantState.disconnected);
            } else if (status == ConnectionStatus.connecting) {
                _setAssistantState(AssistantState.connecting);
            } else if (status == ConnectionStatus.connected &&
                _assistantState != AssistantState.speaking &&
                _assistantState != AssistantState.thinking) {
                _setAssistantState(AssistantState.listening);
            }
            notifyListeners();
        });

        _eventSub = _backendClient.eventStream.listen((event) {
            if (event.toolActivity != null) {
                _activeTool = event.toolActivity;
                notifyListeners();
            }

            if (event.textDelta != null) {
                _appendStreamingDeltaToChat(event.textDelta!);
                _streamingSubtitle = (_streamingSubtitle + event.textDelta!);
                _voiceService.onStreamingTextDelta(event.textDelta!);
            }

            if (event.assistantState != null) {
                _setAssistantState(event.assistantState!);
            }

            if (event.isCompleted) {
                _completeActiveStreamingMessage();
                _activeTool = null;
                _streamingSubtitle = '';
                _voiceService.onBackendStreamDone();
                _setAssistantState(AssistantState.listening);
            }

            notifyListeners();
        });

        _backendErrorSub = _backendClient.errorStream.listen((err) {
            _activeError = err;
            _finalizeStreamingMessageWithError(err.userMessage);
            _setAssistantState(AssistantState.error);
            notifyListeners();
        });

        _voiceErrorSub = _voiceService.errorStream.listen((err) {
            _activeError = err;
            _setAssistantState(AssistantState.error);
            notifyListeners();
        });

        _amplitudeSub = _voiceService.amplitudeStream.listen((amp) {
            _currentAmplitude = amp;
            notifyListeners();
        });

        _speechSub = _voiceService.recognizedSpeechStream.listen((speech) {
            if (speech.isNotEmpty) {
                sendVoicePrompt(speech);
            }
        });

        _speakingDoneSub = _voiceService.speakingCompletedStream.listen((_) {
            _streamingSubtitle = '';
            if (_assistantState == AssistantState.speaking) {
                _setAssistantState(AssistantState.listening);
            }
        });
    }

    void _setAssistantState(AssistantState next) {
        if (_assistantState == next) return;
        _assistantState = next;
        notifyListeners();
    }

    @override
    void dispose() {
        _connectionSub?.cancel();
        _eventSub?.cancel();
        _backendErrorSub?.cancel();
        _voiceErrorSub?.cancel();
        _amplitudeSub?.cancel();
        _speechSub?.cancel();
        _speakingDoneSub?.cancel();
        _voiceService.dispose();
        _backendClient.dispose();
        super.dispose();
    }
}
