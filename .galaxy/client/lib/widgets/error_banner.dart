import 'package:flutter/material.dart';

import '../models/assistant_state.dart';

/// Clean minimal error feedback banner that never exposes stack traces.
class ErrorBanner extends StatelessWidget {
    final AssistantError? error;
    final VoidCallback onRetry;
    final VoidCallback onDismiss;

    const ErrorBanner({
        super.key,
        required this.error,
        required this.onRetry,
        required this.onDismiss,
    });

    @override
    Widget build(BuildContext context) {
        if (error == null) {
            return const SizedBox.shrink();
        }

        return Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFF111827).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                ),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Color(0xFFF43F5E),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                        child: Text(
                            error!.userMessage,
                            style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFFE2E8F0),
                            ),
                        ),
                    ),
                    if (error!.canRetry) ...[
                        const SizedBox(width: 12),
                        TextButton(
                            onPressed: onRetry,
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
                                'Retry',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ),
                    ],
                    const SizedBox(width: 4),
                    IconButton(
                        onPressed: onDismiss,
                        icon: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Color(0xFF64748B),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                        ),
                    ),
                ],
            ),
        );
    }
}
