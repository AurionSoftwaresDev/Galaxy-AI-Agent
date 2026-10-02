import 'package:flutter/material.dart';

import '../../models/assistant_state.dart';
import '../../widgets/microphone_control.dart';

/// Bottom footer of the Voice Stage in MainScreen including the microphone control,
/// connection status, and bottom-left keyboard shortcuts trigger.
class VoiceStageFooter extends StatelessWidget {
    final AssistantState state;
    final bool isMuted;
    final ConnectionStatus connection;
    final String toggleVoiceKeyLabel;
    final String muteKeyLabel;
    final FrontendShortcutsConfig shortcuts;
    final VoidCallback onToggleVoice;
    final VoidCallback onToggleMute;
    final VoidCallback onOpenShortcutsDialog;

    const VoiceStageFooter({
        super.key,
        required this.state,
        required this.isMuted,
        required this.connection,
        required this.toggleVoiceKeyLabel,
        required this.muteKeyLabel,
        required this.shortcuts,
        required this.onToggleVoice,
        required this.onToggleMute,
        required this.onOpenShortcutsDialog,
    });

    @override
    Widget build(BuildContext context) {
        return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        MicrophoneControl(
                            isListening: state == AssistantState.listening && !isMuted,
                            isMuted: isMuted,
                            onPrimaryAction: onToggleVoice,
                            onMuteToggle: onToggleMute,
                            toggleVoiceShortcutLabel: toggleVoiceKeyLabel,
                            muteShortcutLabel: muteKeyLabel,
                        ),
                        const SizedBox(height: 14),
                        Text(
                            connection.label,
                            style: const TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.3,
                                color: Color(0xFF475569),
                            ),
                        ),
                    ],
                ),
                Positioned(
                    left: 0,
                    bottom: 0,
                    child: IconButton(
                        onPressed: onOpenShortcutsDialog,
                        tooltip: 'Keyboard Shortcuts (${shortcuts.summaryLabel})',
                        icon: const Icon(
                            Icons.keyboard_command_key_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                    ),
                ),
            ],
        );
    }
}
