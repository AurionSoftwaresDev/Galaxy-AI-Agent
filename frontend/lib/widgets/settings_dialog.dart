import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/assistant_state.dart';
import '../state/assistant_controller.dart';

/// Minimal dark glassmorphic dialog for configuring the backend `/settings/*` endpoints:
/// - `GET /settings/avaliable-providers`
/// - `GET /settings/avaliable-models`
/// - `PATCH /settings/change-agent-provider`
/// - `PATCH /settings/change-agent-temperature`
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

    @override
    Widget build(BuildContext context) {
        return AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
                final settings = widget.controller.settings;
                final providers = settings.availableProviders;
                final models = settings.availableModels;
                final shortcuts = widget.controller.shortcuts;
                final recordingAction =
                    widget.controller.recordingShortcutAction;

                return PopScope(
                    canPop: recordingAction == null,
                    child: Focus(
                        focusNode: _shortcutFocusNode,
                        autofocus: true,
                        onKeyEvent: _handleDialogKeyEvent,
                        child: Dialog(
                            backgroundColor: const Color(0xFF0B0E17),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side:
                                    const BorderSide(color: Color(0xFF1E293B)),
                            ),
                            child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 460),
                                child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                        children: [
                                            const Text(
                                                'Galaxy AI Backend Settings',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFF8FAFC),
                                                ),
                                            ),
                                            IconButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                icon: const Icon(
                                                    Icons.close_rounded,
                                                    size: 18,
                                                    color: Color(0xFF64748B),
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                    minWidth: 28,
                                                    minHeight: 28,
                                                ),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 18),

                                    // 1. Server Host URL (`http://127.0.0.1:8000`)
                                    const Text(
                                        'FastAPI Server Endpoint',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                        ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                        children: [
                                            Expanded(
                                                child: TextField(
                                                    controller: _baseUrlController,
                                                    style: const TextStyle(
                                                        fontSize: 12.5,
                                                        color: Color(0xFFF1F5F9),
                                                    ),
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 10,
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            const Color(0xFF111827),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                            borderSide:
                                                                const BorderSide(
                                                                color: Color(0xFF1E293B),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                                onPressed: () {
                                                    widget.controller
                                                        .updateBackendBaseUrl(
                                                        _baseUrlController.text,
                                                    );
                                                },
                                                style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFF22D3EE),
                                                ),
                                                child: const Text(
                                                    'Connect',
                                                    style: TextStyle(fontSize: 12),
                                                ),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 18),

                                    // 2. LLM Provider Selector (`/settings/change-agent-provider`)
                                    const Text(
                                        'LLM Provider (/settings/change-agent-provider)',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                        ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF111827),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                                color: const Color(0xFF1E293B),
                                            ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                                value: providers.contains(_selectedProvider)
                                                    ? _selectedProvider
                                                    : (providers.isNotEmpty
                                                        ? providers.first
                                                        : null),
                                                isExpanded: true,
                                                dropdownColor:
                                                    const Color(0xFF111827),
                                                hint: const Text(
                                                    'Connect backend to load providers',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF64748B),
                                                    ),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: Color(0xFFF1F5F9),
                                                ),
                                                items: providers
                                                    .map(
                                                        (provider) =>
                                                            DropdownMenuItem<String>(
                                                            value: provider,
                                                            child: Text(provider),
                                                        ),
                                                    )
                                                    .toList(),
                                                onChanged: _isSaving
                                                    ? null
                                                    : _handleProviderChanged,
                                            ),
                                        ),
                                    ),

                                    if (models.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                            'Configured Models: ${models.join(' · ')}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                            ),
                                        ),
                                    ],
                                    const SizedBox(height: 18),

                                    // 3. Temperature Slider (`/settings/change-agent-temperature`)
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                            const Text(
                                                'Agent Temperature',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF94A3B8),
                                                ),
                                            ),
                                            Text(
                                                _temperature.toStringAsFixed(2),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF22D3EE),
                                                ),
                                            ),
                                        ],
                                    ),
                                    SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                            activeTrackColor:
                                                const Color(0xFF06B6D4),
                                            inactiveTrackColor:
                                                const Color(0xFF1E293B),
                                            thumbColor: const Color(0xFF22D3EE),
                                        ),
                                        child: Slider(
                                            value: _temperature.clamp(0.0, 1.0),
                                            min: 0.0,
                                            max: 1.0,
                                            divisions: 20,
                                            onChanged: (val) =>
                                                setState(() => _temperature = val),
                                            onChangeEnd: _handleTemperatureCommitted,
                                        ),
                                    ),
                                    const SizedBox(height: 12),

                                    // 4. Direct Voice Utterance Dispatch (`/ws/assistant` or `/agent/generate`)
                                    const Text(
                                        'Dispatch Utterance to /ws/assistant',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                        ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                        children: [
                                            Expanded(
                                                child: TextField(
                                                    controller:
                                                        _voicePromptController,
                                                    onSubmitted: (_) =>
                                                        _handleSendPrompt(),
                                                    style: const TextStyle(
                                                        fontSize: 12.5,
                                                        color: Color(0xFFF1F5F9),
                                                    ),
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        hintText:
                                                            'Speak or enter command for Galaxy AI...',
                                                        hintStyle: const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xFF475569),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 10,
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            const Color(0xFF111827),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                            borderSide:
                                                                const BorderSide(
                                                                color: Color(0xFF1E293B),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                                onPressed: _handleSendPrompt,
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF06B6D4),
                                                    foregroundColor:
                                                        const Color(0xFF07090E),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 10,
                                                    ),
                                                ),
                                                child: const Text(
                                                    'Send',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 20),

                                    // 5. Frontend Keyboard Shortcuts Section (Show & Changeable)
                                    Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF080B12),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: const Color(0xFF1E293B),
                                            ),
                                        ),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                                    size: 14,
                                                                    color: Color(
                                                                        0xFF22D3EE,
                                                                    ),
                                                                ),
                                                                SizedBox(
                                                                    width: 6,
                                                                ),
                                                                Text(
                                                                    'Keyboard Shortcuts (Frontend)',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.5,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Color(
                                                                            0xFFF1F5F9,
                                                                        ),
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
                                                                setState(() {});
                                                            },
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(6),
                                                            child: const Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4,
                                                                ),
                                                                child: Text(
                                                                    'Reset Defaults',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Color(
                                                                            0xFF22D3EE,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                const SizedBox(height: 10),
                                                for (final action
                                                    in FrontendShortcutAction
                                                        .values)
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                            bottom: 6,
                                                        ),
                                                        child: InkWell(
                                                            canRequestFocus:
                                                                false,
                                                            onTap: () {
                                                                final nextAction =
                                                                    recordingAction ==
                                                                            action
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
                                                                setState(() {});
                                                            },
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                            child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 8,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                    color: recordingAction ==
                                                                            action
                                                                        ? const Color(
                                                                                0xFF06B6D4)
                                                                            .withValues(
                                                                                alpha:
                                                                                    0.14)
                                                                        : const Color(
                                                                            0xFF111827,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                            8),
                                                                    border:
                                                                        Border.all(
                                                                        color: recordingAction ==
                                                                                action
                                                                            ? const Color(
                                                                                0xFF22D3EE,
                                                                            )
                                                                            : const Color(
                                                                                0xFF1E293B,
                                                                            ),
                                                                    ),
                                                                ),
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                        Expanded(
                                                                            child: Text(
                                                                                action.label,
                                                                                style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                    color: Color(0xFFE2E8F0),
                                                                                ),
                                                                            ),
                                                                        ),
                                                                        Container(
                                                                            padding: const EdgeInsets.symmetric(
                                                                                horizontal:
                                                                                    10,
                                                                                vertical:
                                                                                    4,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                                color: recordingAction ==
                                                                                        action
                                                                                    ? const Color(
                                                                                        0xFF06B6D4,
                                                                                    )
                                                                                    : const Color(
                                                                                        0xFF0B0E17,
                                                                                    ),
                                                                                borderRadius: BorderRadius.circular(
                                                                                    6,
                                                                                ),
                                                                                border: Border.all(
                                                                                    color: recordingAction ==
                                                                                            action
                                                                                        ? const Color(
                                                                                            0xFF22D3EE,
                                                                                        )
                                                                                        : const Color(
                                                                                            0xFF334155,
                                                                                        ),
                                                                                ),
                                                                            ),
                                                                            child: Text(
                                                                                recordingAction ==
                                                                                        action
                                                                                    ? 'Press any key...'
                                                                                    : shortcuts.labelFor(
                                                                                        action,
                                                                                    ),
                                                                                style: TextStyle(
                                                                                    fontSize:
                                                                                        11.5,
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .w600,
                                                                                    fontFamily:
                                                                                        'monospace',
                                                                                    color: recordingAction ==
                                                                                            action
                                                                                        ? const Color(
                                                                                            0xFF07090E,
                                                                                        )
                                                                                        : const Color(
                                                                                            0xFF22D3EE,
                                                                                        ),
                                                                                ),
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                if (recordingAction != null) ...[
                                                    const SizedBox(height: 8),
                                                    Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                10),
                                                        decoration:
                                                            BoxDecoration(
                                                            color: const Color(
                                                                0xFF0B1320,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                            border: Border.all(
                                                                color: const Color(
                                                                        0xFF22D3EE)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.4),
                                                            ),
                                                        ),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                                Text(
                                                                    'Recording "${recordingAction.label}" — press a key on keyboard or pick below:',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Color(
                                                                            0xFF22D3EE,
                                                                        ),
                                                                    ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8,
                                                                ),
                                                                Wrap(
                                                                    spacing: 6,
                                                                    runSpacing:
                                                                        6,
                                                                    children: [
                                                                        for (final presetKey
                                                                            in FrontendShortcutsConfig
                                                                                .presetKeys)
                                                                            InkWell(
                                                                                canRequestFocus:
                                                                                    false,
                                                                                onTap: () {
                                                                                    widget.controller.updateShortcut(
                                                                                        recordingAction,
                                                                                        presetKey,
                                                                                    );
                                                                                    setState(() {});
                                                                                },
                                                                                borderRadius:
                                                                                    BorderRadius.circular(5),
                                                                                child: Container(
                                                                                    padding: const EdgeInsets.symmetric(
                                                                                        horizontal: 8,
                                                                                        vertical: 4,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                        color: const Color(0xFF111827),
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        border: Border.all(
                                                                                            color: const Color(0xFF334155),
                                                                                        ),
                                                                                    ),
                                                                                    child: Text(
                                                                                        FrontendShortcutsConfig.formatKeyLabel(presetKey),
                                                                                        style: const TextStyle(
                                                                                            fontSize: 11,
                                                                                            fontFamily: 'monospace',
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Color(0xFFF8FAFC),
                                                                                        ),
                                                                                    ),
                                                                                ),
                                                                            ),
                                                                    ],
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ],
                                                if (widget.controller
                                                        .shortcutFeedbackMessage !=
                                                    null) ...[
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        widget.controller
                                                            .shortcutFeedbackMessage!,
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xFF10B981,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                        ),
                                                    ),
                                                ],
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ),
        );
    },
);
    }
}

