import 'package:flutter/material.dart';
import '../models/assistant_state.dart';

/// Status indicator displayed below the waveform.
///
/// Features clean typography, neon state transitions, and
/// live tool execution feedback without clutter.
class StatusBar extends StatelessWidget {
    final AssistantState state;
    final String subtitle;
    final ToolStatusInfo? toolStatus;
    final VoidCallback? onRetry;

    const StatusBar({
        super.key,
        required this.state,
        required this.subtitle,
        this.toolStatus,
        this.onRetry,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                // Primary State Heading with Neon Glow Accent
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                        key: ValueKey<String>(state.displayName),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Icon(
                                state.icon,
                                size: 18,
                                color: state.neonColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                                state.displayName,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    color: _getTitleColor(),
                                ),
                            ),
                        ],
                    ),
                ),

                const SizedBox(height: 8),

                // Secondary Human-Readable Subtitle or Tool Activity
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                        key: ValueKey<String>(subtitle),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            if (toolStatus != null && (state == AssistantState.thinking || state == AssistantState.toolExecution)) ...[
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                            width: 1,
                                        ),
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            const Icon(
                                                Icons.terminal_rounded,
                                                size: 11,
                                                color: Color(0xFFA78BFA),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                                toolStatus!.toolName,
                                                style: const TextStyle(
                                                    color: Color(0xFFDDD6FE),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'monospace',
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                            Flexible(
                                child: Text(
                                    subtitle,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: _getSubtitleColor(),
                                        letterSpacing: 0.1,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),

                // Reconnect action button when in error or disconnected state
                if (state == AssistantState.error || state == AssistantState.disconnected) ...[
                    const SizedBox(height: 14),
                    TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Reconnect to Backend'),
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF38BDF8),
                            backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                ),
                            ),
                        ),
                    ),
                ],
            ],
        );
    }

    Color _getTitleColor() {
        switch (state) {
            case AssistantState.idle:
                return const Color(0xFFE2E8F0);
            case AssistantState.listening:
                return const Color(0xFFE0F2FE);
            case AssistantState.thinking:
                return const Color(0xFFEDE9FE);
            case AssistantState.toolExecution:
                return const Color(0xFFFEF3C7);
            case AssistantState.generating:
                return const Color(0xFFDBEAFE);
            case AssistantState.speaking:
                return const Color(0xFFECFDF5);
            case AssistantState.interrupted:
                return const Color(0xFFFCE7F3);
            case AssistantState.connecting:
                return const Color(0xFFBAE6FD);
            case AssistantState.error:
                return const Color(0xFFFCA5A5);
            case AssistantState.disconnected:
                return const Color(0xFF94A3B8);
        }
    }

    Color _getSubtitleColor() {
        switch (state) {
            case AssistantState.error:
                return const Color(0xFFF87171);
            default:
                return const Color(0xFF94A3B8);
        }
    }
}
