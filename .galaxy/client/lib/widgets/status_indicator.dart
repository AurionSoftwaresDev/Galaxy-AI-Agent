import 'package:flutter/material.dart';

import '../models/assistant_state.dart';

/// Top header connection status indicator showing Offline, Connecting, or Connected.
class StatusIndicator extends StatelessWidget {
    final ConnectionStatus status;
    final VoidCallback onReconnectRequested;

    const StatusIndicator({
        super.key,
        required this.status,
        required this.onReconnectRequested,
    });

    Color _dotColor() {
        switch (status) {
            case ConnectionStatus.connected:
                return const Color(0xFF10B981);
            case ConnectionStatus.connecting:
                return const Color(0xFFF59E0B);
            case ConnectionStatus.offline:
                return const Color(0xFF64748B);
        }
    }

    @override
    Widget build(BuildContext context) {
        final dotColor = _dotColor();

        return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: status == ConnectionStatus.connected
                            ? [
                                  BoxShadow(
                                      color: dotColor.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                  ),
                              ]
                            : null,
                    ),
                ),
                const SizedBox(width: 8),
                Text(
                    status.label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: Color(0xFF94A3B8),
                    ),
                ),
                if (status == ConnectionStatus.offline) ...[
                    const SizedBox(width: 10),
                    TextButton(
                        onPressed: onReconnectRequested,
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: const Color(0xFF38BDF8),
                        ),
                        child: const Text(
                            'Reconnect',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                    ),
                ],
            ],
        );
    }
}
