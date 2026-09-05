import 'package:flutter/material.dart';
import '../../api/backend_client.dart';

/// Pill showing FastAPI connection state with colored dot and retry-on-click action.
class ConnectionStatusBadge extends StatelessWidget {
    final ConnectionStatus connectionStatus;
    final String connectionLabel;
    final VoidCallback? onRetryConnection;

    const ConnectionStatusBadge({
        super.key,
        required this.connectionStatus,
        required this.connectionLabel,
        this.onRetryConnection,
    });

    @override
    Widget build(BuildContext context) {
        Color dotColor;
        switch (connectionStatus) {
            case ConnectionStatus.connected:
                dotColor = const Color(0xFF10B981);
                break;
            case ConnectionStatus.connecting:
                dotColor = const Color(0xFF38BDF8);
                break;
            case ConnectionStatus.error:
                dotColor = const Color(0xFFEF4444);
                break;
            case ConnectionStatus.disconnected:
                dotColor = const Color(0xFF64748B);
                break;
        }

        return InkWell(
            onTap: (connectionStatus == ConnectionStatus.disconnected ||
                    connectionStatus == ConnectionStatus.error)
                ? onRetryConnection
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF334155).withValues(alpha: 0.5),
                        width: 0.8,
                    ),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dotColor,
                                boxShadow: [
                                    BoxShadow(
                                        color: dotColor.withValues(alpha: 0.6),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                    ),
                                ],
                            ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                            connectionLabel,
                            style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
