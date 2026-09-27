import 'package:flutter/material.dart';

import '../models/assistant_state.dart';

/// Primary desktop microphone control button with hover, focus, and state feedback.
class MicrophoneControl extends StatefulWidget {
    final AssistantState state;
    final bool isMuted;
    final VoidCallback onPrimaryAction;
    final VoidCallback onMuteToggle;
    final String toggleVoiceShortcutLabel;
    final String muteShortcutLabel;

    const MicrophoneControl({
        super.key,
        required this.state,
        required this.isMuted,
        required this.onPrimaryAction,
        required this.onMuteToggle,
        this.toggleVoiceShortcutLabel = 'Space',
        this.muteShortcutLabel = 'M',
    });

    @override
    State<MicrophoneControl> createState() => _MicrophoneControlState();
}

class _MicrophoneControlState extends State<MicrophoneControl> {
    bool _isHovered = false;

    @override
    Widget build(BuildContext context) {
        final isOffline = widget.state == AssistantState.disconnected ||
            widget.state == AssistantState.error;
        final isSpeaking = widget.state == AssistantState.speaking;
        final isActiveMic = widget.state == AssistantState.listening && !widget.isMuted;

        final Color accentColor = isOffline
            ? const Color(0xFF64748B)
            : widget.isMuted
                ? const Color(0xFFF43F5E)
                : const Color(0xFF06B6D4);

        return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: Tooltip(
                        message: isOffline
                            ? 'Reconnect microphone'
                            : widget.isMuted
                                ? 'Unmute Microphone (${widget.toggleVoiceShortcutLabel} / ${widget.muteShortcutLabel})'
                                : 'Mute Microphone (${widget.toggleVoiceShortcutLabel} / ${widget.muteShortcutLabel})',
                        child: Semantics(
                            button: true,
                            label: isOffline
                                ? 'Reconnect microphone'
                                : widget.isMuted
                                    ? 'Unmute microphone'
                                    : 'Mute microphone',
                            child: GestureDetector(
                                onTap: widget.onPrimaryAction,
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isHovered
                                        ? accentColor.withValues(alpha: 0.18)
                                        : const Color(0xFF111827),
                                    border: Border.all(
                                        color: isActiveMic
                                            ? accentColor.withValues(alpha: 0.65)
                                            : const Color(0xFF1E293B),
                                        width: 1.25,
                                    ),
                                    boxShadow: isActiveMic
                                        ? [
                                              BoxShadow(
                                                  color: accentColor.withValues(alpha: 0.22),
                                                  blurRadius: 20,
                                                  spreadRadius: 1,
                                              ),
                                          ]
                                        : null,
                                ),
                                child: Icon(
                                    isOffline
                                        ? Icons.refresh_rounded
                                        : isSpeaking
                                            ? Icons.stop_rounded
                                            : widget.isMuted
                                                ? Icons.mic_off_rounded
                                                : Icons.mic_rounded,
                                    size: 22,
                                    color: isActiveMic
                                        ? const Color(0xFF22D3EE)
                                        : widget.isMuted
                                            ? const Color(0xFFF43F5E)
                                            : const Color(0xFFE2E8F0),
                                ),
                            ),
                        ),
                        ),
                    ),
                ),
            ],
        );
    }
}
