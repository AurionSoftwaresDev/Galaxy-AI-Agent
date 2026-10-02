import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/assistant_state.dart';
import '../../state/assistant_controller.dart';
import 'components/shortcut_row_item.dart';

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
                                                    child: ShortcutRowItem(
                                                        action: action,
                                                        shortcuts: shortcuts,
                                                        isRecording:
                                                            recordingAction ==
                                                                action,
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
                                                        onKeySelected: (key) {
                                                            widget.controller
                                                                .updateShortcut(
                                                              action,
                                                              key,
                                                            );
                                                            setState(() {});
                                                        },
                                                        onCancel: () {
                                                            widget.controller
                                                                .setRecordingShortcutAction(
                                                              null,
                                                            );
                                                            setState(() {});
                                                        },
                                                    ),
                                                ),
                                            if (feedbackMessage != null) ...[
                                                const SizedBox(height: 8),
                                                Row(
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
                                                        Text(
                                                            feedbackMessage,
                                                            style:
                                                                const TextStyle(
                                                                fontSize: 11,
                                                                color: Color(
                                                                    0xFF10B981,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                            ),
                                                        ),
                                                    ],
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
