import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/assistant_state.dart';
import '../state/assistant_controller.dart';
import '../widgets/ai_orb.dart';
import '../widgets/ambient_orbs_background.dart';
import '../widgets/automation_sidebar.dart';
import '../widgets/chat_panel.dart';
import '../widgets/controls_bar.dart';
import '../widgets/settings_window.dart';
import '../widgets/status_bar.dart';
import '../widgets/top_bar.dart';
import '../widgets/waveform_visualizer.dart';

/// Primary desktop screen for Galaxy AI.
///
/// Implements responsive desktop window layout with:
/// - Dynamic Ambient Floating Neon Orbs background
/// - Top Navbar with Agent State & User Profile (Initials fallback)
/// - Left Sidebar for Basic Tasks Automation
/// - Center Agent Canvas with Neon Small Dots Swarm & Particle Constellation
/// - Right Collapsible Chat Panel for multi-state agent interaction
/// - In-Window Movable & Resizable Floating Settings Window
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

    bool _isSidebarExpanded = false;
    bool _isChatPanelOpen = true;
    bool _isSettingsOpen = false;

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

    /// Handles desktop keyboard shortcuts
    KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
            // Check if any text input (chat input, settings fields) currently has focus
            final primaryFocus = FocusManager.instance.primaryFocus;
            final isTextInputFocused = primaryFocus != null &&
                (primaryFocus.context?.widget is EditableText ||
                 primaryFocus.context?.findAncestorWidgetOfExactType<EditableText>() != null);

            if (isTextInputFocused) {
                // Pass through all keystrokes naturally to the text input
                return KeyEventResult.ignored;
            }

            // Space: Toggle Mic (only when not typing in a text field)
            if (event.logicalKey == LogicalKeyboardKey.space && !_isSettingsOpen) {
                widget.controller.toggleMicrophone();
                return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                if (_isSettingsOpen) {
                    setState(() => _isSettingsOpen = false);
                    return KeyEventResult.handled;
                }
                widget.controller.interruptSpeaking();
                return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.comma &&
                       (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed)) {
                setState(() => _isSettingsOpen = !_isSettingsOpen);
                return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyR &&
                       (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed)) {
                widget.controller.retryConnection();
                return KeyEventResult.handled;
            }
        }
        return KeyEventResult.ignored;
    }

    @override
    Widget build(BuildContext context) {
        return Focus(
            focusNode: _keyboardFocusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                    final state = widget.controller.state;
                    final audioPacket = widget.controller.currentAudioPacket;
                    final config = widget.controller.agentConfig;
                    final palette = config.themePalette;

                    return Scaffold(
                        backgroundColor: palette.background,
                        body: Stack(
                            children: [
                                // 1. Ambient Floating Background Orbs
                                AmbientOrbsBackground(
                                    state: state,
                                    palette: palette,
                                    isEnabled: config.backgroundOrbsEnabled,
                                ),

                                // 2. Main Desktop Structure
                                SafeArea(
                                    child: Column(
                                        children: [
                                            // Top Navbar with User Section & Settings trigger
                                            TopBar(
                                                connectionStatus: widget.controller.connectionStatus,
                                                connectionLabel: widget.controller.connectionLabel,
                                                assistantState: state,
                                                userProfile: widget.controller.userProfile,
                                                isSidebarExpanded: _isSidebarExpanded,
                                                isChatPanelOpen: _isChatPanelOpen,
                                                onToggleSidebar: () {
                                                    setState(() => _isSidebarExpanded = !_isSidebarExpanded);
                                                },
                                                onToggleChatPanel: () {
                                                    setState(() => _isChatPanelOpen = !_isChatPanelOpen);
                                                },
                                                onOpenSettings: () {
                                                    setState(() => _isSettingsOpen = true);
                                                },
                                                onRetryConnection: () => widget.controller.retryConnection(),
                                            ),

                                            // Main Working Area (Sidebar + Center Canvas + Right Chat)
                                            Expanded(
                                                child: Row(
                                                    children: [
                                                        // Left Sidebar for Basic Tasks Automation with bottom Settings launcher
                                                        AutomationSidebar(
                                                            isExpanded: _isSidebarExpanded,
                                                            state: state,
                                                            isSettingsOpen: _isSettingsOpen,
                                                            activeToolName: widget.controller.currentToolStatus?.toolName,
                                                            onToggleExpand: () {
                                                                setState(() => _isSidebarExpanded = !_isSidebarExpanded);
                                                            },
                                                            onOpenSettings: () {
                                                                setState(() => _isSettingsOpen = true);
                                                            },
                                                            onExecuteTask: (task) {
                                                                widget.controller.executeAutomationTask(task);
                                                                if (!_isChatPanelOpen) {
                                                                    setState(() => _isChatPanelOpen = true);
                                                                }
                                                            },
                                                        ),

                                                        // Center Agent Canvas
                                                        Expanded(
                                                            child: LayoutBuilder(
                                                                builder: (context, constraints) {
                                                                    final isCompact = constraints.maxHeight < 560;

                                                                    return Column(
                                                                        children: [
                                                                            // Upgraded AI Voice Orb: Volumetric Glass & Small Dots Constellation
                                                                            Expanded(
                                                                                child: Center(
                                                                                    child: ConstrainedBox(
                                                                                        constraints: BoxConstraints(
                                                                                            maxWidth: isCompact ? 280 : 340,
                                                                                            maxHeight: isCompact ? 280 : 340,
                                                                                        ),
                                                                                        child: FittedBox(
                                                                                            fit: BoxFit.contain,
                                                                                            child: AiOrb(
                                                                                                state: state,
                                                                                                amplitude: audioPacket.amplitude,
                                                                                                particleCount: config.dotDensity,
                                                                                                onTap: () {
                                                                                                    if (state == AssistantState.error ||
                                                                                                        state == AssistantState.disconnected) {
                                                                                                        widget.controller.retryConnection();
                                                                                                    } else {
                                                                                                        widget.controller.toggleMicrophone();
                                                                                                    }
                                                                                                },
                                                                                            ),
                                                                                        ),
                                                                                    ),
                                                                                ),
                                                                            ),

                                                                            // Audio Waveform Visualizer
                                                                            Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                                                child: WaveformVisualizer(
                                                                                    state: state,
                                                                                    audioPacket: audioPacket,
                                                                                    height: isCompact ? 36 : 48,
                                                                                ),
                                                                            ),

                                                                            SizedBox(height: isCompact ? 8 : 14),

                                                                            // Current State & Feedback
                                                                            Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                                                child: StatusBar(
                                                                                    state: state,
                                                                                    subtitle: widget.controller.statusSubtitle,
                                                                                    toolStatus: widget.controller.currentToolStatus,
                                                                                    onRetry: () => widget.controller.retryConnection(),
                                                                                ),
                                                                            ),

                                                                            SizedBox(height: isCompact ? 10 : 18),

                                                                            // Bottom Controls & Shortcuts Bar
                                                                            Padding(
                                                                                padding: EdgeInsets.only(bottom: isCompact ? 10.0 : 18.0),
                                                                                child: ControlsBar(
                                                                                    state: state,
                                                                                    isMuted: widget.controller.isMuted,
                                                                                    onToggleMic: () => widget.controller.toggleMicrophone(),
                                                                                    onInterrupt: () => widget.controller.interruptSpeaking(),
                                                                                    onCycleState: () => widget.controller.cycleState(),
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    );
                                                                },
                                                            ),
                                                        ),

                                                        // Right Panel for Chat Agent
                                                        if (_isChatPanelOpen)
                                                            ChatPanel(
                                                                messages: widget.controller.messages,
                                                                state: state,
                                                                userProfile: widget.controller.userProfile,
                                                                onSendMessage: (text) => widget.controller.sendMessage(text),
                                                                onClearMessages: () => widget.controller.clearMessages(),
                                                                onClose: () => setState(() => _isChatPanelOpen = false),
                                                                onToggleMic: () => widget.controller.toggleMicrophone(),
                                                                isMuted: widget.controller.isMuted,
                                                            ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                ),

                                // 3. In-Window Movable & Resizable Floating Settings Window Overlay
                                if (_isSettingsOpen)
                                    SettingsWindow(
                                        userProfile: widget.controller.userProfile,
                                        agentConfig: widget.controller.agentConfig,
                                        onSaveUserProfile: (updatedProfile) {
                                            widget.controller.updateUserProfile(updatedProfile);
                                        },
                                        onSaveAgentConfig: (updatedConfig) {
                                            widget.controller.updateAgentConfig(updatedConfig);
                                        },
                                        onClose: () {
                                            setState(() => _isSettingsOpen = false);
                                        },
                                    ),
                            ],
                        ),
                    );
                },
            ),
        );
    }
}
