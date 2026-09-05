import 'package:flutter/material.dart';
import '../models/assistant_state.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import 'chat/chat_active_banner.dart';
import 'chat/chat_empty_state.dart';
import 'chat/chat_header.dart';
import 'chat/chat_input_bar.dart';
import 'chat/chat_message_bubble.dart';
import 'chat/chat_quick_suggestions.dart';

/// Right panel for Galaxy AI showing conversational history, reasoning chains,
/// tool executions, and interactive prompt input.
class ChatPanel extends StatefulWidget {
    final List<ChatMessage> messages;
    final AssistantState state;
    final UserProfile userProfile;
    final void Function(String) onSendMessage;
    final VoidCallback onClearMessages;
    final VoidCallback onClose;
    final VoidCallback onToggleMic;
    final bool isMuted;

    const ChatPanel({
        super.key,
        required this.messages,
        required this.state,
        required this.userProfile,
        required this.onSendMessage,
        required this.onClearMessages,
        required this.onClose,
        required this.onToggleMic,
        required this.isMuted,
    });

    @override
    State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
    final TextEditingController _textController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final FocusNode _inputFocusNode = FocusNode();

    @override
    void didUpdateWidget(covariant ChatPanel oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (oldWidget.messages.length != widget.messages.length ||
            oldWidget.state != widget.state) {
            _scrollToBottom();
        }
    }

    void _scrollToBottom() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                );
            }
        });
    }

    void _handleSend() {
        final text = _textController.text.trim();
        if (text.isEmpty) return;
        _textController.clear();
        widget.onSendMessage(text);
        _scrollToBottom();
    }

    void _handleSelectSuggestion(String suggestion) {
        _textController.text = suggestion;
        _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: suggestion.length),
        );
        _inputFocusNode.requestFocus();
    }

    @override
    void dispose() {
        _textController.dispose();
        _scrollController.dispose();
        _inputFocusNode.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            width: 380,
            decoration: BoxDecoration(
                color: const Color(0xFF090D1C).withValues(alpha: 0.94),
                border: const Border(
                    left: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1.2,
                    ),
                ),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(-4, 0),
                    ),
                ],
            ),
            child: Column(
                children: [
                    // Panel Header
                    ChatHeader(
                        messageCount: widget.messages.length,
                        hasMessages: widget.messages.isNotEmpty,
                        onClearMessages: widget.onClearMessages,
                        onClose: widget.onClose,
                    ),

                    // Conversation Message Stream
                    Expanded(
                        child: widget.messages.isEmpty
                            ? const ChatEmptyState()
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                itemCount: widget.messages.length,
                                itemBuilder: (context, index) {
                                    final message = widget.messages[index];
                                    return ChatMessageBubble(
                                        message: message,
                                        userProfile: widget.userProfile,
                                    );
                                },
                            ),
                    ),

                    // Live State Indicator Bar (when thinking or executing tool)
                    if (widget.state.isActive)
                        ChatActiveBanner(state: widget.state),

                    // Quick Prompt Suggestion Chips
                    ChatQuickSuggestions(
                        onSelectSuggestion: _handleSelectSuggestion,
                    ),

                    // Bottom Input Area
                    ChatInputBar(
                        controller: _textController,
                        focusNode: _inputFocusNode,
                        isMuted: widget.isMuted,
                        onToggleMic: widget.onToggleMic,
                        onSend: _handleSend,
                    ),
                ],
            ),
        );
    }
}
