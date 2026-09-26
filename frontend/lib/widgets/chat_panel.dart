import 'package:flutter/material.dart';

import '../models/assistant_state.dart';

/// Left-side desktop chat panel for conversing with Galaxy AI via
/// `WS /ws/assistant` (`{"content": prompt}`) and `POST /agent/generate`.
class ChatPanel extends StatefulWidget {
    final List<ChatMessage> messages;
    final AssistantState assistantState;
    final ValueChanged<String> onSendMessage;
    final VoidCallback onClearHistory;
    final VoidCallback onClosePanel;

    const ChatPanel({
        super.key,
        required this.messages,
        required this.assistantState,
        required this.onSendMessage,
        required this.onClearHistory,
        required this.onClosePanel,
    });

    @override
    State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
    final TextEditingController _inputController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final FocusNode _inputFocusNode = FocusNode();

    static const List<String> _quickPrompts = [
        'Inspect my system hardware and CPU',
        'What is the current date and time?',
        'Fetch the latest technology news',
    ];

    @override
    void didUpdateWidget(covariant ChatPanel oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (widget.messages.length != oldWidget.messages.length ||
            (widget.messages.isNotEmpty &&
                oldWidget.messages.isNotEmpty &&
                widget.messages.last.content != oldWidget.messages.last.content)) {
            _scrollToBottom();
        }
    }

    void _scrollToBottom() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                );
            }
        });
    }

    void _handleSubmit() {
        final text = _inputController.text.trim();
        if (text.isEmpty) return;
        _inputController.clear();
        widget.onSendMessage(text);
        _inputFocusNode.requestFocus();
    }

    @override
    void dispose() {
        _inputController.dispose();
        _scrollController.dispose();
        _inputFocusNode.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            width: 360,
            decoration: const BoxDecoration(
                color: Color(0xFF0A0D16),
                border: Border(
                    right: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1,
                    ),
                ),
            ),
            child: Column(
                children: [
                    // 1. Panel Header
                    Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFF1E293B),
                                    width: 1,
                                ),
                            ),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                const Row(
                                    children: [
                                        Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 15,
                                            color: Color(0xFF22D3EE),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                            'Chat',
                                            style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                                color: Color(0xFFF1F5F9),
                                            ),
                                        ),
                                    ],
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        if (widget.messages.isNotEmpty)
                                            IconButton(
                                                onPressed: widget.onClearHistory,
                                                tooltip: 'Clear chat history',
                                                icon: const Icon(
                                                    Icons.delete_sweep_outlined,
                                                    size: 17,
                                                    color: Color(0xFF64748B),
                                                ),
                                                constraints: const BoxConstraints(
                                                    minWidth: 28,
                                                    minHeight: 28,
                                                ),
                                                padding: EdgeInsets.zero,
                                            ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                            onPressed: widget.onClosePanel,
                                            tooltip: 'Collapse chat panel',
                                            icon: const Icon(
                                                Icons.chevron_left_rounded,
                                                size: 20,
                                                color: Color(0xFF64748B),
                                            ),
                                            constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28,
                                            ),
                                            padding: EdgeInsets.zero,
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),

                    // 2. Message List or Empty Prompt Starters
                    Expanded(
                        child: widget.messages.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                  ),
                                  itemCount: widget.messages.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                      final msg = widget.messages[index];
                                      return _ChatBubble(message: msg);
                                  },
                              ),
                    ),

                    // 3. Bottom Composer Input Bar
                    Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                        decoration: const BoxDecoration(
                            color: Color(0xFF0B0E17),
                            border: Border(
                                top: BorderSide(
                                    color: Color(0xFF1E293B),
                                    width: 1,
                                ),
                            ),
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    child: TextField(
                                        controller: _inputController,
                                        focusNode: _inputFocusNode,
                                        onSubmitted: (_) => _handleSubmit(),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFF1F5F9),
                                        ),
                                        decoration: InputDecoration(
                                            isDense: true,
                                            hintText: 'Message Galaxy AI...',
                                            hintStyle: const TextStyle(
                                                fontSize: 12.5,
                                                color: Color(0xFF475569),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 11,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF111827),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Color(0xFF1E293B),
                                                ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Color(0xFF06B6D4),
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 8),
                                Material(
                                    color: const Color(0xFF06B6D4),
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                        onTap: _handleSubmit,
                                        borderRadius: BorderRadius.circular(10),
                                        child: const SizedBox(
                                            width: 38,
                                            height: 38,
                                            child: Icon(
                                                Icons.arrow_upward_rounded,
                                                size: 18,
                                                color: Color(0xFF07090E),
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildEmptyState() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                        'Direct Agent Channel',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE2E8F0),
                        ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                        'Send messages over /ws/assistant or use voice mode simultaneously.',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Color(0xFF64748B),
                        ),
                    ),
                    const SizedBox(height: 18),
                    ..._quickPrompts.map(
                        (prompt) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                                onTap: () => widget.onSendMessage(prompt),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF111827),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFF1E293B),
                                        ),
                                    ),
                                    child: Text(
                                        prompt,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFCBD5E1),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}

class _ChatBubble extends StatelessWidget {
    final ChatMessage message;

    const _ChatBubble({required this.message});

    @override
    Widget build(BuildContext context) {
        final isUser = message.role == ChatRole.user;

        return Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        isUser ? 'You' : 'Galaxy AI',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isUser
                                ? const Color(0xFF64748B)
                                : const Color(0xFF22D3EE),
                        ),
                    ),
                ),
                Container(
                    constraints: const BoxConstraints(maxWidth: 295),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                    ),
                    decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF0E7490).withValues(alpha: 0.28)
                            : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: message.isError
                                ? const Color(0xFFF43F5E).withValues(alpha: 0.45)
                                : isUser
                                    ? const Color(0xFF06B6D4)
                                        .withValues(alpha: 0.35)
                                    : const Color(0xFF1E293B),
                        ),
                    ),
                    child: message.content.isEmpty && message.isStreaming
                        ? const SizedBox(
                              height: 18,
                              width: 36,
                              child: Center(
                                  child: LinearProgressIndicator(
                                      minHeight: 2,
                                      backgroundColor: Color(0xFF1E293B),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF22D3EE),
                                      ),
                                  ),
                              ),
                          )
                        : Text(
                              message.content,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.48,
                                  color: message.isError
                                      ? const Color(0xFFFDA4AF)
                                      : const Color(0xFFE2E8F0),
                              ),
                          ),
                ),
            ],
        );
    }
}
