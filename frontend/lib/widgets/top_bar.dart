import 'package:flutter/material.dart';
import '../api/backend_client.dart';
import '../models/assistant_state.dart';
import '../models/user_profile.dart';
import 'top_bar/connection_status_badge.dart';
import 'top_bar/state_pill.dart';
import 'top_bar/user_profile_button.dart';

/// Desktop top navbar for Galaxy AI.
///
/// Features brand logo, live agent state pill, connection status,
/// navigation toggles for automation sidebar and chat panel,
/// settings launcher, and user profile avatar with initials fallback.
class TopBar extends StatelessWidget {
    final ConnectionStatus connectionStatus;
    final String connectionLabel;
    final AssistantState assistantState;
    final UserProfile userProfile;
    final bool isSidebarExpanded;
    final bool isChatPanelOpen;
    final VoidCallback onToggleSidebar;
    final VoidCallback onToggleChatPanel;
    final VoidCallback onOpenSettings;
    final VoidCallback? onRetryConnection;

    const TopBar({
        super.key,
        required this.connectionStatus,
        required this.connectionLabel,
        required this.assistantState,
        required this.userProfile,
        required this.isSidebarExpanded,
        required this.isChatPanelOpen,
        required this.onToggleSidebar,
        required this.onToggleChatPanel,
        required this.onOpenSettings,
        this.onRetryConnection,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
                color: const Color(0xFF070B18).withValues(alpha: 0.85),
                border: const Border(
                    bottom: BorderSide(
                        color: Color(0xFF1E293B),
                        width: 1.0,
                    ),
                ),
            ),
            child: Row(
                children: [
                    // Automation Sidebar Toggle
                    IconButton(
                        icon: Icon(
                            isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
                            size: 20,
                        ),
                        color: isSidebarExpanded
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF94A3B8),
                        tooltip: isSidebarExpanded ? 'Collapse automations' : 'Automations sidebar',
                        splashRadius: 18,
                        onPressed: onToggleSidebar,
                    ),

                    const SizedBox(width: 8),

                    // Brand Logo & Title
                    Row(
                        children: [
                            Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                        colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                        BoxShadow(
                                            color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                        ),
                                    ],
                                ),
                                child: const Center(
                                    child: Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 16,
                                    ),
                                ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        'Galaxy AI',
                                        style: TextStyle(
                                            color: Color(0xFFF8FAFC),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                        ),
                                    ),
                                    Text(
                                        'Desktop Agent • v2.4',
                                        style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 10,
                                            letterSpacing: 0.2,
                                        ),
                                    ),
                                ],
                            ),
                        ],
                    ),

                    const SizedBox(width: 20),

                    // Agent Live State Pill (e.g. Thinking, Speaking, Ready)
                    StatePill(state: assistantState),

                    const Spacer(),

                    // Connection Status Pill
                    ConnectionStatusBadge(
                        connectionStatus: connectionStatus,
                        connectionLabel: connectionLabel,
                        onRetryConnection: onRetryConnection,
                    ),

                    const SizedBox(width: 12),

                    // Chat Panel Toggle Button
                    IconButton(
                        icon: Icon(
                            isChatPanelOpen ? Icons.forum_rounded : Icons.forum_outlined,
                            size: 19,
                        ),
                        color: isChatPanelOpen
                            ? const Color(0xFFA855F7)
                            : const Color(0xFF94A3B8),
                        tooltip: isChatPanelOpen ? 'Hide conversation panel' : 'Show conversation panel',
                        splashRadius: 18,
                        onPressed: onToggleChatPanel,
                    ),

                    const SizedBox(width: 4),

                    // Settings Launcher Button
                    IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 20),
                        color: const Color(0xFF94A3B8),
                        tooltip: 'Settings & Configurations',
                        splashRadius: 18,
                        onPressed: onOpenSettings,
                    ),

                    const SizedBox(width: 8),

                    // Vertical Divider
                    Container(
                        height: 24,
                        width: 1,
                        color: const Color(0xFF1E293B),
                    ),

                    const SizedBox(width: 12),

                    // User Profile Section (Username, Gmail, Avatar with Initials Fallback)
                    UserProfileButton(
                        userProfile: userProfile,
                        onOpenSettings: onOpenSettings,
                    ),
                ],
            ),
        );
    }
}
