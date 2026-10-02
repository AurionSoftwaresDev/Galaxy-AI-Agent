import 'package:flutter/material.dart';

import '../models/default_prompt_item.dart';

/// Interactive prompt card featuring hover glow, subtle scale, and a gliding navigation arrow.
class QuickPromptCard extends StatefulWidget {
    final DefaultPromptItem item;
    final ValueChanged<String> onSelect;

    const QuickPromptCard({
        super.key,
        required this.item,
        required this.onSelect,
    });

    @override
    State<QuickPromptCard> createState() => _QuickPromptCardState();
}

class _QuickPromptCardState extends State<QuickPromptCard> {
    bool _isHovered = false;
    bool _isPressed = false;

    @override
    Widget build(BuildContext context) {
        final item = widget.item;

        return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() {
                _isHovered = false;
                _isPressed = false;
            }),
            child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: () => widget.onSelect(item.prompt),
                child: AnimatedScale(
                    scale: _isPressed
                        ? 0.985
                        : _isHovered
                            ? 1.018
                            : 1.0,
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                        ),
                        decoration: BoxDecoration(
                            color: _isHovered
                                ? const Color(0xFF131D31)
                                : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _isHovered
                                    ? const Color(0xFF06B6D4)
                                        .withValues(alpha: 0.6)
                                    : const Color(0xFF1E293B),
                                width: _isHovered ? 1.2 : 1,
                            ),
                            boxShadow: [
                                if (_isHovered)
                                    BoxShadow(
                                        color: const Color(0xFF06B6D4)
                                            .withValues(alpha: 0.12),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                    ),
                            ],
                        ),
                        child: Row(
                            children: [
                                Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: _isHovered
                                            ? const Color(0xFF06B6D4)
                                                .withValues(alpha: 0.18)
                                            : const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: _isHovered
                                                ? const Color(0xFF22D3EE)
                                                    .withValues(alpha: 0.4)
                                                : const Color(0xFF1E293B),
                                        ),
                                    ),
                                    child: Icon(
                                        item.icon,
                                        size: 16,
                                        color: _isHovered
                                            ? const Color(0xFF22D3EE)
                                            : const Color(0xFF06B6D4),
                                    ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Row(
                                                children: [
                                                    Expanded(
                                                        child: Text(
                                                            item.title,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: _isHovered
                                                                    ? const Color(
                                                                        0xFFF8FAFC)
                                                                    : const Color(
                                                                        0xFFE2E8F0),
                                                            ),
                                                        ),
                                                    ),
                                                    Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 5,
                                                            vertical: 1.5,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                            color: const Color(
                                                                0xFF0F172A),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            border: Border.all(
                                                                color:
                                                                    const Color(
                                                                        0xFF1E293B),
                                                            ),
                                                        ),
                                                        child: Text(
                                                            item.category,
                                                            style:
                                                                const TextStyle(
                                                                fontSize: 9.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xFF64748B),
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                                item.prompt,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    height: 1.35,
                                                    color: Color(0xFF64748B),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(width: 6),
                                // Animated navigation arrow that glides forward on hover
                                AnimatedSlide(
                                    offset: _isHovered
                                        ? const Offset(0.22, 0)
                                        : Offset.zero,
                                    duration:
                                        const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    child: AnimatedOpacity(
                                        opacity: _isHovered ? 1.0 : 0.4,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 15,
                                            color: _isHovered
                                                ? const Color(0xFF22D3EE)
                                                : const Color(0xFF64748B),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
