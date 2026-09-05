import 'package:flutter/material.dart';
import '../../models/assistant_state.dart';

/// Live state banner shown above the input bar when the assistant is actively thinking or executing tools.
class ChatActiveBanner extends StatelessWidget {
    final AssistantState state;

    const ChatActiveBanner({
        super.key,
        required this.state,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: state.neonColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: state.neonColor.withValues(alpha: 0.35),
                    width: 1,
                ),
            ),
            child: Row(
                children: [
                    SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(state.neonColor),
                        ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            state.displayName,
                            style: TextStyle(
                                color: state.neonColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}
