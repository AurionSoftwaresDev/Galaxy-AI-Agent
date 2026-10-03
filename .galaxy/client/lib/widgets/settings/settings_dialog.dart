import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/assistant_state.dart';
import '../../state/assistant_controller.dart';
import 'components/llm_provider_card.dart';
import 'components/server_endpoint_card.dart';
import 'components/shortcut_row_item.dart';
import 'components/temperature_slider_card.dart';
import 'components/voice_prompt_test_card.dart';

/// Minimal dark glassmorphic dialog for configuring backend `/settings/*` endpoints
/// and frontend shortcuts.
class SettingsDialog extends StatefulWidget {
    final AssistantController controller;

    const SettingsDialog({
        super.key,
        required this.controller,
    });

    @override
    State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
    late final TextEditingController _baseUrlController;
    late final TextEditingController _voicePromptController;
    final FocusNode _shortcutFocusNode = FocusNode();
    late double _temperature;
    String? _selectedProvider;
    bool _isSaving = false;
    bool _isDisconnecting = false;
    String? _serverActionFeedback;

    @override
    void initState() {
        super.initState();
        _baseUrlController = TextEditingController(
            text: widget.controller.backendBaseUrl,
        );
        _voicePromptController = TextEditingController();
        _temperature = widget.controller.settings.temperature;
        _selectedProvider = widget.controller.settings.activeProvider;
        HardwareKeyboard.instance.addHandler(_handleHardwareKey);
        widget.controller.refreshAgentSettings();
    }

    @override
    void dispose() {
        HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
        widget.controller.setRecordingShortcutAction(null, notify: false);
        _shortcutFocusNode.dispose();
        _baseUrlController.dispose();
        _voicePromptController.dispose();
        super.dispose();
    }

    bool _handleHardwareKey(KeyEvent event) {
        final recording = widget.controller.recordingShortcutAction;
        if (recording == null) {
            return false;
        }
        if (event is KeyDownEvent) {
            if (!FrontendShortcutsConfig.isModifierKey(event.logicalKey)) {
                widget.controller.updateShortcut(recording, event.logicalKey);
                if (mounted) {
                    setState(() {});
                }
            }
        }
        return true;
    }

    KeyEventResult _handleDialogKeyEvent(FocusNode node, KeyEvent event) {
        final recording = widget.controller.recordingShortcutAction;
        if (recording == null) {
            return KeyEventResult.ignored;
        }
        if (event is KeyDownEvent &&
            !FrontendShortcutsConfig.isModifierKey(event.logicalKey)) {
            widget.controller.updateShortcut(recording, event.logicalKey);
            if (mounted) {
                setState(() {});
            }
        }
        return KeyEventResult.handled;
    }

    Future<void> _handleProviderChanged(String? nextProvider) async {
        if (nextProvider == null || nextProvider == _selectedProvider) return;
        setState(() {
            _selectedProvider = nextProvider;
            _isSaving = true;
        });
        await widget.controller.changeProvider(nextProvider);
        if (mounted) {
            setState(() => _isSaving = false);
        }
    }

    Future<void> _handleTemperatureCommitted(double value) async {
        setState(() => _isSaving = true);
        await widget.controller.changeTemperature(value);
        if (mounted) {
            setState(() => _isSaving = false);
        }
    }

    Future<void> _handleSendPrompt() async {
        final text = _voicePromptController.text.trim();
        if (text.isEmpty) return;
        _voicePromptController.clear();
        Navigator.of(context).pop();
        await widget.controller.sendVoicePrompt(text);
    }

