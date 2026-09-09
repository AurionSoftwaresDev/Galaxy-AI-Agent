import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/backend_client.dart';
import '../models/agent_config.dart';
import '../models/assistant_state.dart';
import '../models/audio_packet.dart';
import '../models/backend_event.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../services/audio_service.dart';
import '../services/connection_service.dart';
import '../widgets/automation_sidebar.dart';

/// Central state coordinator for the Galaxy AI desktop assistant.
///
/// Implements [ChangeNotifier] for lightweight, predictable, and reactive UI updates.
class AssistantController extends ChangeNotifier {
  final BackendClient _backendClient;
  final AudioService _audioService;
  final ConnectionService _connectionService;

  AssistantState _state = AssistantState.idle;
  String? _activeErrorMessage;
  ToolStatusInfo? _currentToolStatus;
  AudioPacket _currentAudioPacket = AudioPacket.silent();
  bool _isMuted = false;
  bool _isInitialized = false;

  // User Profile with Gmail, username, and initials fallback
  UserProfile _userProfile = const UserProfile(
    username: 'Example User',
    email: 'example@gmail.com',
  );

  // Agent Configuration
  AgentConfig _agentConfig = const AgentConfig();

  // Chat Conversation History
  final List<ChatMessage> _messages = [];

  // Stream subscriptions
  StreamSubscription<ConnectionStatus>? _connectionSub;
  StreamSubscription<BackendEvent>? _eventSub;
  StreamSubscription<AudioPacket>? _audioSub;
  Timer? _activeSimulationTimer;

  AssistantController({
    required BackendClient backendClient,
    required AudioService audioService,
    required ConnectionService connectionService,
  }) : _backendClient = backendClient,
       _audioService = audioService,
       _connectionService = connectionService {
    _seedInitialConversation();
  }

  /// Current operational state of the assistant.
  AssistantState get state => _state;

  /// Human-readable error description, if in error state.
  String? get activeErrorMessage => _activeErrorMessage;

  /// Active tool information if backend is executing a tool in the background.
  ToolStatusInfo? get currentToolStatus => _currentToolStatus;

  /// Active audio packet for live waveform visualizer.
  AudioPacket get currentAudioPacket => _currentAudioPacket;

  /// Whether microphone input is manually muted.
  bool get isMuted => _isMuted;

  /// Current backend connection status.
  ConnectionStatus get connectionStatus => _connectionService.currentStatus;

  /// Whether audio provider is currently simulated vs real hardware.
  bool get isAudioSimulated => _audioService.isSimulated;

  /// User profile details.
  UserProfile get userProfile => _userProfile;

  /// Active agent configurations.
  AgentConfig get agentConfig => _agentConfig;

