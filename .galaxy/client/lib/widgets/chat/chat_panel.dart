import 'package:flutter/material.dart';

import '../../models/assistant_state.dart';
import 'components/chat_bubble.dart';
import 'components/chat_composer.dart';
import 'components/quick_prompt_card.dart';
import 'models/default_prompt_item.dart';

export 'components/chat_bubble.dart';
export 'components/chat_composer.dart';
export 'components/quick_prompt_card.dart';
export 'models/default_prompt_item.dart';

/// Left-side desktop chat panel for conversing with Galaxy AI via
/// `WS /ws/assistant` (`{"content": prompt}`) and `POST /agent/generate`.
class ChatPanel extends StatefulWidget {
    final List<ChatMessage> messages;
    final AssistantState assistantState;
    final ValueChanged<String> onSendMessage;
    final VoidCallback onClearHistory;
    final VoidCallback onClosePanel;
    final ValueChanged<bool>? onInputFocusChanged;

    const ChatPanel({
        super.key,
        required this.messages,
        required this.assistantState,
        required this.onSendMessage,
        required this.onClearHistory,
        required this.onClosePanel,
        this.onInputFocusChanged,
    });

    @override
    State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
    final TextEditingController _inputController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final FocusNode _inputFocusNode = FocusNode();

    static const List<DefaultPromptItem> _defaultPrompts = [
        DefaultPromptItem(
            title: 'System Diagnostic & Health',
            prompt:
                'Inspect my system hardware, kernel information, CPU load, and available memory.',
            category: 'System',
            icon: Icons.memory_rounded,
        ),
        DefaultPromptItem(
            title: 'Live Web Intelligence',
            prompt:
                "Perform a live web search for today's breaking AI and tech developments.",
            category: 'Web Search',
            icon: Icons.language_rounded,
        ),
        DefaultPromptItem(
            title: 'File System & Archive Manager',
            prompt:
                'Help me inspect directory trees, manage workspace files, and compress archives.',
            category: 'Files',
            icon: Icons.folder_zip_outlined,
        ),
        DefaultPromptItem(
            title: 'Desktop Terminal Automation',
            prompt:
                'Check active system processes and execute diagnostic commands safely.',
            category: 'Terminal',
            icon: Icons.terminal_rounded,
        ),
    ];

    @override
    void initState() {
        super.initState();
        _inputFocusNode.addListener(_handleFocusChange);
        _inputController.addListener(_handleTextChange);
    }

    void _handleTextChange() {
        if (mounted) {
            setState(() {});
        }
    }

    void _handleFocusChange() {
        if (mounted) {
            setState(() {});
        }
        widget.onInputFocusChanged?.call(_inputFocusNode.hasFocus);
    }

    @override
    void didUpdateWidget(covariant ChatPanel oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (widget.messages.length != oldWidget.messages.length ||
            (widget.messages.isNotEmpty &&
                oldWidget.messages.isNotEmpty &&
                widget.messages.last.content !=
                    oldWidget.messages.last.content)) {
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
        _inputFocusNode.removeListener(_handleFocusChange);
        _inputController.removeListener(_handleTextChange);
        widget.onInputFocusChanged?.call(false);
        _inputController.dispose();
        _scrollController.dispose();
        _inputFocusNode.dispose();
        super.dispose();
    }

    Widget _buildEmptyState() {
        return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: [
                            Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFF22D3EE)
                                            .withValues(alpha: 0.35),
                                    ),
                                ),
                                child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 18,
                                    color: Color(0xFF22D3EE),
                                ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        'Galaxy AI Assistant',
                                        style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE2E8F0),
                                        ),
                                    ),
                                    Text(
                                        'Ready for voice or text interaction',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                        ),
                                    ),
                                ],
                            ),
                        ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        'SUGGESTED ACTIONS',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Color(0xFF475569),
                        ),
                    ),
                    const SizedBox(height: 10),
                    for (final promptItem in _defaultPrompts)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: QuickPromptCard(
                                item: promptItem,
                                onSelect: widget.onSendMessage,
                            ),
                        ),
                ],
            ),
        );
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
                    // 1. Top Panel Header
                    Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                Row(
                                    children: [
                                        // Stylized Chat Logo Badge
                                        Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                        Color(0xFF06B6D4),
                                                        Color(0xFF2563EB),
                                                    ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: const Color(0xFF06B6D4)
                                                            .withValues(alpha: 0.28),
                                                        blurRadius: 8,
                                                    ),
                                                ],
                                            ),
                                            child: const Center(
                                                child: Icon(
                                                    Icons.forum_rounded,
                                                    size: 15,
                                                    color: Color(0xFF07090E),
                                                ),
                                            ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    'Galaxy Chat',
                                                    style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.2,
                                                        color:
                                                            Color(0xFFF1F5F9),
                                                    ),
                                                ),
                                                Text(
                                                    'AI Direct Channel',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        letterSpacing: 0.3,
                                                        color:
                                                            Color(0xFF06B6D4),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        if (widget.messages.isNotEmpty)
                                            IconButton(
                                                onPressed:
                                                    widget.onClearHistory,
                                                tooltip: 'Clear chat history',
                                                icon: const Icon(
                                                    Icons.delete_sweep_outlined,
                                                    size: 17,
                                                    color: Color(0xFF64748B),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
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
                                            constraints:
                                                const BoxConstraints(
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
                                      return ChatBubble(message: msg);
                                  },
                              ),
                    ),

                    // 3. Bottom Composer Input Bar (Auto-expanding with mathematical height scaling)
                    ChatComposer(
                        inputController: _inputController,
                        inputFocusNode: _inputFocusNode,
                        onSubmit: _handleSubmit,
                    ),
                ],
            ),
        );
    }
}