    Future<void> _handleDisconnectServer() async {
        if (_isDisconnecting) return;
        setState(() {
            _isDisconnecting = true;
            _serverActionFeedback = null;
        });

        final success = await widget.controller.disconnectDesktopServer();

        if (mounted) {
            setState(() {
                _isDisconnecting = false;
                _serverActionFeedback = success
                    ? 'Server shutdown signal sent successfully.'
                    : 'Server disconnect endpoint timed out (server may already be down).';
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return PopScope(
            canPop: !widget.controller.isRecordingShortcut,
            child: Focus(
                focusNode: _shortcutFocusNode,
                autofocus: true,
                onKeyEvent: _handleDialogKeyEvent,
                child: Dialog(
                    backgroundColor: const Color(0xFF0B0E17),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF1E293B)),
                    ),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: AnimatedBuilder(
                                animation: widget.controller,
                                builder: (context, _) {
                                    final settings = widget.controller.settings;
                                    final providers =
                                        settings.availableProviders;
                                    final models = settings.availableModels;
                                    final shortcuts =
                                        widget.controller.shortcuts;
                                    final recordingAction = widget
                                        .controller.recordingShortcutAction;

                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            // Dialog Header
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                    const Text(
                                                        'Galaxy AI Backend Settings',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFFF8FAFC),
                                                        ),
                                                    ),
                                                    IconButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        icon: const Icon(
                                                            Icons.close_rounded,
                                                            size: 18,
                                                            color: Color(
                                                                0xFF64748B),
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(
                                                            minWidth: 28,
                                                            minHeight: 28,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(height: 18),

                                            // 1. Server Host URL & Kill Endpoint Card
                                            ServerEndpointCard(
                                                baseUrlController:
                                                    _baseUrlController,
                                                connectionStatus: widget
                                                    .controller
                                                    .connectionStatus,
                                                isDisconnecting:
                                                    _isDisconnecting,
                                                serverActionFeedback:
                                                    _serverActionFeedback,
                                                onConnect: () {
                                                    widget.controller
                                                        .updateBackendBaseUrl(
                                                        _baseUrlController.text,
                                                    );
                                                },
                                                onDisconnect:
                                                    _handleDisconnectServer,
                                            ),
                                            const SizedBox(height: 18),

                                            // 2. LLM Provider Selector
                                            LlmProviderCard(
                                                providers: providers,
                                                models: models,
                                                selectedProvider:
                                                    _selectedProvider,
                                                isSaving: _isSaving,
                                                onProviderChanged:
                                                    _handleProviderChanged,
                                            ),
                                            const SizedBox(height: 18),

                                            // 3. Temperature Slider
                                            TemperatureSliderCard(
                                                temperature: _temperature,
                                                onChanged: (val) => setState(
                                                    () => _temperature = val),
                                                onChangeEnd:
                                                    _handleTemperatureCommitted,
                                            ),
                                            const SizedBox(height: 12),

                                            // 4. Direct Voice Utterance Dispatch
                                            VoicePromptTestCard(
                                                voicePromptController:
                                                    _voicePromptController,
                                                onSend: _handleSendPrompt,
                                            ),
                                            const SizedBox(height: 20),

                                            // 5. Frontend Keyboard Shortcuts Section
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF080B12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFF1E293B),
                                                    ),
                                                ),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                                const Row(
                                                                    children: [
                                                                        Icon(
                                                                            Icons
                                                                                .keyboard_command_key_rounded,
                                                                            size:
                                                                                14,
                                                                            color:
                                                                                Color(0xFF22D3EE),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                6,
                                                                        ),
                                                                        Text(
                                                                            'Keyboard Shortcuts (Frontend)',
                                                                            style:
                                                                                TextStyle(
                                                                                fontSize: 12.5,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Color(0xFFF1F5F9),
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                                InkWell(
                                                                    canRequestFocus:
                                                                        false,
                                                                    onTap: () {
                                                                        widget
                                                                            .controller
                                                                            .resetShortcutsToDefault();
                                                                        setState(
                                                                            () {});
                                                                    },
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    child:
                                                                        const Padding(
                                                                        padding: EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 8,
                                                                            vertical: 4,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                            'Reset Defaults',
                                                                            style: TextStyle(
                                                                                fontSize: 11,
                                                                                color: Color(0xFF22D3EE),
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        const SizedBox(
                                                            height: 12,
                                                        ),
                                                        for (final action
                                                            in FrontendShortcutAction
                                                                .values)
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                    bottom: 8,
                                                                ),
                                                                child:
                                                                    ShortcutRowItem(
                                                                    action:
                                                                        action,
                                                                    shortcuts:
                                                                        shortcuts,
                                                                    isRecording:
                                                                        recordingAction ==
                                                                            action,
                                                                    onTap: () {
                                                                        final nextAction =
                                                                            recordingAction == action
                                                                                ? null
                                                                                : action;
                                                                        widget
                                                                            .controller
                                                                            .setRecordingShortcutAction(
                                                                          nextAction,
                                                                        );
                                                                        if (nextAction !=
                                                                            null) {
                                                                            _shortcutFocusNode
                                                                                .requestFocus();
                                                                        }
                                                                        setState(
                                                                            () {});
                                                                    },
                                                                    onKeySelected:
                                                                        (key) {
                                                                        widget
                                                                            .controller
                                                                            .updateShortcut(
                                                                          action,
                                                                          key,
                                                                        );
                                                                        setState(
                                                                            () {});
                                                                    },
                                                                    onCancel:
                                                                        () {
                                                                        widget
                                                                            .controller
                                                                            .setRecordingShortcutAction(
                                                                          null,
                                                                        );
                                                                        setState(
                                                                            () {});
                                                                    },
                                                                ),
                                                            ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    );
                                },
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}
