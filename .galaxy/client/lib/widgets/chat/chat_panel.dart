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
    final List<Map<String, dynamic>> chatSessions;
    final int? currentChatId;
    final String currentChatTitle;
    final Future<void> Function([String? title])? onCreateChat;
    final Future<void> Function(int chatId, String title)? onSelectChat;
    final Future<bool> Function(int chatId, String newTitle)? onRenameChat;
    final Future<bool> Function(int chatId, String title)? onDeleteChat;

    const ChatPanel({
        super.key,
        required this.messages,
        required this.assistantState,
        required this.onSendMessage,
        required this.onClearHistory,
        required this.onClosePanel,
        this.onInputFocusChanged,
        this.chatSessions = const [],
        this.currentChatId,
        this.currentChatTitle = 'Untitled Chat',
        this.onCreateChat,
        this.onSelectChat,
        this.onRenameChat,
        this.onDeleteChat,
    });

    @override
    State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
    final TextEditingController _inputController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final FocusNode _inputFocusNode = FocusNode();
    final TextEditingController _searchController = TextEditingController();
    bool _isDrawerOpen = false;

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
        _searchController.addListener(_handleTextChange);
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

    String _formatDate(dynamic raw) {
        if (raw == null) return '';
        final dt = DateTime.tryParse(raw.toString());
        if (dt == null) return raw.toString().substring(0, raw.toString().length > 10 ? 10 : raw.toString().length);
        final now = DateTime.now();
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
            final hour = dt.hour.toString().padLeft(2, '0');
            final min = dt.minute.toString().padLeft(2, '0');
            return '$hour:$min';
        }
        return '${dt.month}/${dt.day}';
    }

    void _showCreateChatDialog() {
        final controller = TextEditingController();
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF0B0E17),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF1E293B)),
                ),
                title: const Text(
                    'New Conversation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9)),
                ),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'Conversation Title',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                            controller: controller,
                            autofocus: true,
                            style: const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9)),
                            decoration: InputDecoration(
                                hintText: 'e.g. Code Review, System Audit...',
                                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                filled: true,
                                fillColor: const Color(0xFF111827),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (val) {
                                Navigator.of(ctx).pop();
                                widget.onCreateChat?.call(val.trim().isEmpty ? 'Untitled Chat' : val.trim());
                            },
                        ),
                    ],
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: const Color(0xFF07090E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                            Navigator.of(ctx).pop();
                            final val = controller.text.trim();
                            widget.onCreateChat?.call(val.isEmpty ? 'Untitled Chat' : val);
                        },
                        child: const Text('Create Chat', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                ],
            ),
        );
    }

    void _showRenameChatDialog(int chatId, String currentTitle) {
        final controller = TextEditingController(text: currentTitle);
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF0B0E17),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF1E293B)),
                ),
                title: const Text(
                    'Rename Conversation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9)),
                ),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'New Title',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                            controller: controller,
                            autofocus: true,
                            style: const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9)),
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF111827),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (val) {
                                Navigator.of(ctx).pop();
                                if (val.trim().isNotEmpty) {
                                    widget.onRenameChat?.call(chatId, val.trim());
                                }
                            },
                        ),
                    ],
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: const Color(0xFF07090E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                            Navigator.of(ctx).pop();
                            final val = controller.text.trim();
                            if (val.isNotEmpty) {
                                widget.onRenameChat?.call(chatId, val);
                            }
                        },
                        child: const Text('Save Title', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                ],
            ),
        );
    }

    void _showDeleteChatDialog(int chatId, String title) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF0B0E17),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF1E293B)),
                ),
                title: const Text(
                    'Delete Conversation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                ),
                content: Text(
                    'Are you sure you want to delete "$title"? All recorded messages will be permanently deleted from the database.',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8), height: 1.4),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                            Navigator.of(ctx).pop();
                            widget.onDeleteChat?.call(chatId, title);
                        },
                        child: const Text('Delete Chat', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                ],
            ),
        );
    }

    @override
    void dispose() {
        _inputFocusNode.removeListener(_handleFocusChange);
        _inputController.removeListener(_handleTextChange);
        _searchController.removeListener(_handleTextChange);
        widget.onInputFocusChanged?.call(false);
        _inputController.dispose();
        _scrollController.dispose();
        _inputFocusNode.dispose();
        _searchController.dispose();
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

                    // 1.5 Sub-Bar for Active Conversation & Quick Controls
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: const BoxDecoration(
                            color: Color(0xFF080C16),
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
                                // Active Chat Pill
                                InkWell(
                                    onTap: () {
                                        setState(() {
                                            _isDrawerOpen = !_isDrawerOpen;
                                        });
                                    },
                                    borderRadius: BorderRadius.circular(7),
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: _isDrawerOpen
                                                ? const Color(0xFF0E7490).withValues(alpha: 0.28)
                                                : const Color(0xFF0F172A).withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(7),
                                            border: Border.all(
                                                color: _isDrawerOpen
                                                    ? const Color(0xFF06B6D4).withValues(alpha: 0.7)
                                                    : const Color(0xFF334155).withValues(alpha: 0.8),
                                            ),
                                        ),
                                        constraints: const BoxConstraints(maxWidth: 175),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: const BoxDecoration(
                                                        color: Color(0xFF06B6D4),
                                                        shape: BoxShape.circle,
                                                    ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                    child: Text(
                                                        widget.currentChatTitle,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 11.5,
                                                            fontWeight: FontWeight.w500,
                                                            color: Color(0xFFF1F5F9),
                                                        ),
                                                    ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                    _isDrawerOpen
                                                        ? Icons.keyboard_arrow_up_rounded
                                                        : Icons.keyboard_arrow_down_rounded,
                                                    size: 14,
                                                    color: _isDrawerOpen
                                                        ? const Color(0xFF22D3EE)
                                                        : const Color(0xFF94A3B8),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                                // Quick action buttons (New, Rename, Delete)
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        InkWell(
                                            onTap: _showCreateChatDialog,
                                            borderRadius: BorderRadius.circular(6),
                                            child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                                decoration: BoxDecoration(
                                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                        color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                                                    ),
                                                ),
                                                child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        Icon(Icons.add_rounded, size: 12, color: Color(0xFF22D3EE)),
                                                        SizedBox(width: 3),
                                                        Text(
                                                            'New',
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w500,
                                                                color: Color(0xFF22D3EE),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                            onPressed: () {
                                                if (widget.currentChatId != null) {
                                                    _showRenameChatDialog(widget.currentChatId!, widget.currentChatTitle);
                                                }
                                            },
                                            tooltip: 'Rename active chat',
                                            icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF94A3B8)),
                                            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                            padding: EdgeInsets.zero,
                                        ),
                                        IconButton(
                                            onPressed: () {
                                                if (widget.currentChatId != null) {
                                                    _showDeleteChatDialog(widget.currentChatId!, widget.currentChatTitle);
                                                }
                                            },
                                            tooltip: 'Delete active chat',
                                            icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                                            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                            padding: EdgeInsets.zero,
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),

                    // Expandable Conversations Drawer
                    if (_isDrawerOpen)
                        Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            decoration: const BoxDecoration(
                                color: Color(0xFF060912),
                                border: Border(
                                    bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                                ),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF0B101D).withValues(alpha: 0.7),
                                            border: const Border(
                                                bottom: BorderSide(color: Color(0xFF334155), width: 0.5),
                                            ),
                                        ),
                                        child: Row(
                                            children: [
                                                Expanded(
                                                    child: Container(
                                                        height: 28,
                                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                                        decoration: BoxDecoration(
                                                            color: const Color(0xFF0F172A),
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: const Color(0xFF334155), width: 0.7),
                                                        ),
                                                        child: Row(
                                                            children: [
                                                                const Icon(Icons.search_rounded, size: 13, color: Color(0xFF94A3B8)),
                                                                const SizedBox(width: 6),
                                                                Expanded(
                                                                    child: TextField(
                                                                        controller: _searchController,
                                                                        style: const TextStyle(fontSize: 11, color: Color(0xFFF1F5F9)),
                                                                        decoration: const InputDecoration(
                                                                            hintText: 'Search conversations...',
                                                                            hintStyle: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                                            border: InputBorder.none,
                                                                            isDense: true,
                                                                            contentPadding: EdgeInsets.zero,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
                                                    ),
                                                    child: Text(
                                                        '${widget.chatSessions.length} Chats',
                                                        style: const TextStyle(fontSize: 10, color: Color(0xFF06B6D4), fontWeight: FontWeight.w500),
                                                    ),
                                                ),
                                                IconButton(
                                                    onPressed: _showCreateChatDialog,
                                                    tooltip: 'New conversation',
                                                    icon: const Icon(Icons.add_rounded, size: 15, color: Color(0xFF06B6D4)),
                                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                                    padding: EdgeInsets.zero,
                                                ),
                                            ],
                                        ),
                                    ),
                                    Flexible(
                                        child: Builder(
                                            builder: (context) {
                                                final q = _searchController.text.toLowerCase().trim();
                                                final filtered = widget.chatSessions.where((s) {
                                                    final title = (s['title'] ?? '').toString().toLowerCase();
                                                    return q.isEmpty || title.contains(q);
                                                }).toList();

                                                if (filtered.isEmpty) {
                                                    return const Padding(
                                                        padding: EdgeInsets.all(16),
                                                        child: Text(
                                                            'No conversations found',
                                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                        ),
                                                    );
                                                }

                                                return ListView.builder(
                                                    shrinkWrap: true,
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                    itemCount: filtered.length,
                                                    itemBuilder: (context, index) {
                                                        final session = filtered[index];
                                                        final id = (session['id'] as num?)?.toInt() ?? 0;
                                                        final title = (session['title'] as String?) ?? 'Untitled Chat';
                                                        final isActive = id == widget.currentChatId;

                                                        return InkWell(
                                                            onTap: () {
                                                                widget.onSelectChat?.call(id, title);
                                                                setState(() => _isDrawerOpen = false);
                                                            },
                                                            borderRadius: BorderRadius.circular(6),
                                                            child: Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                                margin: const EdgeInsets.only(bottom: 2),
                                                                decoration: BoxDecoration(
                                                                    color: isActive
                                                                        ? const Color(0xFF0E7490).withValues(alpha: 0.22)
                                                                        : Colors.transparent,
                                                                    borderRadius: BorderRadius.circular(6),
                                                                    border: Border.all(
                                                                        color: isActive
                                                                            ? const Color(0xFF06B6D4).withValues(alpha: 0.5)
                                                                            : Colors.transparent,
                                                                    ),
                                                                ),
                                                                child: Row(
                                                                    children: [
                                                                        Expanded(
                                                                            child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                    Text(
                                                                                        title,
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.5,
                                                                                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                                                                            color: isActive ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0),
                                                                                        ),
                                                                                    ),
                                                                                    Text(
                                                                                        _formatDate(session['updated_at'] ?? session['created_at']),
                                                                                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                                                                    ),
                                                                                ],
                                                                            ),
                                                                        ),
                                                                        IconButton(
                                                                            icon: const Icon(Icons.edit_outlined, size: 12, color: Color(0xFF94A3B8)),
                                                                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                                                            padding: EdgeInsets.zero,
                                                                            onPressed: () => _showRenameChatDialog(id, title),
                                                                        ),
                                                                        IconButton(
                                                                            icon: const Icon(Icons.delete_outline_rounded, size: 12, color: Color(0xFFEF4444)),
                                                                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                                                            padding: EdgeInsets.zero,
                                                                            onPressed: () => _showDeleteChatDialog(id, title),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        );
                                                    },
                                                );
                                            },
                                        ),
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