/// Frontend-only Keyboard Shortcuts Settings dialog opened from the
/// Left Bottom Side icon on the Main Screen.
class KeyboardShortcutsDialog extends StatefulWidget {
    final AssistantController controller;

    const KeyboardShortcutsDialog({
        super.key,
        required this.controller,
    });

    @override
    State<KeyboardShortcutsDialog> createState() =>
        _KeyboardShortcutsDialogState();
}

class _KeyboardShortcutsDialogState extends State<KeyboardShortcutsDialog> {
    final FocusNode _shortcutFocusNode = FocusNode();

    @override
    void initState() {
        super.initState();
        HardwareKeyboard.instance.addHandler(_handleHardwareKey);
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
                _shortcutFocusNode.requestFocus();
            }
        });
    }

    @override
    void dispose() {
        HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
        widget.controller.cancelRecordingShortcutSilently();
        _shortcutFocusNode.dispose();
        super.dispose();
    }

    bool _handleHardwareKey(KeyEvent event) {
        if (event is! KeyDownEvent) {
            return false;
        }
        final recording = widget.controller.recordingShortcutAction;
        if (recording == null) {
            return false;
        }
        if (FrontendShortcutsConfig.isModifierKey(event.logicalKey)) {
            return true;
        }
        widget.controller.updateShortcut(recording, event.logicalKey);
        if (mounted) {
            setState(() {});
        }
        return true;
    }

    KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent) {
            return KeyEventResult.ignored;
        }
        final recording = widget.controller.recordingShortcutAction;
        if (recording == null) {
            return KeyEventResult.ignored;
        }
        if (FrontendShortcutsConfig.isModifierKey(event.logicalKey)) {
            return KeyEventResult.handled;
        }
        widget.controller.updateShortcut(recording, event.logicalKey);
        if (mounted) {
            setState(() {});
        }
        return KeyEventResult.handled;
    }

    @override
    Widget build(BuildContext context) {
        return PopScope(
            canPop: !widget.controller.isRecordingShortcut,
            child: Focus(
                focusNode: _shortcutFocusNode,
                autofocus: true,
                onKeyEvent: _handleKeyEvent,
                child: Dialog(
                    backgroundColor: const Color(0xFF0B0E17),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF1E293B)),
                    ),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: AnimatedBuilder(
                                animation: widget.controller,
                                builder: (context, _) {
                                    final shortcuts =
                                        widget.controller.shortcuts;
                                    final recordingAction = widget
                                        .controller.recordingShortcutAction;
                                    final feedbackMessage = widget
                                        .controller.shortcutFeedbackMessage;

                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                                size: 16,
                                                                color: Color(
                                                                    0xFF22D3EE,
                                                                ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                                'Keyboard Shortcuts',
                                                                style:
                                                                    TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Color(
                                                                        0xFFF8FAFC,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                    Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
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
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4,
                                                                    ),
                                                                    child: Text(
                                                                        'Reset Defaults',
                                                                        style:
                                                                            TextStyle(
                                                                            fontSize:
                                                                                11.5,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color:
                                                                                Color(0xFF22D3EE),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6,
                                                            ),
                                                            InkWell(
                                                                canRequestFocus:
                                                                    false,
                                                                onTap: () {
                                                                    widget
                                                                        .controller
                                                                        .cancelRecordingShortcutSilently();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                },
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                                child:
                                                                    const Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(
                                                                                4),
                                                                    child: Icon(
                                                                        Icons
                                                                            .close_rounded,
                                                                        size:
                                                                            18,
                                                                        color: Color(
                                                                            0xFF94A3B8,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                                'Click any frontend shortcut below, then press a key (or pick a quick key) to change it.',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                ),
                                            ),
                                            const SizedBox(height: 16),
                                            for (final action
                                                in FrontendShortcutAction
                                                    .values)
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                        bottom: 8,
                                                    ),
                                                    child: InkWell(
                                                        canRequestFocus: false,
                                                        onTap: () {
                                                            final nextAction =
                                                                recordingAction ==
                                                                        action
                                                                    ? null
                                                                    : action;
                                                            widget.controller
                                                                .setRecordingShortcutAction(
                                                                nextAction,
                                                            );
                                                            if (nextAction !=
                                                                null) {
                                                                _shortcutFocusNode
                                                                    .requestFocus();
                                                            }
                                                            setState(() {});
                                                        },
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                8,
                                                            ),
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 12,
                                                                vertical: 10,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                                color: recordingAction ==
                                                                        action
                                                                    ? const Color(
                                                                            0xFF06B6D4)
                                                                        .withValues(
                                                                            alpha:
                                                                                0.14)
                                                                    : const Color(
                                                                        0xFF111827,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        8,
                                                                    ),
                                                                border:
                                                                    Border.all(
                                                                    color: recordingAction ==
                                                                            action
                                                                        ? const Color(
                                                                            0xFF22D3EE,
                                                                        )
                                                                        : const Color(
                                                                            0xFF1E293B,
                                                                        ),
                                                                ),
                                                            ),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                    Expanded(
                                                                        child:
                                                                            Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment
                                                                                    .start,
                                                                            children: [
                                                                                Text(
                                                                                    action.label,
                                                                                    style: const TextStyle(
                                                                                        fontSize: 12.5,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Color(0xFFE2E8F0),
                                                                                    ),
                                                                                ),
                                                                                const SizedBox(
                                                                                    height: 2,
                                                                                ),
                                                                                Text(
                                                                                    action.description,
                                                                                    style: const TextStyle(
                                                                                        fontSize: 11,
                                                                                        color: Color(0xFF64748B),
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                    ),
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                5,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                            color: recordingAction ==
                                                                                    action
                                                                                ? const Color(
                                                                                    0xFF06B6D4,
                                                                                )
                                                                                : const Color(
                                                                                    0xFF0B0E17,
                                                                                ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                                6,
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                                color: recordingAction ==
                                                                                        action
                                                                                    ? const Color(
                                                                                        0xFF22D3EE,
                                                                                    )
                                                                                    : const Color(
                                                                                        0xFF334155,
                                                                                    ),
                                                                            ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                            recordingAction ==
                                                                                    action
                                                                                ? 'Press any key...'
                                                                                : shortcuts
                                                                                    .labelFor(
                                                                                    action,
                                                                                ),
                                                                            style:
                                                                                TextStyle(
                                                                                fontSize:
                                                                                    11.5,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                                fontFamily:
                                                                                    'monospace',
                                                                                color: recordingAction ==
                                                                                        action
                                                                                    ? const Color(
                                                                                        0xFF07090E,
                                                                                    )
                                                                                    : const Color(
                                                                                        0xFF22D3EE,
                                                                                    ),
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            if (recordingAction != null) ...[
                                                const SizedBox(height: 6),
                                                Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFF0B1320,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: const Color(
                                                                    0xFF22D3EE)
                                                                .withValues(
                                                                    alpha: 0.4),
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
                                                                    Expanded(
                                                                        child:
                                                                            Text(
                                                                            'Listening for key for "${recordingAction.label}" — or click a key:',
                                                                            style:
                                                                                const TextStyle(
                                                                                fontSize:
                                                                                    11,
                                                                                color:
                                                                                    Color(0xFF22D3EE),
                                                                                fontWeight:
                                                                                    FontWeight.w500,
                                                                            ),
                                                                        ),
                                                                    ),
                                                                    InkWell(
                                                                        canRequestFocus:
                                                                            false,
                                                                        onTap:
                                                                            () {
                                                                            widget
                                                                                .controller
                                                                                .setRecordingShortcutAction(
                                                                                    null);
                                                                            setState(
                                                                                () {});
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                            'Cancel',
                                                                            style:
                                                                                TextStyle(
                                                                                fontSize:
                                                                                    11,
                                                                                color:
                                                                                    Color(0xFF94A3B8),
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                            const SizedBox(
                                                                height: 8,
                                                            ),
                                                            Wrap(
                                                                spacing: 6,
                                                                runSpacing: 6,
                                                                children: [
                                                                    for (final presetKey
                                                                        in FrontendShortcutsConfig
                                                                            .presetKeys)
                                                                        InkWell(
                                                                            canRequestFocus:
                                                                                false,
                                                                            onTap:
                                                                                () {
                                                                                widget.controller.updateShortcut(
                                                                                    recordingAction,
                                                                                    presetKey,
                                                                                );
                                                                                setState(() {});
                                                                            },
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            child:
                                                                                Container(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                    horizontal: 9,
                                                                                    vertical: 5,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                    color: const Color(0xFF111827),
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    border: Border.all(
                                                                                        color: const Color(0xFF334155),
                                                                                    ),
                                                                                ),
                                                                                child: Text(
                                                                                    FrontendShortcutsConfig.formatKeyLabel(presetKey),
                                                                                    style: const TextStyle(
                                                                                        fontSize: 11,
                                                                                        fontFamily: 'monospace',
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Color(0xFFF8FAFC),
                                                                                    ),
                                                                                ),
                                                                            ),
                                                                        ),
                                                                ],
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                            if (feedbackMessage != null) ...[
                                                const SizedBox(height: 10),
                                                Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 7,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                                0xFF10B981)
                                                            .withValues(
                                                                alpha: 0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        border: Border.all(
                                                            color: const Color(
                                                                    0xFF10B981)
                                                                .withValues(
                                                                    alpha:
                                                                        0.35),
                                                        ),
                                                    ),
                                                    child: Row(
                                                        children: [
                                                            const Icon(
                                                                Icons
                                                                    .check_circle_outline_rounded,
                                                                size: 14,
                                                                color: Color(
                                                                    0xFF10B981,
                                                                ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6,
                                                            ),
                                                            Expanded(
                                                                child: Text(
                                                                    feedbackMessage,
                                                                    style:
                                                                        const TextStyle(
                                                                        fontSize:
                                                                            11.5,
                                                                        color: Color(
                                                                            0xFF10B981,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
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

