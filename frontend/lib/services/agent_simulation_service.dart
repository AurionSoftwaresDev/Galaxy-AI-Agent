import 'dart:async';
import '../models/agent_config.dart';
import '../models/assistant_state.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';

/// Service that simulates multi-stage LLM reasoning, tool execution, response streaming,
/// and synthetic speech playback when the desktop agent operates standalone or offline.
class AgentSimulationService {
    Timer? _activeTimer;

    /// Disposes any pending timer.
    void dispose() {
        _activeTimer?.cancel();
    }

    /// Cancels active simulation.
    void cancel() {
        _activeTimer?.cancel();
    }

    /// Detects if the prompt calls for a specific built-in desktop tool.
    String? detectToolFromPrompt(String prompt) {
        final lower = prompt.toLowerCase();
        if (lower.contains('clipboard') || lower.contains('paste')) return 'clipboard_extractor';
        if (lower.contains('diagnostic') || lower.contains('health') || lower.contains('speed')) return 'diagnostics_runner';
        if (lower.contains('email') || lower.contains('draft')) return 'email_composer';
        if (lower.contains('research') || lower.contains('web') || lower.contains('search')) return 'web_search';
        if (lower.contains('translate') || lower.contains('spanish')) return 'polyglot_translator';
        if (lower.contains('schedule') || lower.contains('calendar')) return 'calendar_sync';
        if (lower.contains('memory') || lower.contains('flush')) return 'memory_sanitizer';
        return null;
    }

    /// Generates contextual responses for simulated agent execution.
    String generateResponseText({
        required String prompt,
        required String? tool,
        required UserProfile userProfile,
        required AgentConfig agentConfig,
    }) {
        if (tool == 'clipboard_extractor') {
            return 'I inspected your active clipboard buffer. Here are the 3 critical action items:\n\n1. Finalize desktop release build v2.4 with updated neon dot shader.\n2. Review WebSocket handshake retry backoff parameters.\n3. Validate cross-platform input bindings for macOS & Linux.';
        }
        if (tool == 'diagnostics_runner') {
            return 'Desktop System Health Check Completed:\n\n• Audio Latency: 14ms (Optimal Low-Latency SIMD)\n• LLM Model: ${agentConfig.model} (Ready)\n• Connection Stream: 127.0.0.1:8080 (Listening)\n• Memory Footprint: 26.4 MB\n\nAll background tasks and subsystems are operating normally.';
        }
        if (tool == 'email_composer') {
            return 'Here is the drafted executive briefing email:\n\nSubject: Sprint Delivery: Galaxy AI Desktop Agent Overhaul\n\nHi Team,\n\nWe have successfully integrated the new multi-state reasoning engine, interactive neon particle constellation, and task automation sidebar into the desktop build. Latency benchmarks remain under 15ms.\n\nBest regards,\n${userProfile.username}';
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

        return 'Understood, ${userProfile.username}. I have processed your request: "$prompt". All parameters and context memory have been synchronized across Galaxy AI.';
    }

    /// Orchestrates the multi-stage simulation pipeline:
    /// 1. Thinking phase (1.0s)
    /// 2. Tool execution phase (1.2s if detected)
    /// 3. Response generation & text streaming (0.8s)
    /// 4. Speaking synthesis (3.2s)
    /// 5. Completion transition
    void runPipeline({
        required String messageId,
        required String prompt,
        required String? toolName,
        required UserProfile userProfile,
        required AgentConfig agentConfig,
        required void Function(AssistantState state) onStateChange,
        required void Function(ToolStatusInfo? toolStatus) onToolStatusChange,
        required void Function(ChatMessage updatedMessage) onUpdateMessage,
        required VoidCallback onComplete,
    }) {
        _activeTimer?.cancel();

        // 1. Thinking phase (1.0s)
        _activeTimer = Timer(const Duration(milliseconds: 1000), () {
            final detectedTool = toolName ?? detectToolFromPrompt(prompt);

            if (detectedTool != null) {
                // Transition to tool execution state
                onStateChange(AssistantState.toolExecution);
                onToolStatusChange(ToolStatusInfo(
                    toolName: detectedTool,
                    humanReadableMessage: 'Calling $detectedTool...',
                    timestamp: DateTime.now(),
                ));

                onUpdateMessage(ChatMessage(
                    id: messageId,
                    role: MessageRole.assistant,
                    text: '',
                    timestamp: DateTime.now(),
                    status: MessageStatus.executingTool,
                    toolName: detectedTool,
                    reasoning: 'Deconstructed query into target execution plan: invoking $detectedTool.',
                ));

                // 2. Tool execution phase (1.2s)
                _activeTimer = Timer(const Duration(milliseconds: 1200), () {
                    _transitionToGenerating(
                        messageId: messageId,
                        prompt: prompt,
                        tool: detectedTool,
                        userProfile: userProfile,
                        agentConfig: agentConfig,
                        onStateChange: onStateChange,
                        onUpdateMessage: onUpdateMessage,
                        onComplete: onComplete,
                    );
                });
            } else {
                _transitionToGenerating(
                    messageId: messageId,
                    prompt: prompt,
                    tool: null,
                    userProfile: userProfile,
                    agentConfig: agentConfig,
                    onStateChange: onStateChange,
                    onUpdateMessage: onUpdateMessage,
                    onComplete: onComplete,
                );
            }
        });
    }

    void _transitionToGenerating({
        required String messageId,
        required String prompt,
        required String? tool,
        required UserProfile userProfile,
        required AgentConfig agentConfig,
        required void Function(AssistantState state) onStateChange,
        required void Function(ChatMessage updatedMessage) onUpdateMessage,
        required VoidCallback onComplete,
    }) {
        onStateChange(AssistantState.generating);

        final responseText = generateResponseText(
            prompt: prompt,
            tool: tool,
            userProfile: userProfile,
            agentConfig: agentConfig,
        );

        onUpdateMessage(ChatMessage(
            id: messageId,
            role: MessageRole.assistant,
            text: responseText,
            timestamp: DateTime.now(),
            status: MessageStatus.streaming,
            toolName: tool,
            reasoning: 'Synthesized high-context response using ${agentConfig.model}.',
        ));

        // 3. Transition to speaking phase (0.8s delay)
        _activeTimer = Timer(const Duration(milliseconds: 800), () {
            onStateChange(AssistantState.speaking);
            onUpdateMessage(ChatMessage(
                id: messageId,
                role: MessageRole.assistant,
                text: responseText,
                timestamp: DateTime.now(),
                status: MessageStatus.completed,
                toolName: tool,
                reasoning: 'Synthesized high-context response using ${agentConfig.model}.',
                hasAudio: true,
            ));

            // End speaking phase
            _activeTimer = Timer(const Duration(milliseconds: 3200), () {
                onComplete();
            });
        });
    }
}
