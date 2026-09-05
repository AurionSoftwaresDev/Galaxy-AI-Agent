import 'package:flutter/material.dart';
import '../../models/assistant_state.dart';

/// Live neon pill reflecting the assistant's active state (Thinking, Speaking, Ready, etc.).
class StatePill extends StatelessWidget {
    final AssistantState state;

    const StatePill({
        super.key,
        required this.state,
    });

    @override
    Widget build(BuildContext context) {
        final color = state.neonColor;

        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 1.0,
                ),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(
                        state.icon,
                        size: 13,
                        color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                        state.displayName,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ],
            ),
        );
    }
}
