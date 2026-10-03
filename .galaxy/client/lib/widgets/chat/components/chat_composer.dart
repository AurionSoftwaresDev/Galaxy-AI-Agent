import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern, auto-adjusting chat composer card featuring mathematical height scaling,
/// multi-row prompt capability, live row/char counter, and quick clear action.
class ChatComposer extends StatelessWidget {
    final TextEditingController inputController;
    final FocusNode inputFocusNode;
    final VoidCallback onSubmit;

    const ChatComposer({
        super.key,
        required this.inputController,
        required this.inputFocusNode,
        required this.onSubmit,
    });

    /// Mathematical calculation for dynamic chatbox height based on prompt length and rows.
    /// Increases height by up to 100 for long prompts, or automatically scales via math.
    static double calculateChatBoxHeight(String text) {
        const double baseHeight = 44.0;
        const double maxHeight = 144.0; // baseHeight + 100

        if (text.isEmpty) {
            return baseHeight;
        }

        // Count manual line breaks in user prompt
        final int explicitLines = text.split('\n').length;

        // Approximate wrapped rows based on chat panel width (~30 chars per row)
        final int approxWrappedLines = (text.length / 30).ceil();
        final int calculatedLines = math.max(explicitLines, approxWrappedLines);

        // "You can use maths to increase the chatbox height by 100. If else, use maths to increase the chatbox height automatically."
        if (calculatedLines >= 5 || text.length >= 120) {
            return maxHeight;
        } else if (calculatedLines > 1 || text.length > 25) {
            final double dynamicGrowth =
                ((calculatedLines - 1) * 25.0) + (text.length / 8.0);
            return (baseHeight + dynamicGrowth).clamp(baseHeight, maxHeight);
        } else {
            return baseHeight;
        }
    }

    @override
    Widget build(BuildContext context) {
        final currentText = inputController.text;
        final hasText = currentText.trim().isNotEmpty;
        final lineBreaks =
            currentText.isEmpty ? 0 : currentText.split('\n').length;
        final charCount = currentText.length;
        final double calculatedHeight = calculateChatBoxHeight(currentText);

        return Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: const BoxDecoration(
                color: Color(0xFF090D16),
                border: Border(
                    top: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1,
                    ),
                ),
            ),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: inputFocusNode.hasFocus
                            ? const Color(0xFF06B6D4)
                            : const Color(0xFF1E293B),
                        width: inputFocusNode.hasFocus ? 1.5 : 1,
                    ),
                    boxShadow: [
                        if (inputFocusNode.hasFocus)
                            BoxShadow(
                                color: const Color(0xFF06B6D4)
                                    .withValues(alpha: 0.12),
                                blurRadius: 10,
                                spreadRadius: 1,
                            ),
                    ],
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        // Dynamic mathematical auto-adjusting chatbox
                        AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOutCubic,
                            height: calculatedHeight,
                            child: Focus(
                                onKeyEvent: (node, event) {
                                    if (event is KeyDownEvent &&
                                        event.logicalKey ==
                                            LogicalKeyboardKey.enter) {
                                        if (HardwareKeyboard
                                            .instance.isShiftPressed) {
                                            // Shift+Enter inserts newline without submitting
                                            return KeyEventResult.ignored;
                                        } else {
                                            // Enter submits prompt
                                            onSubmit();
                                            return KeyEventResult.handled;
                                        }
                                    }
                                    return KeyEventResult.ignored;
                                },
                                child: TextField(
                                    controller: inputController,
                                    focusNode: inputFocusNode,
                                    minLines: 1,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.45,
                                        color: Color(0xFFF1F5F9),
                                    ),
                                    decoration: const InputDecoration(
                                        isDense: true,
                                        hintText:
                                            'Message Galaxy AI... (Shift+Enter for newline)',
                                        hintStyle: TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF475569),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 11,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                    ),
                                ),
                            ),
                        ),

                        // Formatting toolbar & interactive action row
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                            ),
                            decoration: const BoxDecoration(
                                color: Color(0xFF0D121F),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(13),
                                    bottomRight: Radius.circular(13),
                                ),
                                border: Border(
                                    top: BorderSide(
                                        color: Color(0xFF1E293B),
                                        width: 0.8,
                                    ),
                                ),
                            ),
                            child: Row(
                                children: [
                                    if (hasText) ...[
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF0F172A),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFF334155),
                                                    width: 0.8,
                                                ),
                                            ),
                                            child: Text(
                                                '$lineBreaks row${lineBreaks > 1 ? 's' : ''} · $charCount char${charCount > 1 ? 's' : ''}',
                                                style: const TextStyle(
                                                    fontSize: 10.5,
                                                    fontFamily:
                                                        'JetBrains Mono',
                                                    color: Color(0xFF22D3EE),
                                                    fontWeight: FontWeight.w500,
                                                ),
                                            ),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                            onTap: () {
                                                inputController.clear();
                                            },
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2,
                                                ),
                                                child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                        Icon(
                                                            Icons.close_rounded,
                                                            size: 13,
                                                            color: Color(
                                                                0xFF94A3B8),
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
                                                            'Clear',
                                                            style: TextStyle(
                                                                fontSize: 10.5,
                                                                color: Color(
                                                                    0xFF94A3B8),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ] else ...[
                                        const Row(
                                            children: [
                                                Icon(
                                                    Icons
                                                        .keyboard_return_rounded,
                                                    size: 13,
                                                    color: Color(0xFF64748B),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                    'Enter to send · Shift+Enter newline',
                                                    style: TextStyle(
                                                        fontSize: 10.5,
                                                        color:
                                                            Color(0xFF64748B),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                    const Spacer(),
                                    Material(
                                        color: hasText
                                            ? const Color(0xFF06B6D4)
                                            : const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(7),
                                        child: InkWell(
                                            onTap: hasText ? onSubmit : null,
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            child: Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                child: Icon(
                                                    Icons.arrow_upward_rounded,
                                                    size: 16,
                                                    color: hasText
                                                        ? const Color(
                                                            0xFF07090E)
                                                        : const Color(
                                                            0xFF64748B),
                                                ),
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
