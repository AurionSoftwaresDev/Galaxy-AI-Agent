import 'package:flutter/material.dart';

/// Horizontal scrollable row of quick prompt suggestion chips.
class ChatQuickSuggestions extends StatelessWidget {
    final void Function(String) onSelectSuggestion;

    static const List<String> defaultSuggestions = [
        'Summarize clipboard',
        'Run system health check',
        'Draft update email',
        'What can you do?',
    ];

    final List<String> suggestions;

    const ChatQuickSuggestions({
        super.key,
        required this.onSelectSuggestion,
        this.suggestions = defaultSuggestions,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 34,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return InkWell(
                        onTap: () => onSelectSuggestion(suggestion),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF334155),
                                    width: 0.8,
                                ),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    const Icon(Icons.add_circle_outline_rounded, size: 12, color: Color(0xFF38BDF8)),
                                    const SizedBox(width: 5),
                                    Text(
                                        suggestion,
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
                },
            ),
        );
    }
}