  /// Chat messages in conversation.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Human-readable connection label for the top header.
  String get connectionLabel {
    switch (_connectionService.currentStatus) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.error:
        return 'Offline';
      case ConnectionStatus.disconnected:
        return 'Offline';
    }
  }

  /// Primary human-readable status text displayed beneath the waveform.
  String get statusSubtitle {
    if (_activeErrorMessage != null && _state == AssistantState.error) {
      return _activeErrorMessage!;
    }
    if (_currentToolStatus != null &&
        (_state == AssistantState.thinking ||
            _state == AssistantState.toolExecution)) {
      return _currentToolStatus!.humanReadableMessage;
    }
    switch (_state) {
      case AssistantState.idle:
        return 'Galaxy AI ready. Click microphone or issue a task.';
      case AssistantState.disconnected:
        return 'Backend offline at 127.0.0.1:8080. Click to retry.';
      case AssistantState.connecting:
        return 'Establishing secure connection to Galaxy AI...';
      case AssistantState.listening:
        return _isMuted
            ? 'Microphone muted. Press Space or click to speak.'
            : 'Listening to your voice...';
      case AssistantState.thinking:
        return 'Reasoning and analyzing request...';
      case AssistantState.toolExecution:
        return 'Executing desktop automation tool...';
      case AssistantState.generating:
        return 'Generating multi-modal response...';
      case AssistantState.speaking:
        return 'Speaking response...';
      case AssistantState.interrupted:
        return 'Playback interrupted by user.';
      case AssistantState.error:
        return _activeErrorMessage ??
            'An unexpected connection issue occurred.';
    }
  }

  void _seedInitialConversation() {
    _messages.addAll([
      ChatMessage(
        id: 'msg_welcome',
        role: MessageRole.assistant,
        text: 'Hello Jakir! Galaxy AI desktop assistant is online and ready. You can speak naturally, trigger workflow automations from the left sidebar, or customize agent parameters in Settings.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        hasAudio: true,
      ),
    ]);
  }

  /// Startup sequence:
  /// 1. Initialize frontend audio service.
  /// 2. Subscribe to event and audio streams.
  /// 3. Attempt backend connection.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _audioService.initialize();

    _audioSub = _audioService.amplitudeStream.listen((packet) {
      _currentAudioPacket = packet;
      notifyListeners();
    });

    _connectionSub = _connectionService.statusStream.listen((connStatus) {
      _handleConnectionStatusChange(connStatus);
    });

    _eventSub = _backendClient.eventStream.listen((event) {
      _handleBackendEvent(event);
    });

    // Initiate initial connection to FastAPI backend
    _setState(AssistantState.connecting);
    await _connectionService.connect();
  }

  void _handleConnectionStatusChange(ConnectionStatus connStatus) {
    switch (connStatus) {
      case ConnectionStatus.connected:
        _activeErrorMessage = null;
        _setState(AssistantState.idle);
        break;
      case ConnectionStatus.connecting:
        _setState(AssistantState.connecting);
        break;
      case ConnectionStatus.error:
        _activeErrorMessage =
            _connectionService.lastError ??
            'Unable to reach backend at 127.0.0.1:8080';
        _setState(AssistantState.error);
        break;
      case ConnectionStatus.disconnected:
        _setState(AssistantState.disconnected);
        break;
    }
  }

  void _handleBackendEvent(BackendEvent event) {
    final parsedState = event.parseState();

    if (parsedState != null) _setState(parsedState);

    final toolInfo = event.parseToolStatus();

    if (toolInfo != null) {
      _currentToolStatus = toolInfo;

      notifyListeners();
    }

    if (event.type == "text_delta") {
      _handleTextDelta(event);

      return;
    }

    if (event.type == "done") {
      _handleResponseCompleted();

      return;
    }

    if (event.type == "error") {
      _handleAgentError(event);
    }

    if (toolInfo != null &&
        _state != AssistantState.thinking &&
        _state != AssistantState.toolExecution) {
      _currentToolStatus = null;
    }
  }

  void _handleTextDelta(BackendEvent event) {

    final text = event.payload["content"];

    if (text is! String || text.isEmpty) return;

    final index = _messages.lastIndexWhere((message) => message.role == MessageRole.assistant && message.status == MessageStatus.thinking);

    if (index == -1) return;

    final message = _messages[index];

    _messages[index] = message.copyWith(text : message.text + text, status : MessageStatus.streaming);

    _setState(AssistantState.generating);

    notifyListeners();
  }

  void _handleResponseCompleted() {

    final index = _messages.lastIndexWhere(
      (message) => message.role == MessageRole.assistant && message.status == MessageStatus.streaming
    );

    if (index != -1) {


      _messages[index] = _messages[index].copyWith(status : MessageStatus.completed);

      _currentToolStatus = null;

      _setState(AssistantState.idle);

      notifyListeners();
    }
  }

  void _handleAgentError(BackendEvent event) {

    final message = event.payload["content"];

    _activeErrorMessage = message is String ? message : "Agent Failed To Generate A Response.";

    _setState(AssistantState.error);
  }

  void _setState(AssistantState newState) {
    if (_state == newState) return;
    _state = newState;
    _audioService.setAssistantState(newState);

    if (newState != AssistantState.thinking &&
        newState != AssistantState.toolExecution) {
      _currentToolStatus = null;
    }
    if (newState != AssistantState.error) {
      _activeErrorMessage = null;
    }

    notifyListeners();
  }

  /// Direct state change override (e.g. from UI buttons).
  void setAssistantState(AssistantState newState) {
    _setState(newState);
  }

  /// Updates the user profile (Username, Gmail, Avatar).
  void updateUserProfile(UserProfile updated) {
    _userProfile = updated;
    notifyListeners();
  }

  /// Updates the agent configuration (Models, Voice, Density, Palette).
  void updateAgentConfig(AgentConfig updated) {
    _agentConfig = updated;
    notifyListeners();
  }

  /// Clear chat history.
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// Execute a task automation from the sidebar.
  void executeAutomationTask(AutomationTask task) {
    sendMessage(task.prompt, toolName: task.toolName);
  }

  /// Handles sending a user prompt either from chat input or voice recognition.
  void sendMessage(String text, {String? toolName}) {
    if (text.trim().isEmpty) return;

    final userMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}_u';
    _messages.add(
      ChatMessage(
        id: userMsgId,
        role: MessageRole.user,
        text: text,
        timestamp: DateTime.now(),
      ),
    );

    // Create placeholder assistant message
    final assistantMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}_a';
    _messages.add(
      ChatMessage(
        id: assistantMsgId,
        role: MessageRole.assistant,
        text: '',
        timestamp: DateTime.now(),
        status: MessageStatus.thinking,
        toolName: toolName,
      ),
    );

    _setState(AssistantState.thinking);
    notifyListeners();

    _backendClient.sendMessage(text);
  }

  void _runAgentPipelineSimulation(
    String messageId,
    String prompt,
    String? toolName,
  ) {
    _activeSimulationTimer?.cancel();

    // Mark any prior lingering messages as completed to avoid stuck states
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].id != messageId &&
          (_messages[i].status == MessageStatus.thinking ||
              _messages[i].status == MessageStatus.executingTool)) {
        _messages[i] = _messages[i].copyWith(status: MessageStatus.completed);
      }
    }

    // 1. Thinking phase (1.0s)
    _activeSimulationTimer = Timer(const Duration(milliseconds: 1000), () {
      final msgIndex = _messages.indexWhere((m) => m.id == messageId);
      if (msgIndex == -1) return;

      final detectedTool = toolName ?? _detectToolFromPrompt(prompt);

      if (detectedTool != null) {
        // Transition to tool execution state
        _setState(AssistantState.toolExecution);
        _currentToolStatus = ToolStatusInfo(
          toolName: detectedTool,
          humanReadableMessage: 'Calling $detectedTool...',
          timestamp: DateTime.now(),
        );
        _messages[msgIndex] = _messages[msgIndex].copyWith(
          status: MessageStatus.executingTool,
          toolName: detectedTool,
          reasoning:
              'Deconstructed query into target execution plan: invoking $detectedTool.',
        );
        notifyListeners();

        // 2. Tool Execution phase (1.2s)
        _activeSimulationTimer = Timer(const Duration(milliseconds: 1200), () {
          _transitionToGenerating(messageId, prompt, detectedTool);
        });
      } else {
        _transitionToGenerating(messageId, prompt, null);
      }
    });
  }

  void _transitionToGenerating(String messageId, String prompt, String? tool) {
    _setState(AssistantState.generating);
    final msgIndex = _messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final responseText = _generateResponseText(prompt, tool);
    _messages[msgIndex] = _messages[msgIndex].copyWith(
      status: MessageStatus.streaming,
      text: responseText,
      reasoning:
          'Synthesized high-context response using ${_agentConfig.model}.',
    );
    notifyListeners();

    // 3. Transition to Speaking phase with audio synthesis (2.8s)
    _activeSimulationTimer = Timer(const Duration(milliseconds: 800), () {
      _setState(AssistantState.speaking);
      if (msgIndex < _messages.length) {
        _messages[msgIndex] = _messages[msgIndex].copyWith(
          status: MessageStatus.completed,
          hasAudio: true,
        );
      }
      notifyListeners();

      // End speaking phase
      _activeSimulationTimer = Timer(const Duration(milliseconds: 3200), () {
        if (_agentConfig.autoListen) {
          _setState(AssistantState.listening);
        } else {
          _setState(AssistantState.idle);
        }
      });
    });
  }

  String? _detectToolFromPrompt(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('clipboard') || lower.contains('paste'))
      return 'clipboard_extractor';
    if (lower.contains('diagnostic') ||
        lower.contains('health') ||
        lower.contains('speed'))
      return 'diagnostics_runner';
    if (lower.contains('email') || lower.contains('draft'))
      return 'email_composer';
    if (lower.contains('research') ||
        lower.contains('web') ||
        lower.contains('search'))
      return 'web_search';
    if (lower.contains('translate') || lower.contains('spanish'))
      return 'polyglot_translator';
    if (lower.contains('schedule') || lower.contains('calendar'))
      return 'calendar_sync';
    return null;
  }

  String _generateResponseText(String prompt, String? tool) {
    if (tool == 'clipboard_extractor') {
      return 'I inspected your active clipboard buffer. Here are the 3 critical action items:\n\n1. Finalize desktop release build v2.4 with updated neon dot shader.\n2. Review WebSocket handshake retry backoff parameters.\n3. Validate cross-platform input bindings for macOS & Linux.';
    }
    if (tool == 'diagnostics_runner') {
      return 'Desktop System Health Check Completed:\n\n• Audio Latency: 14ms (Optimal Low-Latency SIMD)\n• LLM Model: ${_agentConfig.model} (Ready)\n• Connection Stream: 127.0.0.1:8080 (Listening)\n• Memory Footprint: 26.4 MB\n\nAll background tasks and subsystems are operating normally.';
    }
    if (tool == 'email_composer') {
      return 'Here is the drafted executive briefing email:\n\nSubject: Sprint Delivery: Galaxy AI Desktop Agent Overhaul\n\nHi Team,\n\nWe have successfully integrated the new multi-state reasoning engine, interactive neon particle constellation, and task automation sidebar into the desktop build. Latency benchmarks remain under 15ms.\n\nBest regards,\n${_userProfile.username}';
    }
    if (tool == 'web_search') {
      return 'Web search synthesis for your query:\n\nLatest benchmarks indicate that modern multimodal voice agents achieve sub-300ms end-to-end response times by streaming tokenized audio directly from the model, eliminating discrete TTS transcription lag.';
    }
    if (tool == 'calendar_sync') {
      return 'Scheduled calendar event: "Team Sync & Galaxy AI Review" for tomorrow at 2:00 PM - 2:30 PM. Calendar invitation payload has been prepared.';
    }
    if (tool == 'polyglot_translator') {
      return 'Polyglot translation synthesis complete:\n\n• Spanish: "El agente de escritorio Galaxy AI está completamente sincronizado y listo para responder."\n• German: "Der Galaxy AI Desktop-Agent ist vollständig synchronisiert und einsatzbereit."';
    }
    if (tool == 'memory_sanitizer') {
      return 'Context buffer memory flushed successfully. Transient token caches have been cleared while your user profile and model preferences remain preserved.';
    }

    return 'Understood, ${_userProfile.username}. I have processed your request: "$prompt". All parameters and context memory have been synchronized across Galaxy AI.';
  }

  /// Toggle microphone mute/active state.
  void toggleMicrophone() {
    if (!_state.canInteract) return;
    _isMuted = !_isMuted;
    _audioService.toggleMute();

    if (_isMuted) {
      _backendClient.sendEvent(BackendEvent.audioStop());
      if (_state == AssistantState.listening) {
        _setState(AssistantState.idle);
      }
    } else {
      _backendClient.sendEvent(BackendEvent.audioStart());
      _setState(AssistantState.listening);
    }
    notifyListeners();
  }

  /// Interrupt assistant speech.
  void interruptSpeaking() {
    if (_state == AssistantState.speaking) {
      _backendClient.sendEvent(BackendEvent.interrupt());
      _setState(AssistantState.interrupted);
      Timer(const Duration(milliseconds: 900), () {
        _setState(
          _agentConfig.autoListen
              ? AssistantState.listening
              : AssistantState.idle,
        );
      });
    }
  }

  /// Re-attempt connection to backend.
  Future<void> retryConnection() async {
    _activeErrorMessage = null;
    _setState(AssistantState.connecting);
    await _connectionService.retryConnection();
  }

  /// Directly cycle state for desktop testing and visual previews.
  void cycleState() {
    const states = AssistantState.values;
    final nextIndex = (_state.index + 1) % states.length;
    _setState(states[nextIndex]);
  }

  @override
  void dispose() {
    _activeSimulationTimer?.cancel();
    _connectionSub?.cancel();
    _eventSub?.cancel();
    _audioSub?.cancel();
    _audioService.dispose();
    _connectionService.dispose();
    super.dispose();
  }
}
