import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/assistant_state.dart';
import '../state/assistant_controller.dart';
import '../widgets/ai_orb.dart';
import '../widgets/chat_panel.dart';
import '../widgets/error_banner.dart';
import '../widgets/microphone_control.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/status_indicator.dart';
import '../widgets/tool_activity_indicator.dart';
import '../widgets/waveform_visualizer.dart';

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
        // Handled via HardwareKeyboard.instance listener
        return KeyEventResult.ignored;
    }

    void _openSettingsDialog() {
        showDialog<void>(
            context: context,
            builder: (_) => SettingsDialog(controller: widget.controller),
        ).then((_) {
            if (mounted) {
                _focusVoiceStage();
            }
        });
    }

    void _openKeyboardShortcutsDialog() {
        showDialog<void>(
            context: context,
            builder: (_) =>
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
                        final amplitude = widget.controller.currentAmplitude;
                        final isMuted = widget.controller.isMuted;
                        final streamingSubtitle =
                            widget.controller.streamingSubtitle;
                        final isChatOpen = widget.controller.isChatPanelOpen;
                        final shortcuts = widget.controller.shortcuts;
                        final toggleVoiceKeyLabel = shortcuts.labelFor(
                            FrontendShortcutAction.toggleVoiceInteraction,
                        );
                        final muteKeyLabel = shortcuts.labelFor(
                            FrontendShortcutAction.toggleMute,
                        );
                        final interruptKeyLabel = shortcuts.labelFor(
                            FrontendShortcutAction.interruptAssistant,
                        );

                        final String subtitleText;
                        if (state == AssistantState.speaking &&
                            streamingSubtitle.isNotEmpty) {
                            subtitleText = streamingSubtitle;
                        } else if (state == AssistantState.speaking) {
                            subtitleText =
                                'Press $interruptKeyLabel or tap the orb to interrupt';
                        } else if (state == AssistantState.idle) {
                            subtitleText =
                                'Click the orb or press $toggleVoiceKeyLabel to begin speaking';
                        } else {
                            subtitleText = state.subtitleHint;
                        }

                        return Row(
                            children: [
                                // Left-Side Chat Panel
                                AnimatedSize(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    child: isChatOpen
                                        ? ChatPanel(
                                              messages:
                                                  widget.controller.messages,
                                              assistantState: state,
                                              onSendMessage: widget
                                                  .controller.sendVoicePrompt,
                                              onClearHistory: widget
                                                  .controller.clearChatHistory,
                                              onClosePanel: () {
                                                  _focusVoiceStage();
                                                  widget.controller
                                                      .toggleChatPanel();
                                              },
                                              onInputFocusChanged: (focused) {
                                                  _isChatInputFocused = focused;
                                              },
                                          )
                                        : const SizedBox.shrink(),
                                ),

                                // Main Voice Interaction Stage
                                Expanded(
                                    child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: _focusVoiceStage,
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                            final shortestSide =
                                                constraints.biggest.shortestSide;
                                            final orbSize = (shortestSide * 0.36)
                                                .clamp(180.0, 290.0);
                                            final waveWidth =
                                                (constraints.maxWidth * 0.38)
                                                    .clamp(240.0, 380.0);

                                            return Stack(
                                                children: [
                                                    // Subtle deep-space radial atmosphere
                                                    Positioned.fill(
                                                        child: DecoratedBox(
                                                            decoration:
                                                                BoxDecoration(
                                                                gradient:
                                                                    RadialGradient(
                                                                    center:
                                                                        const Alignment(
                                                                        0.0,
                                                                        -0.08,
                                                                    ),
                                                                    radius: 0.85,
                                                                    colors: [
                                                                        const Color(
                                                                                0xFF0F172A)
                                                                            .withValues(
                                                                                alpha:
                                                                                    0.65,
                                                                            ),
                                                                        const Color(
                                                                            0xFF07090E,
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        ),
                                                    ),

                                                    SafeArea(
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 32,
                                                                vertical: 24,
                                                            ),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                    // 1. Minimal Top Bar
                                                                    Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceBetween,
                                                                        children: [
                                                                            Row(
                                                                                mainAxisSize:
                                                                                    MainAxisSize
                                                                                        .min,
                                                                                children: [
                                                                                    if (!isChatOpen) ...[
                                                                                        IconButton(
                                                                                            onPressed:
                                                                                                widget
                                                                                                    .controller
                                                                                                    .toggleChatPanel,
                                                                                            tooltip:
                                                                                                'Open Chat Panel',
                                                                                            icon: const Icon(
                                                                                                Icons
                                                                                                    .chat_bubble_outline_rounded,
                                                                                                size:
                                                                                                    17,
                                                                                                color: Color(
                                                                                                    0xFF94A3B8,
                                                                                                ),
                                                                                            ),
                                                                                            constraints:
                                                                                                const BoxConstraints(
                                                                                                minWidth:
                                                                                                    32,
                                                                                                minHeight:
                                                                                                    32,
                                                                                            ),
                                                                                            padding:
                                                                                                EdgeInsets
                                                                                                    .zero,
                                                                                        ),
                                                                                        const SizedBox(
                                                                                            width:
                                                                                                10,
                                                                                        ),
                                                                                    ],
                                                                                    const Text(
                                                                                        'Galaxy AI',
                                                                                        style:
                                                                                            TextStyle(
                                                                                            fontSize:
                                                                                                16,
                                                                                            fontWeight:
                                                                                                FontWeight
                                                                                                    .w600,
                                                                                            letterSpacing:
                                                                                                0.6,
                                                                                            color: Color(
                                                                                                0xFFF8FAFC,
                                                                                            ),
                                                                                        ),
                                                                                    ),
                                                                                ],
                                                                            ),
                                                                            Row(
                                                                                mainAxisSize:
                                                                                    MainAxisSize
                                                                                        .min,
                                                                                children: [
                                                                                    StatusIndicator(
                                                                                        status:
                                                                                            connection,
                                                                                        onReconnectRequested:
                                                                                            widget
                                                                                                .controller
                                                                                                .reconnect,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                        width:
                                                                                            14,
                                                                                    ),
                                                                                    IconButton(
                                                                                        onPressed:
                                                                                            _openSettingsDialog,
                                                                                        tooltip:
                                                                                            'Agent Settings',
                                                                                        icon: const Icon(
                                                                                            Icons
                                                                                                .tune_rounded,
                                                                                            size:
                                                                                                18,
                                                                                            color: Color(
                                                                                                0xFF94A3B8,
                                                                                            ),
                                                                                        ),
                                                                                        constraints:
                                                                                            const BoxConstraints(
                                                                                            minWidth:
                                                                                                32,
                                                                                            minHeight:
                                                                                                32,
                                                                                        ),
                                                                                        padding:
                                                                                            EdgeInsets
                                                                                                .zero,
                                                                                    ),
                                                                                ],
                                                                            ),
                                                                        ],
                                                                    ),

                                                                    // 2. Center Voice Orb & Waveform
                                                                    Expanded(
                                                                        child:
                                                                            Center(
                                                                            child: SingleChildScrollView(
                                                                                physics:
                                                                                    const NeverScrollableScrollPhysics(),
                                                                                child:
                                                                                    Column(
                                                                                    mainAxisSize:
                                                                                        MainAxisSize
                                                                                            .min,
                                                                                    children: [
                                                                                        AIOrb(
                                                                                            state:
                                                                                                state,
                                                                                            amplitude:
                                                                                                amplitude,
                                                                                            isMuted:
                                                                                                isMuted,
                                                                                            size:
                                                                                                orbSize,
                                                                                            onTap: widget
                                                                                                .controller
                                                                                                .toggleVoiceInteraction,
                                                                                        ),
                                                                                        const SizedBox(
                                                                                            height:
                                                                                                18,
                                                                                        ),
                                                                                        WaveformVisualizer(
                                                                                            state:
                                                                                                state,
                                                                                            amplitude:
                                                                                                amplitude,
                                                                                            isMuted:
                                                                                                isMuted,
                                                                                            width:
                                                                                                waveWidth,
                                                                                            height:
                                                                                                52,
                                                                                        ),
                                                                                        const SizedBox(
                                                                                            height:
                                                                                                18,
                                                                                        ),
                                                                                        AnimatedSwitcher(
                                                                                            duration:
                                                                                                const Duration(
                                                                                                milliseconds:
                                                                                                    220,
                                                                                            ),
                                                                                            child:
                                                                                                Text(
                                                                                                isMuted &&
                                                                                                        state ==
                                                                                                            AssistantState
                                                                                                                .listening
                                                                                                    ? 'Microphone Muted'
                                                                                                    : state
                                                                                                        .displayLabel,
                                                                                                key: ValueKey<
                                                                                                    String>(
                                                                                                    '${state.name}_$isMuted',
                                                                                                ),
                                                                                                style:
                                                                                                    const TextStyle(
                                                                                                    fontSize:
                                                                                                        20,
                                                                                                    fontWeight:
                                                                                                        FontWeight
                                                                                                            .w500,
                                                                                                    letterSpacing:
                                                                                                        0.4,
                                                                                                    color: Color(
                                                                                                        0xFFF1F5F9,
                                                                                                    ),
                                                                                                ),
                                                                                            ),
                                                                                        ),
                                                                                        const SizedBox(
                                                                                            height:
                                                                                                6,
                                                                                        ),
                                                                                        ConstrainedBox(
                                                                                            constraints:
                                                                                                const BoxConstraints(
                                                                                                maxWidth:
                                                                                                    460,
                                                                                            ),
                                                                                            child:
                                                                                                Text(
                                                                                                subtitleText,
                                                                                                maxLines:
                                                                                                    2,
                                                                                                overflow:
                                                                                                    TextOverflow
                                                                                                        .ellipsis,
                                                                                                textAlign:
                                                                                                    TextAlign
                                                                                                        .center,
                                                                                                style:
                                                                                                    const TextStyle(
                                                                                                    fontSize:
                                                                                                        13,
                                                                                                    color: Color(
                                                                                                        0xFF64748B,
                                                                                                    ),
                                                                                                ),
                                                                                            ),
                                                                                        ),
                                                                                        ToolActivityIndicator(
                                                                                            toolActivity: widget
                                                                                                .controller
                                                                                                .activeTool,
                                                                                        ),
                                                                                    ],
                                                                                ),
                                                                            ),
                                                                        ),
                                                                    ),

                                                                    // 3. Bottom Microphone Control & Connection Footer
                                                                    Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize
                                                                                .min,
                                                                        children: [
                                                                            if (widget
                                                                                    .controller
                                                                                    .activeError !=
                                                                                null) ...[
                                                                                ErrorBanner(
                                                                                    error: widget
                                                                                        .controller
                                                                                        .activeError,
                                                                                    onRetry: widget
                                                                                        .controller
                                                                                        .reconnect,
                                                                                    onDismiss: widget
                                                                                        .controller
                                                                                        .dismissError,
                                                                                ),
                                                                                const SizedBox(
                                                                                    height:
                                                                                        18,
                                                                                ),
                                                                            ],
                                                                            MicrophoneControl(
                                                                                state:
                                                                                    state,
                                                                                isMuted:
                                                                                    isMuted,
                                                                                onPrimaryAction: widget
                                                                                    .controller
                                                                                    .toggleVoiceInteraction,
                                                                                onMuteToggle: widget
                                                                                    .controller
                                                                                    .toggleMute,
                                                                                toggleVoiceShortcutLabel:
                                                                                    toggleVoiceKeyLabel,
                                                                                muteShortcutLabel:
                                                                                    muteKeyLabel,
                                                                            ),
                                                                            const SizedBox(
                                                                                height:
                                                                                    14,
                                                                            ),
                                                                            Text(
                                                                                connection
                                                                                    .label,
                                                                                style:
                                                                                    const TextStyle(
                                                                                    fontSize:
                                                                                        12,
                                                                                    letterSpacing:
                                                                                        0.3,
                                                                                    color: Color(
                                                                                        0xFF475569,
                                                                                    ),
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),

                                                    // Left Bottom Side Settings Icon for Frontend Keyboard Shortcuts
                                                    Positioned(
                                                        left: 32,
                                                        bottom: 24,
                                                        child: SafeArea(
                                                            child: IconButton(
                                                                onPressed:
                                                                    _openKeyboardShortcutsDialog,
                                                                tooltip:
                                                                    'Keyboard Shortcuts (${shortcuts.summaryLabel()})',
                                                                icon: const Icon(
                                                                    Icons
                                                                        .keyboard_command_key_rounded,
                                                                    size: 18,
                                                                    color: Color(
                                                                        0xFF94A3B8,
                                                                    ),
                                                                ),
                                                                constraints:
                                                                    const BoxConstraints(
                                                                    minWidth:
                                                                        32,
                                                                    minHeight:
                                                                        32,
                                                                ),
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                            ),
                                                        ),
                                                    ),
                                                ],
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
