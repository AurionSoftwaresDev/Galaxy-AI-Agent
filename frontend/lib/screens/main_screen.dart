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

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _keyboardFocusNode.requestFocus();
        });
    }

    @override
    void dispose() {
        _keyboardFocusNode.dispose();
        super.dispose();
    }

    KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent) {
            return KeyEventResult.ignored;
        }

        // Ignore global shortcuts when typing inside a TextField
        final primaryFocus = FocusManager.instance.primaryFocus;
        if (primaryFocus?.context?.widget is EditableText) {
            return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.space) {
            widget.controller.toggleVoiceInteraction();
            return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyM) {
            widget.controller.toggleMute();
            return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.controller.interruptAssistant();
            return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyR) {
            widget.controller.reconnect();
            return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
    }

    void _openSettingsDialog() {
        showDialog<void>(
            context: context,
            builder: (_) => SettingsDialog(controller: widget.controller),
        );
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

                        final subtitleText = (state ==
                                    AssistantState.speaking &&
                                streamingSubtitle.isNotEmpty)
                            ? streamingSubtitle
                            : state.subtitleHint;

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
                                              onClosePanel: widget
                                                  .controller.toggleChatPanel,
                                          )
                                        : const SizedBox.shrink(),
                                ),

                                // Main Voice Interaction Stage
                                Expanded(
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
                                                ],
                                            );
                                        },
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
