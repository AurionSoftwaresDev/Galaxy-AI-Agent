import 'package:flutter/material.dart';

import '../../../models/assistant_state.dart';

/// Card component inside SettingsDialog for server host URL configuration
/// and server disconnect / termination control (`/server/desktop/disconnect`).
class ServerEndpointCard extends StatelessWidget {
    final TextEditingController baseUrlController;
    final ConnectionStatus connectionStatus;
    final bool isDisconnecting;
    final String? serverActionFeedback;
    final VoidCallback onConnect;
    final VoidCallback onDisconnect;

    const ServerEndpointCard({
        super.key,
        required this.baseUrlController,
        required this.connectionStatus,
        required this.isDisconnecting,
        required this.serverActionFeedback,
        required this.onConnect,
        required this.onDisconnect,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                                controller: baseUrlController,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFFF1F5F9),
                                ),
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF111827),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1E293B),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                            onPressed: onConnect,
                            style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF22D3EE),
                            ),
                            child: const Text(
                                'Connect',
                                style: TextStyle(fontSize: 12),
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 8),

                // Server Disconnect / Kill Option (/server/desktop/disconnect)
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                    ),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF1E293B),
                        ),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                    Row(
                                        children: [
                                            Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                    color: connectionStatus ==
                                                            ConnectionStatus
                                                                .connected
                                                        ? const Color(
                                                            0xFF10B981)
                                                        : const Color(
                                                            0xFF64748B),
                                                    shape: BoxShape.circle,
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                                'Status: ${connectionStatus.label}',
                                                style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF94A3B8),
                                                ),
                                            ),
                                        ],
                                    ),
                                    ElevatedButton.icon(
                                        onPressed: isDisconnecting
                                            ? null
                                            : onDisconnect,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                    0xFFE11D48)
                                                .withValues(alpha: 0.18),
                                            foregroundColor:
                                                const Color(0xFFFDA4AF),
                                            elevation: 0,
                                            side: const BorderSide(
                                                color: Color(0xFFF43F5E),
                                                width: 1,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                        ),
                                        icon: isDisconnecting
                                            ? const SizedBox(
                                                  width: 11,
                                                  height: 11,
                                                  child:
                                                      CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: Color(0xFFFDA4AF),
                                                  ),
                                              )
                                            : const Icon(
                                                  Icons
                                                      .power_settings_new_rounded,
                                                  size: 13,
                                              ),
                                        label: Text(
                                            isDisconnecting
                                                ? 'Killing...'
                                                : 'Disconnect / Kill Server',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                            const SizedBox(height: 5),
                            const Text(
                                'Kill endpoint: /server/desktop/disconnect',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF64748B),
                                ),
                            ),
                            if (serverActionFeedback != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                    serverActionFeedback!,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFF43F5E),
                                        fontWeight: FontWeight.w500,
                                    ),
                                ),
                            ],
                        ],
                    ),
                ),
            ],
        );
    }
}
