import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/assistant_state.dart';
import '../state/assistant_controller.dart';
import '../widgets/ai_orb.dart';
import '../widgets/chat_panel.dart';
import '../widgets/error_banner.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/tool_activity_indicator.dart';
import '../widgets/waveform_visualizer.dart';
import 'components/voice_stage_footer.dart';
import 'components/voice_stage_header.dart';

/// Primary desktop screen for Galaxy AI Agent featuring a collapsible
/// left-side Chat Panel alongside the central Voice Interaction stage.
class MainScreen extends StatefulWidget {
    final AssistantController controller;

    const MainScreen({
        super.key,
        required this.controller,
    });

    @override
    State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    final FocusNode _keyboardFocusNode = FocusNode();
    bool _isChatInputFocused = false;

    @override
    void initState() {
        super.initState();
        HardwareKeyboard.instance.addHandler(_handleHardwareKey);
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
                _keyboardFocusNode.requestFocus();
            }
        });
    }

    @override
    void dispose() {
        HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
        _keyboardFocusNode.dispose();
        super.dispose();
    }

    void _focusVoiceStage() {
        _isChatInputFocused = false;
        _keyboardFocusNode.requestFocus();
    }

    bool _isTextInputFocused() {
        if (_isChatInputFocused) {
            return true;
        }
        final primaryFocus = FocusManager.instance.primaryFocus;
        final focusContext = primaryFocus?.context;
        if (focusContext == null) {
            return false;
        }
        if (focusContext.widget is EditableText ||
            focusContext.widget is TextField) {
            return true;
        }
        if (focusContext.findAncestorWidgetOfExactType<EditableText>() !=
                null ||
            focusContext.findAncestorWidgetOfExactType<TextField>() != null ||
            focusContext.findAncestorStateOfType<EditableTextState>() != null) {
            return true;
        }
        return false;
    }

    bool _executeShortcutKey(LogicalKeyboardKey logicalKey) {
        // If user is recording a new key for a frontend shortcut:
        final recordingAction = widget.controller.recordingShortcutAction;
        if (recordingAction != null) {
            if (FrontendShortcutsConfig.isModifierKey(logicalKey)) {
                return true;
            }
            widget.controller.updateShortcut(recordingAction, logicalKey);
            return true;
        }

        // Do not fire main screen shortcuts when a modal dialog is open on top
        if (mounted && !(ModalRoute.of(context)?.isCurrent ?? true)) {
            return false;
        }

        // Ignore global shortcuts when typing inside any TextField / EditableText
        if (_isTextInputFocused()) {
            return false;
        }

        // Ignore when modifier keys (Ctrl, Alt, Cmd) are pressed
        final keyboard = HardwareKeyboard.instance;
        if (keyboard.isControlPressed ||
            keyboard.isMetaPressed ||
            keyboard.isAltPressed) {
            return false;
        }

        final shortcuts = widget.controller.shortcuts;

        if (shortcuts.matches(
            FrontendShortcutAction.toggleVoiceInteraction,
            logicalKey,
        )) {
            widget.controller.toggleVoiceInteraction();
            return true;
        }
        if (shortcuts.matches(
            FrontendShortcutAction.toggleMute,
            logicalKey,
        )) {
            widget.controller.toggleMute();
            return true;
        }
        if (shortcuts.matches(
            FrontendShortcutAction.interruptAssistant,
            logicalKey,
        )) {
            widget.controller.interruptAssistant();
            return true;
        }
        if (shortcuts.matches(
            FrontendShortcutAction.reconnect,
            logicalKey,
        )) {
            widget.controller.reconnect();
            return true;
        }

        return false;
    }

    bool _handleHardwareKey(KeyEvent event) {
        if (event is! KeyDownEvent) {
            return false;
        }
        return _executeShortcutKey(event.logicalKey);
    }

    KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent) {
            return KeyEventResult.ignored;
        }
        final handled = _executeShortcutKey(event.logicalKey);
        return handled ? KeyEventResult.handled : KeyEventResult.ignored;
    }

    void _openSettingsDialog() {
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withValues(alpha: 0.65),
            builder: (ctx) => SettingsDialog(controller: widget.controller),
        ).then((_) {
            if (mounted) {
                _focusVoiceStage();
            }
        });
    }

    void _openKeyboardShortcutsDialog() {
        widget.controller.cancelRecordingShortcutSilently();
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withValues(alpha: 0.65),
            builder: (ctx) =>
                KeyboardShortcutsDialog(controller: widget.controller),
        ).then((_) {
            if (mounted) {
                _focusVoiceStage();
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return Focus(
            focusNode: _keyboardFocusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: Scaffold(
                backgroundColor: const Color(0xFF07090E),
                body: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) {
                        final state = widget.controller.assistantState;
                        final connection = widget.controller.connectionStatus;
                        final isMuted = widget.controller.isMuted;
                        final amplitude = widget.controller.currentAmplitude;
                        final error = widget.controller.activeError;
                        final tool = widget.controller.activeTool;
                        final isChatOpen = widget.controller.isChatPanelOpen;
                        final shortcuts = widget.controller.shortcuts;

                        final toggleVoiceKeyLabel = shortcuts
                            .labelFor(FrontendShortcutAction.toggleVoiceInteraction);
                        final muteKeyLabel =
                            shortcuts.labelFor(FrontendShortcutAction.toggleMute);
                        final interruptKeyLabel = shortcuts
                            .labelFor(FrontendShortcutAction.interruptAssistant);

                        String titleText = state.displayLabel;
                        String subtitleText = state.subtitleHint;

                        if (state == AssistantState.speaking) {
                            titleText = 'Speaking';
                            subtitleText =
                                'Press $interruptKeyLabel or click the orb to interrupt';
                        } else if (state == AssistantState.thinking) {
                            titleText = 'Thinking';
                            subtitleText = tool != null
                                ? tool.statusText
                                : 'Galaxy AI is reasoning...';
                        } else if (state == AssistantState.listening) {
                            subtitleText = isMuted
                                ? 'Click the orb or press $toggleVoiceKeyLabel to unmute microphone'
                                : 'Speak naturally or type in the left chat panel';
                        }

                        return Row(
                            children: [
                                // 1. Collapsible Left-Side Chat Panel with Smooth Animation
                                ClipRect(
                                    child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 320),
                                        curve: Curves.easeInOutCubic,
                                        width: isChatOpen ? 360.0 : 0.0,
                                        child: OverflowBox(
                                            minWidth: 360.0,
                                            maxWidth: 360.0,
                                            alignment: Alignment.topRight,
                                            child: ChatPanel(
                                                messages:
                                                    widget.controller.messages,
                                                assistantState: state,
                                                onSendMessage: widget
                                                    .controller.sendTextMessage,
                                                onClearHistory: widget
                                                    .controller
                                                    .clearChatHistory,
                                                onClosePanel: widget
                                                    .controller.toggleChatPanel,
                                                onInputFocusChanged:
                                                    (isFocused) {
                                                    _isChatInputFocused =
                                                        isFocused;
                                                },
                                            ),
                                        ),
                                    ),
                                ),

                                // 2. Central Voice Interaction Stage
                                Expanded(
                                    child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: _focusVoiceStage,
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                                final stageHeight =
                                                    constraints.maxHeight;
                                                final orbSize = (stageHeight *
                                                        0.32)
                                                    .clamp(140.0, 240.0);
                                                final waveWidth = (constraints
                                                            .maxWidth *
                                                        0.42)
                                                    .clamp(200.0, 360.0);

                                                return Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                        gradient:
                                                            RadialGradient(
                                                            center:
                                                                Alignment(0, -0.1),
                                                            radius: 0.85,
                                                            colors: [
                                                                Color(0xFF0F172A),
                                                                Color(0xFF07090E),
                                                            ],
                                                        ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 24,
                                                    ),
                                                    child: Column(
                                                        children: [
                                                            // Header
                                                            VoiceStageHeader(
                                                                isChatPanelOpen:
                                                                    isChatOpen,
                                                                messageCount: widget
                                                                    .controller
                                                                    .messages
                                                                    .length,
                                                                connectionStatus:
                                                                    connection,
                                                                onToggleChat: widget
                                                                    .controller
                                                                    .toggleChatPanel,
                                                                onOpenSettings:
                                                                    _openSettingsDialog,
                                                                onReconnect: widget
                                                                    .controller
                                                                    .reconnect,
                                                            ),

                                                            // Center AI Orb & Waveform
                                                            Expanded(
                                                                child: Center(
                                                                    child:
                                                                        SingleChildScrollView(
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        child:
                                                                            Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                                AIOrb(
                                                                                    state: state,
                                                                                    amplitude: amplitude,
                                                                                    isMuted: isMuted,
                                                                                    size: orbSize,
                                                                                    onTap: widget.controller.toggleVoiceInteraction,
                                                                                ),
                                                                                const SizedBox(height: 18),
                                                                                WaveformVisualizer(
                                                                                    state: state,
                                                                                    amplitude: amplitude,
                                                                                    isMuted: isMuted,
                                                                                    width: waveWidth,
                                                                                    height: 52,
                                                                                ),
                                                                                const SizedBox(height: 18),
                                                                                Text(
                                                                                    titleText,
                                                                                    style: const TextStyle(
                                                                                        fontSize: 16,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Color(0xFFF1F5F9),
                                                                                    ),
                                                                                ),
                                                                                const SizedBox(height: 6),
                                                                                Text(
                                                                                    subtitleText,
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(
                                                                                        fontSize: 12.5,
                                                                                        color: Color(0xFF64748B),
                                                                                    ),
                                                                                ),
                                                                                if (tool != null && tool.isActive) ...[
                                                                                    const SizedBox(height: 14),
                                                                                    ToolActivityIndicator(toolActivity: tool),
                                                                                ],
                                                                                if (error != null) ...[
                                                                                    const SizedBox(height: 14),
                                                                                    ErrorBanner(
                                                                                        error: error,
                                                                                        onRetry: widget.controller.reconnect,
                                                                                        onDismiss: widget.controller.dismissError,
                                                                                    ),
                                                                                ],
                                                                            ],
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),

                                                            // Footer with Left-Bottom Settings & Shortcuts
                                                            VoiceStageFooter(
                                                                state: state,
                                                                isMuted: isMuted,
                                                                connection:
                                                                    connection,
                                                                toggleVoiceKeyLabel:
                                                                    toggleVoiceKeyLabel,
                                                                muteKeyLabel:
                                                                    muteKeyLabel,
                                                                shortcuts:
                                                                    shortcuts,
                                                                onToggleVoice: widget
                                                                    .controller
                                                                    .toggleVoiceInteraction,
                                                                onToggleMute: widget
                                                                    .controller
                                                                    .toggleMute,
                                                                onOpenShortcutsDialog:
                                                                    _openKeyboardShortcutsDialog,
                                                                onOpenSettings:
                                                                    _openSettingsDialog,
                                                            ),
                                                        ],
                                                    ),
                                                );
                                            },
                                        ),
                                    ),
                                ),
                            ],
                        );
                    },
                ),
            ),
        );
    }
}
