import 'package:flutter/material.dart';
import '../models/assistant_state.dart';

/// Minimal desktop bottom control panel for Galaxy AI.
///
/// Houses the primary microphone action button, state switcher, shortcut hints,
/// and interrupt controls with neon glow styling.
class ControlsBar extends StatelessWidget {
    final AssistantState state;
    final bool isMuted;
    final VoidCallback onToggleMic;
    final VoidCallback onInterrupt;
    final VoidCallback onCycleState;

    const ControlsBar({
        super.key,
        required this.state,
        required this.isMuted,
        required this.onToggleMic,
        required this.onInterrupt,
        required this.onCycleState,
    });

    @override
    Widget build(BuildContext context) {
        return FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            // State Simulation Switcher (Cycle through multiple states)
                            Tooltip(
                                message: 'Cycle agent state (${state.displayName})',
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: onCycleState,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: state.neonColor.withValues(alpha: 0.4),
                                                    width: 1,
                                                ),
                                            ),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    Icon(Icons.tune_rounded, size: 14, color: state.neonColor),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                        'State: ${state.displayName}',
                                                        style: TextStyle(
                                                            color: state.neonColor,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w500,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),
                                ),
                            ),

                            const SizedBox(width: 18),

                            // Primary Microphone Action Button with Neon Swarm Glow
                            _buildPrimaryActionButton(),

                            const SizedBox(width: 18),

                            // Interrupt Action (Active when assistant is speaking)
                            Tooltip(
                                message: state == AssistantState.speaking
                                    ? 'Stop Assistant Speech (Esc)'
                                    : 'Interrupt playback',
                                child: IconButton(
                                    onPressed: state == AssistantState.speaking ? onInterrupt : null,
                                    icon: const Icon(Icons.stop_circle_outlined, size: 22),
                                    color: state == AssistantState.speaking
                                        ? const Color(0xFFF43F5E)
                                        : const Color(0xFF334155),
                                    splashRadius: 20,
                                ),
                            ),
                        ],
                    ),

                    const SizedBox(height: 10),

                    // Subtle Desktop Keyboard Shortcuts Bar
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            _buildKeyBadge('Space'),
                            const SizedBox(width: 6),
                            const Text(
                                'Toggle Mic',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                            const SizedBox(width: 14),
                            _buildKeyBadge('Esc'),
                            const SizedBox(width: 6),
                            const Text(
                                'Interrupt',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                            const SizedBox(width: 14),
                            _buildKeyBadge('R'),
                            const SizedBox(width: 6),
                            const Text(
                                'Reconnect',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }

    Widget _buildPrimaryActionButton() {
        final bool isListening = state == AssistantState.listening && !isMuted;
        final bool isInteractive = state.canInteract;
        final neonColor = state.neonColor;

        return Tooltip(
            message: isMuted ? 'Unmute Microphone (Space)' : 'Mute Microphone (Space)',
            child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                    onTap: isInteractive ? onToggleMic : null,
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isListening
                                ? neonColor.withValues(alpha: 0.22)
                                : const Color(0xFF0F172A).withValues(alpha: 0.85),
                            border: Border.all(
                                color: isListening ? neonColor : const Color(0xFF334155),
                                width: 1.6,
                            ),
                            boxShadow: isListening
                                ? [
                                    BoxShadow(
                                        color: neonColor.withValues(alpha: 0.45),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                    ),
                                ]
                                : [
                                    BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                    ),
                                ],
                        ),
                        child: Icon(
                            isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            size: 22,
                            color: !isInteractive
                                ? const Color(0xFF475569)
                                : (isListening ? neonColor : const Color(0xFF94A3B8)),
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildKeyBadge(String label) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: const Color(0xFF334155).withValues(alpha: 0.7),
                    width: 0.8,
                ),
            ),
            child: Text(
                label,
                style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                ),
            ),
        );
    }
}
