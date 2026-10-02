import 'package:flutter/material.dart';

import '../../models/assistant_state.dart';
import '../../widgets/status_indicator.dart';

/// Top header of the central Voice Stage in MainScreen.
class VoiceStageHeader extends StatelessWidget {
    final bool isChatPanelOpen;
    final ConnectionStatus connectionStatus;
    final VoidCallback onToggleChat;
    final VoidCallback onOpenSettings;
    final VoidCallback onReconnect;

    const VoiceStageHeader({
        super.key,
        required this.isChatPanelOpen,
        required this.connectionStatus,
        required this.onToggleChat,
        required this.onOpenSettings,
        required this.onReconnect,
    });

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Row(
                    children: [
                        if (!isChatPanelOpen) ...[
                            IconButton(
                                onPressed: onToggleChat,
                                tooltip: 'Expand chat panel',
                                icon: const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 22,
                                    color: Color(0xFF64748B),
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 10),
                        ],
                        const Text(
                            'Galaxy AI',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: Color(0xFFF8FAFC),
                            ),
                        ),
                    ],
                ),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        StatusIndicator(
                            status: connectionStatus,
                            onReconnectRequested: onReconnect,
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                            onPressed: onOpenSettings,
                            tooltip: 'Agent Settings',
                            icon: const Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                        ),
                    ],
                ),
            ],
        );
    }
}
