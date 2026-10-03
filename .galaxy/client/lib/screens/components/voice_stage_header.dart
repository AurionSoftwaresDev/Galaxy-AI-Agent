import 'package:flutter/material.dart';

import '../../models/assistant_state.dart';
import '../../widgets/status_indicator.dart';

/// Top header of the central Voice Stage in MainScreen with high-visibility Chat Logo button.
class VoiceStageHeader extends StatelessWidget {
    final bool isChatPanelOpen;
    final int messageCount;
    final ConnectionStatus connectionStatus;
    final VoidCallback onToggleChat;
    final VoidCallback? onOpenSettings;
    final VoidCallback onReconnect;

    const VoiceStageHeader({
        super.key,
        required this.isChatPanelOpen,
        this.messageCount = 0,
        required this.connectionStatus,
        required this.onToggleChat,
        this.onOpenSettings,
        required this.onReconnect,
    });

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Row(
                    children: [
                        Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                        Color(0x3306B6D4),
                                        Color(0x402563EB),
                                    ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0x7306B6D4),
                                    width: 1.25,
                                ),
                                boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x3306B6D4),
                                        blurRadius: 8,
                                    ),
                                ],
                            ),
                            child: const Center(
                                child: Icon(
                                    Icons.blur_on_rounded,
                                    size: 16,
                                    color: Color(0xFF22D3EE),
                                ),
                            ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                            'Galaxy AI',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: Color(0xFFF8FAFC),
                            ),
                        ),
                    ],
                ),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        StatusIndicator(
                            status: connectionStatus,
                            onReconnectRequested: onReconnect,
                        ),
                        const SizedBox(width: 12),
                        // Connected corner dock unifying Chat toggle and Settings / Agent APIs
                        _ConnectedCornerDock(
                            isChatOpen: isChatPanelOpen,
                            messageCount: messageCount,
                            onToggleChat: onToggleChat,
                            onOpenSettings: onOpenSettings,
                        ),
                    ],
                ),
            ],
        );
    }
}

/// Unified connected corner dock containing Chat toggle and Settings / Agent APIs.
class _ConnectedCornerDock extends StatelessWidget {
    final bool isChatOpen;
    final int messageCount;
    final VoidCallback onToggleChat;
    final VoidCallback? onOpenSettings;

    const _ConnectedCornerDock({
        required this.isChatOpen,
        required this.messageCount,
        required this.onToggleChat,
        this.onOpenSettings,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: const Color(0xFF0B101D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF334155),
                    width: 1.25,
                ),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                    ),
                ],
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    _DockButton(
                        icon: Icons.forum_rounded,
                        label: 'Chat',
                        isActive: isChatOpen,
                        tooltip: isChatOpen ? 'Close Chat Panel' : 'Open Galaxy AI Chat',
                        onTap: onToggleChat,
                    ),
                    if (onOpenSettings != null) ...[
                        Container(
                            width: 1,
                            height: 18,
                            color: const Color(0xFF334155),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                        ),
                        _DockButton(
                            icon: Icons.settings_rounded,
                            label: 'Settings / Agent APIs',
                            isActive: false,
                            tooltip: 'Galaxy AI Backend Settings & Agent APIs',
                            onTap: onOpenSettings!,
                        ),
                    ],
                ],
            ),
        );
    }
}

class _DockButton extends StatefulWidget {
    final IconData icon;
    final String label;
    final bool isActive;
    final String tooltip;
    final VoidCallback onTap;

    const _DockButton({
        required this.icon,
        required this.label,
        required this.isActive,
        required this.tooltip,
        required this.onTap,
    });

    @override
    State<_DockButton> createState() => _DockButtonState();
}

class _DockButtonState extends State<_DockButton> {
    bool _isHovered = false;

    @override
    Widget build(BuildContext context) {
        return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
                onTap: widget.onTap,
                child: Tooltip(
                    message: widget.tooltip,
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                            color: widget.isActive
                                ? const Color(0x520E7490)
                                : _isHovered
                                    ? const Color(0x991E293B)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: widget.isActive
                                ? Border.all(color: const Color(0x6606B6D4), width: 1)
                                : null,
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Icon(
                                    widget.icon,
                                    size: 14,
                                    color: widget.isActive || _isHovered
                                        ? const Color(0xFF22D3EE)
                                        : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                    widget.label,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: widget.isActive || _isHovered
                                            ? Colors.white
                                            : const Color(0xFFCBD5E1),
                                    ),
                                ),
                                if (widget.isActive) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                            color: Color(0xFF06B6D4),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                                BoxShadow(
                                                    color: Color(0xFF06B6D4),
                                                    blurRadius: 4,
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}

/// Custom interactive Chat Logo button with hover glow and smooth animated state.
class _ChatLogoButton extends StatefulWidget {
    final bool isOpen;
    final int messageCount;
    final VoidCallback onTap;

    const _ChatLogoButton({
        required this.isOpen,
        required this.messageCount,
        required this.onTap,
    });

    @override
    State<_ChatLogoButton> createState() => _ChatLogoButtonState();
}

class _ChatLogoButtonState extends State<_ChatLogoButton> {
    bool _isHovered = false;

    @override
    Widget build(BuildContext context) {
        final bool showBadge = widget.messageCount > 0 && !widget.isOpen;

        return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
                onTap: widget.onTap,
                child: Tooltip(
                    message: widget.isOpen
                        ? 'Collapse Chat Panel'
                        : 'Open Galaxy AI Chat (${widget.messageCount} messages)',
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                        ),
                        decoration: BoxDecoration(
                            color: widget.isOpen
                                ? const Color(0xFF111827)
                                : _isHovered
                                    ? const Color(0xFF0C192E)
                                    : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: widget.isOpen
                                    ? const Color(0xFF1E293B)
                                    : _isHovered
                                        ? const Color(0xFF06B6D4)
                                        : const Color(0xFF22D3EE)
                                            .withValues(alpha: 0.45),
                                width: widget.isOpen ? 1 : 1.25,
                            ),
                            boxShadow: [
                                if (!widget.isOpen || _isHovered)
                                    BoxShadow(
                                        color: const Color(0xFF06B6D4)
                                            .withValues(alpha: _isHovered ? 0.22 : 0.1),
                                        blurRadius: _isHovered ? 12 : 8,
                                        spreadRadius: 1,
                                    ),
                            ],
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                // Glowing Chat Logo emblem
                                Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                                Color(0xFF06B6D4),
                                                Color(0xFF3B82F6),
                                            ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                            BoxShadow(
                                                color: const Color(0xFF06B6D4)
                                                    .withValues(alpha: 0.35),
                                                blurRadius: 6,
                                            ),
                                        ],
                                    ),
                                    child: const Center(
                                        child: Icon(
                                            Icons.forum_rounded,
                                            size: 13,
                                            color: Color(0xFF07090E),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    'Chat',
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: !widget.isOpen || _isHovered
                                            ? const Color(0xFF22D3EE)
                                            : const Color(0xFFCBD5E1),
                                    ),
                                ),
                                if (showBadge) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF06B6D4),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                            '${widget.messageCount}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF07090E),
                                            ),
                                        ),
                                    ),
                                ],
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                    turns: widget.isOpen ? 0.5 : 0.0,
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    child: Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16,
                                        color: _isHovered
                                            ? const Color(0xFF22D3EE)
                                            : const Color(0xFF64748B),
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
