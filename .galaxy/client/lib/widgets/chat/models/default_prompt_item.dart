import 'package:flutter/material.dart';

/// Structured default prompt card item for quick conversation starters.
class DefaultPromptItem {
    final String title;
    final String prompt;
    final String category;
    final IconData icon;

    const DefaultPromptItem({
        required this.title,
        required this.prompt,
        required this.category,
        required this.icon,
    });
}
