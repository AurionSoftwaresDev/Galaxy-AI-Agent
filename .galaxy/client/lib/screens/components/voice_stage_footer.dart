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
    final VoidCallback? onOpenSettings;

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
        this.onOpenSettings,
    });

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: double.infinity,
            child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            MicrophoneControl(
                                state: state,
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
                        left: 14,
                        bottom: 10,
                        child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xCC0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0x4D334155),
                                    width: 1,
                                ),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                    ),
                                ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            child: IconButton(
                                onPressed: onOpenShortcutsDialog,
                                tooltip: 'Keyboard Shortcuts (${shortcuts.summaryLabel})',
                                icon: const Icon(
                                    Icons.keyboard_command_key_rounded,
                                    size: 18,
                                    color: Color(0xFF22D3EE),
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}
