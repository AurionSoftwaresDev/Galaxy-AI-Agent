import 'package:flutter/material.dart';

/// Empty state displayed in chat panel when no messages have been sent.
class ChatEmptyState extends StatelessWidget {
    const ChatEmptyState({super.key});

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                                border: Border.all(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                    width: 1.5,
                                ),
                            ),
                            child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFA855F7),
                                size: 26,
                            ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                            'Galaxy AI Ready',
                            style: TextStyle(
                                color: Color(0xFFF8FAFC),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                            'Speak using microphone or type a query to reason, automate tasks, or get real-time voice answers.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                height: 1.4,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
